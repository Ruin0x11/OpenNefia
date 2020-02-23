(require 'lua-mode)
(require 'eval-sexp-fu nil t)
(require 'json)
(require 'dash)
(require 'company)
(require 'cl)
(require 'flycheck)
(require 'markdown-mode)
(require 'help-mode)

(defvar elona-next-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-l" 'elona-next-send-buffer)
    map))

(defcustom elona-next-always-send-to-repl nil
  "If non-nil, treat hotloading as evaluating the buffer in the REPL instead.")

(defcustom elona-next-repl-address "127.0.0.1"
  "Address to use for connecting to the REPL.")

(defcustom elona-next-repl-port 4567
  "Port to use for connecting to the REPL.")

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
    (with-demoted-errors "Error: %s"
        (elona-next--process-response
         (process-get proc :command)
         (process-get proc :content)
         response))))

(defun elona-next--completing-read (prompt list)
  (let ((cands (mapcar (lambda (c) (append c nil)) (append list nil)))
        (reader (if (bound-and-true-p ivy-read) 'ivy-read 'completing-read)))
    (funcall reader prompt cands nil t)))

(defun elona-next--fontify-region (mode beg end)
  (let ((prev-mode major-mode))
    (delay-mode-hooks (funcall mode))
    (font-lock-default-function mode)
    (font-lock-default-fontify-region beg end nil)
    ;(delay-mode-hooks (funcall prev-mode))
    ))

(defun elona-next--fontify-str (str mode)
  (with-temp-buffer
    (insert str)
    (elona-next--fontify-region mode (point-min) (point-max))
    (buffer-string)))

(defvar elona-next--eldoc-saved-message nil)
(defvar elona-next--eldoc-saved-point nil)

(defun elona-next--eldoc-message (&optional msg)
  (run-with-idle-timer 0 nil (lambda () (eldoc-message elona-next--eldoc-saved-message))))

(defun elona-next--eldoc-get ()
  (ignore-errors
    (let ((sym (elona-next--dotted-symbol-at-point)))
      (if (and (not (string-empty-p sym))
               (elona-next--game-running-p)
               (not (string-equal sym "nil")))
          (elona-next--send "signature" sym))))
  eldoc-last-message)

(defun elona-next-eldoc-function ()
  (if (and elona-next--eldoc-saved-message
           (equal elona-next--eldoc-saved-point (point)))
      elona-next--eldoc-saved-message

    (setq elona-next--eldoc-saved-message nil
          elona-next--eldoc-saved-point nil)
    (elona-next--eldoc-get)
    (let* ((sym-dotted (elona-next--dotted-symbol-at-point))
           (sym (symbol-at-point)))
      (when (not (or (string-empty-p sym-dotted) (string-empty-p sym)))
        (let ((defs (or (and sym-dotted (etags--xref-find-definitions sym-dotted))
                        (and sym (etags--xref-find-definitions (prin1-to-string sym))))))
          (when defs
            (let* ((def (car defs))
                   (raw (substring-no-properties (xref-item-summary def))))
              (with-temp-buffer
                (insert raw)
                (delay-mode-hooks (lua-mode))
                (font-lock-default-function 'lua-mode)
                (font-lock-default-fontify-region (point-min)
                                                  (point-max)
                                                  nil)
                (buffer-string)))))))))

(defun elona-next--game-running-p ()
  (or
   (and (buffer-live-p lua-process-buffer) (get-buffer-process lua-process-buffer))
   (and compilation-in-progress)))

(defun elona-next--process-response (cmd content response)
  (-let (((&alist 'success 'candidates 'message) response))
    (if (eq success t)
        (if candidates
            ; in pairs of ("api.Api.name", "api.api.name")
            (let ((cand (elona-next--completing-read "Candidate: " (append candidates nil))))
              (elona-next--send cmd cand))
          (pcase cmd
            ("help" (elona-next--command-help content response))
            ("jump_to" (elona-next--command-jump-to content response))
            ("signature" (elona-next--command-signature response))
            ("apropos" (elona-next--command-apropos response))
            ("completion" (elona-next--command-completion response))
            ("template" (elona-next--command-template response))
            ("ids" (elona-next--command-ids content response))
            ("run" t)
            ("hotload" t)
            (else (error "No action for %s %s" cmd (prin1-to-string response)))))
      (error message))))

;;
;; Commands
;;

(defun elona-next--start-of-help-buffer ()
  (let* ((str (buffer-string))
         (pos (string-match "^\n  " str)))
    (or (and pos (+ 1 pos))
        (save-excursion
          (beginning-of-buffer)
          (next-line 3)
          (point)))))

(defun elona-next--end-of-help-buffer ()
  (let ((str (buffer-string)))
    (or (string-match "\n= Parameters$" str)
        (string-match "\n= Returns$" str)
        (point-max))))

(defvar elona-next--help-buffer-font-lock-keywords
  `(;; Definitions
    (,(rx line-start "'" (group-n 1 (+ not-newline)) "'"
          " is " (? (or "a " "an ")) (group-n 2 (+ not-newline))
          " defined in '" (group-n 3 (+ not-newline))
          "' on line " (group-n 4 (+ digit)) ".")
     (1 font-lock-function-name-face t noerror)
     (2 font-lock-type-face t noerror)
     (3 '(face link) t noerror)
     (4 font-lock-constant-face t noerror))

    ;; Type signature
    (,(lua-rx line-start
              (group-n 1 lua-funcname)
              "("
              (group-n 2 (? "[") (* (or lua-name "...") (* (any " ,[])"))))
              ") :: ("
              (group-n 3 (* (+ (not (any "-)"))) (? " -> ")))
              ") => "
              (group-n 4 (+ (not (any "\n" space)))))
     (1 font-lock-function-name-face t noerror)
     (2 font-lock-variable-name-face t noerror)
     (3 font-lock-type-face t noerror)
     (4 font-lock-type-face t noerror))

    ;; Section headers
    (,(rx line-start "= " (group-n 1 (or "Parameters" "Returns")) line-end)
     (0 font-lock-comment-face t noerror))

    ;; Parameters
    (,(lua-rx line-start " * " (group-n 1 lua-name)
              " :: " (group-n 2 (+ (not (any "\n" space)))) (? ":"))
     (1 font-lock-variable-name-face t noerror)
     (2 font-lock-type-face t noerror))

    ;; Returns
    (,(lua-rx line-start " * " (group-n 1 (+ (not (any "\n" space)))))
     (1 font-lock-type-face nil noerror))
    ))

(define-button-type 'elona-next-file
  :supertype 'help-xref
  'help-function (lambda (file line)
                   (let ((path (string-join (list (projectile-project-root)
                                                  "src/"
                                                  file))))
                     (pop-to-buffer (find-file-noselect path))
                     (goto-line line)
                     (recenter)))
  'help-echo (purecopy "mouse-2, RET: find object's definition"))

(defvar elona-next--file-regexp "defined in '\\(.*?\\)' on line \\([0-9]+\\)")

(defun elona-next--format-help-buffer ()
  (save-excursion
    (beginning-of-buffer)
    (let ((paragraph-start "[ \t]*\n[ \t]*$\\|[ \t]*[-+*=] ")
          (fill-column 80)
          (start (elona-next--start-of-help-buffer))
          (end (elona-next--end-of-help-buffer))
          (inhibit-read-only t))
      (elona-next--fontify-region 'markdown-mode start end)
      (font-lock-add-keywords nil elona-next--help-buffer-font-lock-keywords)
      (font-lock-fontify-region (point-min) (point-max))
      (beginning-of-buffer)
      (next-line 3)
      (fill-region (point) (point-max))
      (beginning-of-buffer)
      (when (and (re-search-forward elona-next--file-regexp nil t)
                 (match-string 1))
        (help-xref-button 1 'elona-next-file (match-string 1) (string-to-number (match-string 2)))))))

(defvar elona-next--signature-font-lock-keywords
  `((,(lua-rx line-start
              (group-n 1 (symbol "function"))
              " "
              (group-n 2 lua-funcname)
              "("
              (group-n 3 (? "[") (* (or lua-name "...") (* (any " ,[])"))))
              ") "
              (group-n 4 (symbol "end"))
              " :: ("
              (group-n 5 (* (+ (not (any "-)"))) (? " -> ")))
              ") => "
              (group-n 6 (+ (not (any "\n" space)))))
     (1 font-lock-keyword-face t noerror)
     (2 font-lock-function-name-face t noerror)
     (3 font-lock-variable-name-face t noerror)
     (4 font-lock-keyword-face t noerror)
     (5 font-lock-type-face t noerror)
     (6 font-lock-type-face t noerror))))

(defun elona-next--fontify-signature (str)
  (with-temp-buffer
    (insert str)
    (font-lock-add-keywords nil elona-next--signature-font-lock-keywords)
    (font-lock-fontify-region (point-min) (point-max))
    (buffer-string)))

(defun elona-next--command-help (content response)
  (-let (((&alist 'doc 'message) response)
         (buffer (get-buffer-create "*elona-next-help*")))
    (with-help-window buffer
      (princ doc)
      (with-current-buffer buffer
        (elona-next--format-help-buffer)))
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
    (if file
        (let* ((loc (xref-make-file-location file line column))
               (marker (xref-location-marker loc))
               (buf (marker-buffer marker)))
          (xref-push-marker-stack)
          (switch-to-buffer buf)
          (xref--goto-char marker))
      (xref-find-definitions (strip-text-properties content)))))

(defun elona-next--command-signature (response)
  (-let* (((&alist 'sig 'params 'summary) response))
    (when sig
      (setq elona-next--eldoc-saved-message
            (elona-next--fontify-signature
             (format "%s :: %s%s" sig params (or (and (not (string-blank-p summary))
                                                      (format "\n%s" summary))
                                                 "")))
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

(defun elona-next--command-template (response)
  (insert (alist-get 'template response)))

(defun elona-next--command-ids (type response)
  (let ((ids (alist-get 'ids response)))
    (insert
     (format "\"%s\""
             (completing-read (format "ID (%s): " type)
                              (append ids nil))))))

;;
;; Network
;;

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
  (let ((proc (elona-next--make-tcp-connection elona-next-repl-address elona-next-repl-port))
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
          (buf (if compilation-in-progress
                   (if (buffer-live-p compilation-last-buffer)
                       compilation-last-buffer
                     (get-buffer "*compilation*"))
                 lua-process-buffer)))
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
    (elona-next--send "run" (format "require('api.Repl').send([[\n%s\n]])" str))))

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
           (string-join (list (projectile-project-root)))))
         (lua-path (string-trim-left
                    (replace-regexp-in-string "/" "." prefix)
                    "\\(src\\)?\\.+"))
         (lua-name (let ((it (car (last (split-string lua-path "\\.")))))
                     (if (string-equal it "init")
                         (car (last (butlast
                                     (split-string lua-path "\\."))))
                       it))))
    (cons lua-path lua-name)))

(defun elona-next-hotload-this-file ()
  (interactive)
  (if elona-next-always-send-to-repl
      (elona-next-eval-buffer)
    (let* ((lua-path (car (elona-next--require-path-of-file (buffer-file-name)))))
      (save-buffer)
      (elona-next--send "hotload" lua-path)
      (message "Hotloaded %s." lua-path))))

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

(defun elona-next--require-path (file)
  (let* ((pair (elona-next--require-path-of-file file))
         (lua-path (car pair))
         (lua-name (cdr pair))
         (local (if elona-next-always-send-to-repl "" "local ")))
    (format
     "%s%s = require(\"%s\")\n"
     local
     lua-name
     lua-path)))

(defun elona-next-copy-require-path ()
  (interactive)
  (let ((src (elona-next--require-path (buffer-file-name))))
    (message "%s" src)
    (kill-new src)))

(defun elona-next-insert-require-for-file (file)
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (beginning-of-line)
    (insert (elona-next--require-path
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
  (let* ((regexp (format "/%s\\(\\|/init\\).lua$" api-name))
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
      (-each paths 'elona-next-insert-require-for-file)
      (save-buffer)
      (flycheck-buffer))))

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
          (kill-line)))
      (save-buffer)
      (flycheck-buffer))))

(defvar elona-next--eval-expression-history '())

(defun elona-next-eval-expression (exp)
  (interactive
   (list
    (read-from-minibuffer "Eval (lua): " nil nil nil 'elona-next--eval-expression-history)))
  (elona-next--send-to-repl exp))

(defun elona-next-eval-region (start end)
  (interactive "r")
  (elona-next--send-to-repl (buffer-substring start end)))

(defun elona-next-eval-buffer ()
  (interactive)
  (elona-next--send-to-repl (buffer-string)))

(defun elona-next-eval-current-line ()
  (interactive)
  (elona-next-eval-region (line-beginning-position) (line-end-position)))

(defun elona-next--bounds-of-block ()
  (save-excursion
    (let ((start
           (save-excursion
             (while (and (not (bobp)) (> (lua-calculate-indentation) 0))
               (previous-line))
             (beginning-of-line)
             (point)))
          (end
           (save-excursion
             (while (and (not (eobp)) (> (lua-calculate-indentation) 0))
               (next-line))
             (end-of-line)
             (point))))
      (cons start end))))

(defun elona-next-eval-block ()
  (interactive)
  (let ((pos (elona-next---bounds-of-block)))
    (elona-next-eval-region (car pos) (cdr pos))))

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
  (if (elona-next--game-running-p)
      (let* ((sym (if arg
                      (symbol-name (symbol-at-point))
                    (elona-next--dotted-symbol-at-point)))
             (result (if (string-equal sym "nil")
                         (elona-next--completing-read
                          "Jump to: "
                          (json-read-file (elona-next--apropos-file "data/apropos.json")))
                       sym)))
        (elona-next--send "jump_to" result))
    (xref-find-definitions (elona-next--dotted-symbol-at-point))))

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
    (eval-sexp-fu-flash (elona-next--bounds-of-line)))

  (define-eval-sexp-fu-flash-command elona-next-eval-block
    (eval-sexp-fu-flash (elona-next--bounds-of-block)))
  (define-eval-sexp-fu-flash-command elona-next-eval-current-line
    (eval-sexp-fu-flash (elona-next--bounds-of-line)))

  (define-eval-sexp-fu-flash-command lua-send-buffer
    (eval-sexp-fu-flash (elona-next--bounds-of-buffer))))

(defvar elona-next--repl-errors-buffer "*elona-next-repl-errors*")
(defvar elona-next--repl-name "elona-next-repl")

(defun elona-next--repl-file ()
  (string-join (list (projectile-project-root) "src/repl.lua")))

(defun elona-next--test-repl ()
  (with-current-buffer (get-buffer-create elona-next--repl-errors-buffer)
    (erase-buffer)
    (apply 'call-process "luajit" nil
           (current-buffer)
           nil
           (list (elona-next--repl-file) "test"))))

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
      (let ((result (elona-next--test-repl)))
        (if (eq result 0)
            (progn
              (run-lua elona-next--repl-name "luajit" nil (elona-next--repl-file) switch)
              (setq next-error-last-buffer (get-buffer buffer-name))
              (pop-to-buffer buffer-name)
              (setq-local company-backends '(company-etags)))
          (progn
            (with-current-buffer elona-next--repl-errors-buffer
              (ansi-color-apply-on-region (point-min) (point-max)))
            (pop-to-buffer elona-next--repl-errors-buffer)
            (error "REPL startup failed with code %s." result)))))))

(defun elona-next-run-batch-script ()
  (interactive)
  (compile (format "%s repl.lua batch %s" lua-default-application (buffer-file-name))))

(defun elona-next-insert-template ()
  (interactive)
  (elona-next--send "template" ""))

(defun elona-next-insert-id ()
  (interactive)
  (elona-next--send "ids" ""))

(defun elona-next-make-scratch-buffer ()
  (interactive)
  (let* ((filename (format-time-string "%Y-%m-%d_%H-%M-%S.lua"))
         (dest-path (string-join (list (projectile-project-root) "src/scratch/" filename))))
    (find-file dest-path)
    (newline)
    (add-file-local-variable 'elona-next-always-send-to-repl t)
    (beginning-of-buffer)))

(provide 'elona-next)
