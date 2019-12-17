(require 'lua-mode)
(require 'eval-sexp-fu nil t)
(require 'json)
(require 'dash)
(require 'company)
(require 'cl)

(defvar elona-next-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-l" 'elona-next-send-buffer)
    map))

;;;###autoload
(define-minor-mode elona-next-minor-mode
  "Elona next debug server."
  :lighter " Elona" :keymap elona-next-minor-mode-map)

(defun elona-next--parse-response ()
  (condition-case nil
      (progn
        (goto-char (point-min))
        (if (fboundp 'json-parse-buffer)
            (json-parse-buffer
             :object-type 'alist
             :null-object nil
             :false-object :json-false)
          (json-read)))
    (error nil)))

(defun elona-next--tcp-filter (proc chunk)
  (with-current-buffer (process-buffer proc)
    (goto-char (point-max))
    (insert chunk)
    (let ((response (process-get proc :response)))
      (unless response
        (when (setf response (elona-next--parse-response))
          (delete-region (point-min) (point))
          (process-put proc :response response)))))
  (when-let ((response (process-get proc :response)))
    (with-current-buffer (process-buffer proc)
      (erase-buffer))
    (process-put proc :response nil)
    (elona-next--process-response
     (process-get proc :command)
     (process-get proc :content)
     response)))

(defun elona-next--completing-read (prompt list)
  (let ((cands (mapcar (lambda (c) (append c nil)) (append list nil))))
    (completing-read prompt cands)))

(defun elona-next--fontify-str (str)
  (with-temp-buffer
    (insert str)
    (delay-mode-hooks (lua-mode))
    (font-lock-default-function 'lua-mode)
    (font-lock-default-fontify-region (point-min)
                                      (point-max)
                                      nil)
    (buffer-string)))

(defvar elona-next--eldoc-saved-message nil)
(defvar elona-next--eldoc-saved-point nil)

(defun elona-next--eldoc-message (&optional msg)
  (run-with-idle-timer 0 nil (lambda () (eldoc-message elona-next--eldoc-saved-message))))

(defun elona-next--game-running-p ()
  (or
   (and (buffer-live-p lua-process-buffer) (get-buffer-process lua-process-buffer))
   (and compilation-in-progress)))

(defun elona-next-eldoc-function ()
  (ignore-errors
    (when (elona-next--game-running-p)
      (elona-next--send "signature"
                        (elona-next--dotted-symbol-at-point))))
  eldoc-last-message)

(defun elona-next--process-response (cmd content response)
  (-let (((&alist 'success 'candidates 'message) response))
    (if (eq success t)
        (if candidates
            ; in pairs of ("api.Api.name", "api.api.name")
            (let ((cand (elona-next--completing-read "Candidate: " (cdr candidates))))
              (elona-next--send cmd cand))
          (pcase cmd
            ("help" (elona-next--command-help content response))
            ("jump_to" (elona-next--command-jump-to content response))
            ("signature" (elona-next--command-signature response))
            ("apropos" (elona-next--command-apropos response))
            ("completion" (elona-next--command-completion response))
            ("run" t)
            (else (error "No action for %s" cmd))))
      (error message))))

;;
;; Commands
;;

(defun elona-next--command-help (content response)
  (-let (((&alist 'doc 'message) response)
         (buffer (get-buffer-create "*elona-next-help*")))
    (with-help-window buffer
      (princ doc)
      (with-current-buffer buffer
        (let ((paragraph-start "[ \t]*\n[ \t]*$\\|[ \t]*[-+*=] ")
              (fill-column 80))
          (beginning-of-buffer)
          (next-line 3)
          (fill-region (point) (point-max)))))
    (message "%s" message)))

(defvar elona-next--is-completing nil)

(defun elona-next--command-completion (response)
  (when elona-next--is-completing
    (-let* (((&alist 'results 'prefix) response)
            (candidates (mapcar (lambda (item)
                                  (elona-next--make-completion-candidate item prefix))
                                results)))))
  (funcall elona-next--is-completing candidates)
  (setq elona-next--is-completing nil))

(defun elona-next--company-candidates (prefix callback)
  (message (prin1-to-string prefix))
  (when (elona-next--game-running-p)
    (progn
      (setq elona-next--is-completing callback)
      (elona-next--send "completion" prefix))))

;;;###autoload
(defun company-elona-next (command &optional arg &rest _)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend #'company-elona-next))
    (prefix (substring-no-properties (company-grab-symbol)))
    (candidates (cons :async (lambda (callback) (elona-next--company-candidates arg callback))))
    ;(annotation (elona-next--company-annotation arg))
    ;(quickhelp-string (elona-next--company-quickhelp-string arg))
    ;; (doc-buffer (company-doc-buffer "*elona-next-help*"))
    ))

(defun elona-next--command-jump-to (content response)
  (-let* (((&alist 'success 'file 'line 'column) response))
    (if (eq success t)
        (let* ((loc (xref-make-file-location file line column))
               (marker (xref-location-marker loc))
               (buf (marker-buffer marker)))
          (xref--push-markers)
          (switch-to-buffer buf)
          (xref--goto-char marker))
      (xref-find-definitions content))))

(defun elona-next--command-signature (response)
  (-let* (((&alist 'sig 'params 'summary) response))
    (when sig
      (setq elona-next--eldoc-saved-message
            (format "%s :: %s%s" (elona-next--fontify-str sig) params (or (and (not (string-blank-p summary))
                                                                               (format "\n%s" summary))
                                                                          ""))
            elona-next--eldoc-saved-point (point))
      (elona-next--eldoc-message elona-next--eldoc-saved-message))))

(defvar elona-next--apropos-candidates nil)

(defun elona-next--apropos-file (path)
  (let ((base (if (elona-next--headless-mode-p)
                  (string-trim-right (temporary-file-directory) "/")
                (getenv "HOME")))
        (sep (if (eq system-type 'windows-nt) "\\" "/"))
        (dir
         (if (eq system-type 'windows-nt)
             "AppData\\Roaming\\LOVE"
           ".local/share/love")))
    (string-join (list base dir "Elona_next" path) sep)))

(defun elona-next--command-apropos (response)
  (-let* (((&alist 'path 'updated) response)
          (items (or
                  (and (not updated) elona-next--apropos-candidates)
                  (json-read-file (elona-next--apropos-file path)))))
    (setq elona-next--apropos-candidates items)
    (let ((item (elona-next--completing-read "Apropos: " items)))
      (elona-next--send "help" item))))

(defun elona-next--tcp-sentinel (proc message)
  "Runs when a client closes the connection."
  (when (string-match-p "^open " message)
    (let ((buffer (process-buffer proc)))
      (when buffer
        (kill-buffer buffer)))))

(defun elona-next--make-tcp-connection (host port)
  (make-network-process :name "elona next"
                        :buffer "*elona next*"
                        :host host
                        :service port
                        :filter 'elona-next--tcp-filter
                        :sentinel 'elona-next--tcp-sentinel
                        :coding 'utf-8))

(defun elona-next--headless-mode-p ()
  (and (buffer-live-p lua-process-buffer)
       (get-buffer-process lua-process-buffer)))

(defun elona-next--send (cmd str)
  (let ((proc (elona-next--make-tcp-connection "127.0.0.1" 4567))
        (json (json-encode (list :command cmd :content str))))
    (when (process-live-p proc)
      (process-put proc :command cmd)
      (process-put proc :content str)
      (comint-send-string proc (format "%s\n" json))
      (process-send-eof proc)
      ;; In REPL mode, run the server for one step to ensure the
      ;; response is received (it's supposed to run every frame as
      ;; a coroutine in LOVE)
      (when (elona-next--headless-mode-p)
        (lua-send-string "server:step()"))))

  ;; Show the REPL if we're executing code.
  (when (string-equal cmd "run")
    (let ((win (get-buffer-window lua-process-buffer))
          (compilation-win (get-buffer-window compilation-last-buffer))
          (buf (if compilation-in-progress compilation-last-buffer lua-process-buffer)))
      (when (not (or (and compilation-win (window-live-p win)) (and lua-process-buffer win (window-live-p win))))
        (when (and (buffer-live-p buf) (not (window-live-p (get-buffer-window buf))))
          (popwin:popup-buffer buf :stick t :noselect t :height 0.3)))
      (if-let ((win (get-buffer-window buf)))
          (save-excursion
            (with-selected-window win
              (end-of-buffer)))))))

(defun elona-next--get-lua-result ()
  "Gets the last line of the current Lua buffer."
  (with-current-buffer lua-process-buffer
    (sleep-for 0 200)
    (goto-char (point-max))
    (forward-line -1)
    (let ((line (thing-at-point 'line t)))
      (substring line 2 (max 3 (- (length line) 1))))))

(defun elona-next--send-to-repl (str)
  (if (elona-next--headless-mode-p)
      (progn
        (lua-send-string str)
        (message (elona-next--get-lua-result)))
    (elona-next--send "run" (format "require('api.Repl').send('%s')" str))))

(defun elona-next-send-region (start end)
  (interactive "r")
  (setq start (lua-maybe-skip-shebang-line start))
  (let* ((lineno (line-number-at-pos start))
         (region-str (buffer-substring-no-properties start end)))
    (elona-next--send "run" region-str)))

(defun elona-next-send-buffer ()
  (interactive)
  (elona-next-send-region (point-min) (point-max)))

(defun elona-next-send-current-line ()
  (interactive)
  (elona-next-send-region (line-beginning-position) (line-end-position)))

(defun elona-next--bounds-of-last-defun (pos)
  (save-excursion
    (let ((start (if (save-match-data (looking-at "^function[ \t]"))
                     (point)
                   (lua-beginning-of-proc)
                   (point)))
          (end (progn (lua-end-of-proc) (point))))

      (if (and (>= pos start) (< pos end))
          (cons start end)
        (cons 0 1)))))

(defun elona-next--bounds-of-buffer ()
  (cons (point-min) (point-max)))

(defun elona-next--bounds-of-line ()
  (cons (point-at-bol) (point-at-eol)))

(defun elona-next-send-defun (pos)
  (interactive "d")
  (let ((bounds (elona-next--bounds-of-last-defun pos)))
    (elona-next-send-region (car bounds) (cdr bounds))))

(defun elona-next--require-path-of-file (file)
  (let* ((prefix
          (file-relative-name
           (file-name-sans-extension file)
           (string-join (list (projectile-project-root) "src/"))))
         (lua-path (string-trim-left
                    (replace-regexp-in-string "/" "." prefix)
                    "\\.+"))
         (lua-name (let ((it (car (last (split-string lua-path "\\.")))))
                     (if (string-equal it "init")
                         (car (last (butlast
                                     (split-string lua-path "\\."))))
                       it))))
    (cons lua-path lua-name)))

(defun elona-next-hotload-this-file ()
  (interactive)
  (let* ((lua-path (car (elona-next--require-path-of-file (buffer-file-name))))
         (cmd (format
               "local ok, hotload = pcall(function() return require('hotload') end); if ok then hotload('%s') else require('internal.hotload').hotload('%s') end"
               lua-path
               lua-path)))
    (save-buffer)
    (elona-next--send "run" cmd)
    (message "Hotloaded %s." lua-path)))

(defun elona-next-require-this-file ()
  (interactive)
  (let* ((pair (elona-next--require-path-of-file (buffer-file-name)))
         (lua-path (car pair))
         (lua-name (cdr pair))
         (cmd (format
               "%s = require(\"%s\")"
               lua-name
               lua-path)))
    (save-buffer)
    (elona-next--send-to-repl cmd)
    (message "%s" cmd)))

(defun elona-next-require-path (file)
  (interactive)
  (let* ((pair (elona-next--require-path-of-file file))
         (lua-path (car pair))
         (lua-name (cdr pair)))
    (format
     "local %s = require(\"%s\")\n"
     lua-name
     lua-path)))

(defun elona-next-copy-require-path ()
  (interactive)
  (let ((src (elona-next-require-path (buffer-file-name))))
    (message "%s" src)
    (kill-new src)))

(defun elona-next-insert-require-for-file (file)
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (beginning-of-line)
    (insert (elona-next-require-path
             (string-join (list project-root file))))
    (indent-region (point-at-bol) (point-at-eol))))

(defun elona-next--api-file-cands ()
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (-filter (lambda (f)
               (and (not (string-prefix-p "lib/" f))
                    (string-equal "lua" (file-name-extension f))))
             (projectile-project-files project-root))))

(defun elona-next-insert-require ()
  (interactive)
  (let* ((files (elona-next--api-file-cands))
         (file (projectile-completing-read "File: " files)))
    (when file
      (elona-next-insert-require-for-file file))))

(defun elona-next--extract-missing-api (flycheck-error)
  (let ((message (flycheck-error-message flycheck-error)))
    (when (string-match "accessing undefined variable '\\(.+\\)'" message)
      (match-string 1 message))))

(defun elona-next--api-name-to-path (api-name cands)
  (let* ((regexp (format "/%s.lua$" api-name))
         (case-fold-search nil)
         (filtered (-filter (lambda (f) (string-match-p regexp f)) cands)))
    (cl-case (length filtered)
      (0 nil)
      (1 (car filtered))
      (t (completing-read (format "Path for '%s': " api-name) filtered)))))

(defun elona-next-insert-missing-requires ()
  (interactive)
  (let* ((errors flycheck-current-errors)
         (apis (-uniq (-non-nil (-map 'elona-next--extract-missing-api errors))))
         (cands (elona-next--api-file-cands))
         (paths (-non-nil (-map (lambda (n) (elona-next--api-name-to-path n cands)) apis))))
    (save-excursion
      (beginning-of-buffer)
      (-each paths 'elona-next-insert-require-for-file))))

(defun elona-next--extract-unused-api (flycheck-error)
  (let ((message (flycheck-error-message flycheck-error))
        (line (flycheck-error-line flycheck-error)))
    (when (string-match "unused variable '\\([A-Z][a-zA-Z]+\\)'" message)
      line)))

(defun elona-next-remove-unused-requires ()
  (interactive)
  (let* ((errors flycheck-current-errors)
         (lines (sort (-non-nil (-map 'elona-next--extract-unused-api errors)) '>))
         (kill-whole-line t))
    (save-excursion
      (-each lines
        (lambda (line)
          (goto-line line)
          (beginning-of-line)
          (kill-line))))))

(defvar elona-next--eval-expression-history '())

(defun elona-next-eval-expression (exp)
  (interactive
   (list
    (read-from-minibuffer "Eval: " nil nil nil 'elona-next--eval-expression-history)))
  (elona-next--send-to-repl exp))

(defun elona-next-eval-current-line ()
  (interactive)
  (elona-next--send-to-repl (buffer-substring (line-beginning-position) (line-end-position))))

(defun elona-next--dotted-symbol-at-point ()
  (interactive)
  (with-syntax-table (copy-syntax-table)
    (modify-syntax-entry ?. "_")
    (string-trim
     (symbol-name
      (symbol-at-point))
     "[.:]" "[.:]")))

(defun elona-next-describe-thing-at-point (arg)
  (interactive "P")
  (let ((sym (if arg
                 (symbol-name (symbol-at-point))
               (elona-next--dotted-symbol-at-point))))
    (elona-next--send "help" sym)))

(defun elona-next-jump-to-definition (arg)
  (interactive "P")
  (let ((sym (if arg
                 (symbol-name (symbol-at-point))
               (elona-next--dotted-symbol-at-point))))
    (elona-next--send "jump_to" sym)))

(defun elona-next-describe-apropos ()
  (interactive)
  (elona-next--send "apropos" ""))

(defun elona-next-eval-sexp-fu-setup ()
  (define-eval-sexp-fu-flash-command elona-next-send-defun
    (eval-sexp-fu-flash (elona-next--bounds-of-last-defun (point))))
  (define-eval-sexp-fu-flash-command elona-next-hotload-this-file
    (eval-sexp-fu-flash (elona-next--bounds-of-buffer)))
  (define-eval-sexp-fu-flash-command elona-next-require-this-file
    (eval-sexp-fu-flash (elona-next--bounds-of-buffer)))
  (define-eval-sexp-fu-flash-command elona-next-send-current-line
    (eval-sexp-fu-flash (elona-next--bounds-of-line))))

(defvar elona-next--repl-errors-buffer "*elona-next-repl-errors*")
(defvar elona-next--repl-name "elona-next-repl")

(defun elona-next--repl-file ()
  (string-join (list (projectile-project-root) "src/repl.lua")))

(defun elona-next--test-repl ()
  (with-current-buffer (get-buffer-create elona-next--repl-errors-buffer)
    (erase-buffer)
    (let ((result (apply 'call-process "luajit" nil
                         (current-buffer)
                         nil
                         (list (elona-next--repl-file) "test"))))
      (equal 0 result))))

(defun elona-next-start-repl (&optional arg)
  (interactive "P")
  (let* ((buffer-name (string-join (list "*" elona-next--repl-name "*")))
         (buffer (get-buffer buffer-name))
         (default-directory (file-name-directory (directory-file-name (elona-next--repl-file))))
         (switch (or (and arg "load") "")))
    (when-let ((buf (get-buffer elona-next--repl-errors-buffer))
               (dir default-directory))
      (with-current-buffer buf
        (setq-local default-directory dir)))
    (if (and (buffer-live-p buffer) (process-live-p (get-buffer-process buffer)))
        (progn
          (setq next-error-last-buffer (get-buffer buffer-name))
          (pop-to-buffer buffer)
          (comint-goto-process-mark))
      (if (elona-next--test-repl)
          (progn
            (run-lua elona-next--repl-name "luajit" nil (elona-next--repl-file) switch)
            (setq next-error-last-buffer (get-buffer buffer-name))
            (pop-to-buffer buffer-name))
        (progn
          (pop-to-buffer elona-next--repl-errors-buffer)
          (error "REPL startup failed."))))))

(provide 'elona-next)
