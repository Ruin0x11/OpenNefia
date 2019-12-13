(require 'lua-mode)
(require 'eval-sexp-fu nil t)
(require 'json)
(require 'dash)

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
             :object-type 'plist
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

(defun elona-next--process-response (cmd content response)
  (if-let ((candidates (plist-get :candidates response)))
      (let ((cand (completing-read "Candidate: " (append candidates nil))))
        (elona-next--send cmd cand))
    (pcase cmd
      ("help" (elona-next--command-help content response))
      ("jump_to" (elona-next--command-jump-to content response))
      ("signature" (elona-next--command-signature response))
      ("apropos" (elona-next--command-apropos response))
      ("run" t)
      (else (error "No action for %s" cmd)))))

(defun elona-next--command-help (content response)
  (-let (((&plist :success :doc :message) response)
         (buffer (get-buffer-create "*elona-next-help*")))
     (if (eq success t)
        (with-help-window buffer
          (princ doc)))
    (message "%s" message)))

(defun elona-next--command-jump-to (content response)
  (-let* (((&plist :success :file :line :column) response))
    (if (eq success t)
        (let ((loc (xref-make-file-location file line column)))
          (xref--push-markers)
          (xref--show-location loc nil))
      (xref-find-definitions content))))

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

(defun elona-next--command-signature (response)
  (-let* (((&plist :sig :params :summary) response))
    (when sig
      (setq elona-next--eldoc-saved-message
            (format "%s :: %s\n%s" (elona-next--fontify-str sig) params summary)
            elona-next--eldoc-saved-point (point))
      (elona-next--eldoc-message elona-next--eldoc-saved-message))))

(defun elona-next-eldoc-function ()
  (ignore-errors
      (elona-next--send "signature"
                        (symbol-name (elona-next--dotted-symbol-at-point))))
  eldoc-last-message)

(defun elona-next--command-apropos (response)
  (-let* (((&plist :items) response)
          (cand (completing-read "Apropos: " (append items nil))))
    (elona-next--send "help" cand)))

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
      (when (and (buffer-live-p lua-process-buffer)
                 (get-buffer-process lua-process-buffer))
        (lua-send-string "server:step()"))))

  ;; Show the REPL if we're executing code.
  (when (string-equal cmd "run")
    (let ((win (get-buffer-window lua-process-buffer))
          (compilation-win (get-buffer-window compilation-last-buffer))
          (buf (if compilation-in-progress compilation-last-buffer lua-process-buffer)))
      (when (not (or (and compilation-win (window-live-p win)) (and lua-process-buffer win (window-live-p win))))
        (when (and (buffer-live-p buf) (not (window-live-p (get-buffer-window buf))))
          (popwin:display-buffer buf)))
      (if-let ((win (get-buffer-window buf)))
          (with-selected-window win
            (end-of-buffer))))))

(defun elona-next--send-to-repl (str)
  (elona-next--send "run" (format "require('api.Repl').send('%s')" str)))

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

(defun elona-next-insert-require ()
  (interactive)
  (let* ((project-root (projectile-ensure-project (projectile-project-root)))
         (cands (seq-filter (lambda (f)
                              (and (not (string-prefix-p "lib/" f))
                               (string-equal "lua" (file-name-extension f))))
                            (projectile-project-files project-root)))
         (file (projectile-completing-read "File: " cands)))
    (when file
      (beginning-of-line)
      (when (not (eobp))
        (next-line))
      (insert (elona-next-require-path
               (string-join (list project-root file))))
      (when (not (bobp))
        (previous-line))
      (indent-region (point-at-bol) (point-at-eol)))))

(defun elona-next-run-this-file ()
  (interactive)
  (lua-send-string (format "dofile \"%s\"" (buffer-file-name))))

(defun elona-next--dotted-symbol-at-point ()
  (interactive)
  (with-syntax-table (copy-syntax-table)
    (modify-syntax-entry ?. "_")
    (modify-syntax-entry ?: "_")
    (symbol-at-point)))

(defun elona-next-describe-thing-at-point (arg)
  (interactive "P")
  (let ((sym (if arg
                 (symbol-at-point)
               (elona-next--dotted-symbol-at-point))))
    (elona-next--send "help" (symbol-name sym))))

(defun elona-next-jump-to-definition (arg)
  (interactive "P")
  (let ((sym (if arg
                 (symbol-at-point)
               (elona-next--dotted-symbol-at-point))))
    (elona-next--send "jump_to" (symbol-name sym))))

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
