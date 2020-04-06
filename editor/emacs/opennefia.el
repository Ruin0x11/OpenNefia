(require 'lua-mode)
(require 'eval-sexp-fu nil t)
(require 'json)
(require 'dash)
(require 'company)
(require 'cl)
(require 'flycheck)
(require 'markdown-mode)
(require 'help-mode)

(defvar opennefia-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-l" 'opennefia-send-buffer)
    map))

(defvar-local opennefia-always-send-to-repl nil
  "If non-nil, treat hotloading as evaluating the buffer in the REPL instead.")

(defcustom opennefia-repl-address "127.0.0.1"
  "Address to use for connecting to the REPL.")

(defcustom opennefia-repl-port 4567
  "Port to use for connecting to the REPL.")

;;;###autoload
(define-minor-mode opennefia-minor-mode
  "Elona next debug server."
  :lighter " OpenNefia" :keymap opennefia-minor-mode-map)

(defun opennefia--parse-response ()
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

(defun opennefia--tcp-filter (proc chunk)
  (with-current-buffer (process-buffer proc)
    (goto-char (point-max))
    (insert chunk)
    (let ((response (process-get proc :response)))
      (unless response
        (when (setf response (opennefia--parse-response))
          (delete-region (point-min) (point))
          (process-put proc :response response)))))
  (when-let ((response (process-get proc :response)))
    (with-current-buffer (process-buffer proc)
      (erase-buffer))
    (process-put proc :response nil)
    (with-demoted-errors "Error: %s"
        (opennefia--process-response
         (process-get proc :command)
         (process-get proc :args)
         response))))

(defun opennefia--completing-read (prompt list)
  (let ((cands (mapcar (lambda (c) (append c nil)) (append list nil)))
        (reader (if (bound-and-true-p ivy-read) 'ivy-read 'completing-read)))
    (funcall reader prompt cands nil t)))

(defun opennefia--fontify-region (mode beg end)
  (let ((prev-mode major-mode))
    (delay-mode-hooks (funcall mode))
    (font-lock-default-function mode)
    (font-lock-default-fontify-region beg end nil)
    ;(delay-mode-hooks (funcall prev-mode))
    ))

(defun opennefia--fontify-str (str mode)
  (with-temp-buffer
    (insert str)
    (opennefia--fontify-region mode (point-min) (point-max))
    (buffer-string)))

(defvar opennefia--eldoc-saved-message nil)
(defvar opennefia--eldoc-saved-point nil)

(defun opennefia--eldoc-message (&optional msg)
  (run-with-idle-timer 0 nil (lambda () (eldoc-message opennefia--eldoc-saved-message))))

(defun opennefia--eldoc-get ()
  (ignore-errors
    (let ((sym (opennefia--dotted-symbol-at-point)))
      (if (and (not (string-empty-p sym))
               (opennefia--game-running-p)
               (not (string-equal sym "nil")))
          (opennefia--send "signature" sym))))
  eldoc-last-message)

(defun opennefia-eldoc-function ()
  (if (and opennefia--eldoc-saved-message
           (equal opennefia--eldoc-saved-point (point)))
      opennefia--eldoc-saved-message

    (setq opennefia--eldoc-saved-message nil
          opennefia--eldoc-saved-point nil)
    (opennefia--eldoc-get)
    (let* ((sym-dotted (opennefia--dotted-symbol-at-point))
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

(defun opennefia--game-running-p ()
  (or
   (and (buffer-live-p lua-process-buffer) (get-buffer-process lua-process-buffer))
   (and compilation-in-progress)))

(defun opennefia--process-response (cmd args response)
  (with-demoted-errors "Error: %s"
    (-let (((&alist 'success 'candidates 'message) response))
      (if (eq success t)
          (if candidates
              ; in pairs of ("api.Api.name", "api.api.name")
              (let* ((cand (opennefia--completing-read "Candidate: " (append candidates nil)))
                     (args (pcase cmd
                             ("help" (list :query cand))
                             ("ids" (list :type cand))
                             ("template" (list :type cand))
                             ("hotload" (list :require_path cand))
                             (else (error "Candidates not supported for %s" cmd)))))
                (opennefia--send cmd cand))
            (pcase cmd
              ("help" (opennefia--command-help args response))
              ("jump_to" (opennefia--command-jump-to args response))
              ("signature" (opennefia--command-signature response))
              ("apropos" (opennefia--command-apropos response))
              ("completion" (opennefia--command-completion response))
              ("template" (opennefia--command-template response))
              ("ids" (opennefia--command-ids args response))
              ("run" t)
              ("hotload" t)
              (else (error "No action for %s %s" cmd (prin1-to-string response)))))
        (error message)))))

;;
;; Commands
;;

(defun opennefia--start-of-help-buffer ()
  (let* ((str (buffer-string))
         (pos (string-match "^\n  " str)))
    (or (and pos (+ 1 pos))
        (save-excursion
          (beginning-of-buffer)
          (next-line 3)
          (point)))))

(defun opennefia--end-of-help-buffer ()
  (let ((str (buffer-string)))
    (or (string-match "\n= Parameters$" str)
        (string-match "\n= Returns$" str)
        (point-max))))

(defvar opennefia--help-buffer-font-lock-keywords
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

(define-button-type 'opennefia-file
  :supertype 'help-xref
  'help-function (lambda (file line)
                   (let ((path (string-join (list (projectile-project-root)
                                                  "src/"
                                                  file))))
                     (pop-to-buffer (find-file-noselect path))
                     (goto-line line)
                     (recenter)))
  'help-echo (purecopy "mouse-2, RET: find object's definition"))

(defvar opennefia--file-regexp "defined in '\\(.*?\\)' on line \\([0-9]+\\)")

(defun opennefia--format-help-buffer ()
  (save-excursion
    (beginning-of-buffer)
    (let ((paragraph-start "[ \t]*\n[ \t]*$\\|[ \t]*[-+*=] ")
          (fill-column 80)
          (start (opennefia--start-of-help-buffer))
          (end (opennefia--end-of-help-buffer))
          (inhibit-read-only t))
      (opennefia--fontify-region 'markdown-mode start end)
      (font-lock-add-keywords nil opennefia--help-buffer-font-lock-keywords)
      (font-lock-fontify-region (point-min) (point-max))
      (beginning-of-buffer)
      (next-line 3)
      (fill-region (point) (point-max))
      (beginning-of-buffer)
      (when (and (re-search-forward opennefia--file-regexp nil t)
                 (match-string 1))
        (help-xref-button 1 'opennefia-file (match-string 1) (string-to-number (match-string 2)))))))

(defvar opennefia--signature-font-lock-keywords
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

(defun opennefia--fontify-signature (str)
  (with-temp-buffer
    (insert str)
    (font-lock-add-keywords nil opennefia--signature-font-lock-keywords)
    (font-lock-fontify-region (point-min) (point-max))
    (buffer-string)))

(defun opennefia--command-help (args response)
  (-let (((&alist 'doc 'message) response)
         (buffer (get-buffer-create "*opennefia-help*")))
    (with-help-window buffer
      (princ doc)
      (with-current-buffer buffer
        (opennefia--format-help-buffer)))
    (message "%s" message)))

(defvar opennefia--is-completing nil)

(defun opennefia--command-completion (response)
  (when opennefia--is-completing
    (-let* (((&alist 'results 'prefix) response)
            (candidates (mapcar (lambda (item)
                                  (opennefia--make-completion-candidate item prefix))
                                results)))))
  (funcall opennefia--is-completing candidates)
  (setq opennefia--is-completing nil))

(defun opennefia--company-candidates (prefix callback)
  (message (prin1-to-string prefix))
  (when (opennefia--game-running-p)
    (progn
      (setq opennefia--is-completing callback)
      (opennefia--send "completion" prefix))))

;;;###autoload
(defun company-opennefia (command &optional arg &rest _)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend #'company-opennefia))
    (prefix (substring-no-properties (company-grab-symbol)))
    (candidates (cons :async (lambda (callback) (opennefia--company-candidates arg callback))))
    ;(annotation (opennefia--company-annotation arg))
    ;(quickhelp-string (opennefia--company-quickhelp-string arg))
    ;; (doc-buffer (company-doc-buffer "*opennefia-help*"))
    ))

(defun opennefia--command-jump-to (args response)
  (-let* (((&alist 'success 'file 'line 'column) response))
    (if file
        (let* ((loc (xref-make-file-location file line column))
               (marker (xref-location-marker loc))
               (buf (marker-buffer marker)))
          (xref-push-marker-stack)
          (switch-to-buffer buf)
          (xref--goto-char marker))
      (xref-find-definitions (strip-text-properties (plist-get :query args))))))

(defun opennefia--command-signature (response)
  (-let* (((&alist 'sig 'params 'summary) response))
    (when sig
      (setq opennefia--eldoc-saved-message
            (format "%s :: %s%s" sig params (or (and (not (string-blank-p summary))
                                                     (format "\n%s" summary))
                                                ""))
            opennefia--eldoc-saved-point (point))
      (opennefia--eldoc-message opennefia--eldoc-saved-message))))

(defvar opennefia--apropos-candidates nil)

(defun opennefia--apropos-file (path)
  (let ((base (if (opennefia--headless-mode-p)
                  (string-trim-right (temporary-file-directory) "/")
                (getenv "HOME")))
        (sep (if (eq system-type 'windows-nt) "\\" "/"))
        (dir
         (if (eq system-type 'windows-nt)
             "AppData\\Roaming\\LOVE"
           ".local/share/love")))
    (string-join (list base dir "OpenNefia" path) sep)))

(defun opennefia--command-apropos (response)
  (-let* (((&alist 'path 'updated) response)
          (items (or
                  (and (not updated) opennefia--apropos-candidates)
                  (json-read-file (opennefia--apropos-file path)))))
    (setq opennefia--apropos-candidates items)
    (let ((item (opennefia--completing-read "Apropos: " items)))
      (opennefia--send "help" item))))

(defun opennefia--command-template (response)
  (insert (alist-get 'template response)))

(defun opennefia--command-ids (type response)
  (let ((ids (alist-get 'ids response)))
    (insert
     (format "\"%s\""
             (completing-read (format "ID (%s): " type)
                              (append ids nil))))))

;;
;; Network
;;

(defun opennefia--tcp-sentinel (proc message)
  "Runs when a client closes the connection."
  (when (string-match-p "^open " message)
    (let ((buffer (process-buffer proc)))
      (when buffer
        (kill-buffer buffer)))))

(defun opennefia--make-tcp-connection (host port)
  (make-network-process :name "OpenNefia"
                        :buffer "*OpenNefia*"
                        :host host
                        :service port
                        :filter 'opennefia--tcp-filter
                        :sentinel 'opennefia--tcp-sentinel
                        :coding 'utf-8))

(defun opennefia--headless-mode-p ()
  (and (buffer-live-p lua-process-buffer)
       (get-buffer-process lua-process-buffer)))

(defun opennefia--send (cmd args)
  (let ((proc (opennefia--make-tcp-connection opennefia-repl-address opennefia-repl-port))
        (json (json-encode (list :command cmd :args args))))
    (when (process-live-p proc)
      (process-put proc :command cmd)
      (process-put proc :args args)
      (comint-send-string proc (format "%s\n" json))
      (process-send-eof proc)
      ;; In REPL mode, run the server for one step to ensure the
      ;; response is received (it's supposed to run every frame as
      ;; a coroutine in LOVE)
      (when (opennefia--headless-mode-p)
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

(defun opennefia--get-lua-result ()
  "Gets the last line of the current Lua buffer."
  (with-current-buffer lua-process-buffer
    (sleep-for 0 200)
    (goto-char (point-max))
    (forward-line -1)
    (let ((line (thing-at-point 'line t)))
      (substring line 2 (max 3 (- (length line) 1))))))

(defun opennefia--send-to-repl (str)
  (if (opennefia--headless-mode-p)
      (progn
        (lua-send-string str)
        (message (opennefia--get-lua-result)))
    (opennefia--send "run" (list :code (format "local success, err = require('api.Repl').send([[\n%s\n]]); if not success then error(err) end" str)))))

(defun opennefia-send-region (start end)
  (interactive "r")
  (setq start (lua-maybe-skip-shebang-line start))
  (let* ((lineno (line-number-at-pos start))
         (region-str (buffer-substring-no-properties start end)))
    (opennefia--send "run" (list :code region-str))))

(defun opennefia-send-buffer ()
  (interactive)
  (opennefia-send-region (point-min) (point-max)))

(defun opennefia-send-current-line ()
  (interactive)
  (opennefia-send-region (line-beginning-position) (line-end-position)))

(defun opennefia--bounds-of-last-defun (pos)
  (save-excursion
    (let ((start (if (save-match-data (looking-at "^function[ \t]"))
                     (point)
                   (lua-beginning-of-proc)
                   (point)))
          (end (progn (lua-end-of-proc) (point))))

      (if (and (>= pos start) (< pos end))
          (cons start end)
        (cons 0 1)))))

(defun opennefia--bounds-of-buffer ()
  (cons (point-min) (point-max)))

(defun opennefia--bounds-of-line ()
  (cons (point-at-bol) (point-at-eol)))

(defun opennefia-send-defun (pos)
  (interactive "d")
  (let ((bounds (opennefia--bounds-of-last-defun pos)))
    (opennefia-send-region (car bounds) (cdr bounds))))

(defun opennefia--require-path-of-file (file)
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

(defun opennefia-hotload-this-file ()
  (interactive)
  (if opennefia-always-send-to-repl
      (opennefia-eval-buffer)
    (let* ((lua-path (car (opennefia--require-path-of-file (buffer-file-name)))))
      (save-buffer)
      (opennefia--send "hotload" (list :require_path lua-path))
      (message "Hotloaded %s." lua-path))))

(defun opennefia-require-this-file ()
  (interactive)
  (let* ((pair (opennefia--require-path-of-file (buffer-file-name)))
         (lua-path (car pair))
         (lua-name (cdr pair))
         (cmd (format
               "%s = require(\"%s\")"
               lua-name
               lua-path)))
    (save-buffer)
    (opennefia--send-to-repl cmd)
    (message "%s" cmd)))

(defun opennefia--require-path (file)
  (let* ((pair (opennefia--require-path-of-file file))
         (lua-path (car pair))
         (lua-name (cdr pair))
         (local (if opennefia-always-send-to-repl "" "local ")))
    (format
     "%s%s = require(\"%s\")\n"
     local
     lua-name
     lua-path)))

(defun opennefia-copy-require-path ()
  (interactive)
  (let ((src (opennefia--require-path (buffer-file-name))))
    (message "%s" src)
    (kill-new src)))

(defun opennefia-insert-require-for-file (file)
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (beginning-of-line)
    (insert (opennefia--require-path
             (string-join (list project-root file))))
    (indent-region (point-at-bol) (point-at-eol))))

(defun opennefia--api-file-cands ()
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (-filter (lambda (f)
               (and (not (string-prefix-p "lib/" f))
                    (string-equal "lua" (file-name-extension f))))
             (projectile-project-files project-root))))

(defun opennefia-insert-require ()
  (interactive)
  (let* ((files (opennefia--api-file-cands))
         (file (projectile-completing-read "File: " files)))
    (when file
      (opennefia-insert-require-for-file file))))

(defun opennefia--extract-missing-api (flycheck-error)
  (let ((message (flycheck-error-message flycheck-error)))
    (when (string-match "accessing undefined variable '\\(.+\\)'" message)
      (match-string 1 message))))

(defun opennefia--api-name-to-path (api-name cands)
  (let* ((regexp (format "/%s\\(\\|/init\\).lua$" api-name))
         (case-fold-search nil)
         (filtered (-filter (lambda (f) (string-match-p regexp f)) cands)))
    (cl-case (length filtered)
      (0 nil)
      (1 (car filtered))
      (t (completing-read (format "Path for '%s': " api-name) filtered)))))

(defun opennefia-insert-missing-requires ()
  (interactive)
  (let* ((errors flycheck-current-errors)
         (apis (-uniq (-non-nil (-map 'opennefia--extract-missing-api errors))))
         (cands (opennefia--api-file-cands))
         (paths (-non-nil (-map (lambda (n) (opennefia--api-name-to-path n cands)) apis))))
    (save-excursion
      (beginning-of-buffer)
      (-each paths 'opennefia-insert-require-for-file)
      (save-buffer)
      (flycheck-buffer))))

(defun opennefia--extract-unused-api (flycheck-error)
  (let ((message (flycheck-error-message flycheck-error))
        (line (flycheck-error-line flycheck-error)))
    (when (string-match "unused variable '\\([A-Z][a-zA-Z]+\\)'" message)
      line)))

(defun opennefia-remove-unused-requires ()
  (interactive)
  (let* ((errors flycheck-current-errors)
         (lines (sort (-non-nil (-map 'opennefia--extract-unused-api errors)) '>))
         (kill-whole-line t))
    (save-excursion
      (-each lines
        (lambda (line)
          (goto-line line)
          (beginning-of-line)
          (kill-line)))
      (save-buffer)
      (flycheck-buffer))))

(defvar opennefia--eval-expression-history '())

(defun opennefia-eval-expression (exp)
  (interactive
   (list
    (read-from-minibuffer "Eval (lua): " nil nil nil 'opennefia--eval-expression-history)))
  (opennefia--send-to-repl exp))

(defun opennefia-eval-region (start end)
  (interactive "r")
  (opennefia--send-to-repl (buffer-substring start end)))

(defun opennefia-eval-buffer ()
  (interactive)
  (opennefia--send-to-repl (buffer-string)))

(defun opennefia-eval-current-line ()
  (interactive)
  (opennefia-eval-region (line-beginning-position) (line-end-position)))

(defun opennefia--bounds-of-block ()
  (save-excursion
    (let* ((start
           (save-excursion
             (while (and (not (bobp)) (> (lua-calculate-indentation) 0))
               (previous-line))
             (beginning-of-line)
             (point)))
          (end
           (save-excursion
             (goto-char start)
             (next-line)
             (while (and (not (eobp)) (> (lua-calculate-indentation) 0))
               (next-line))
             (end-of-line)
             (point))))
      (cons start end))))

(defun opennefia-eval-block ()
  (interactive)
  (let ((pos (opennefia--bounds-of-block)))
    (opennefia-eval-region (car pos) (cdr pos))))

(defun opennefia--dotted-symbol-at-point ()
  (interactive)
  (with-syntax-table (copy-syntax-table)
    (modify-syntax-entry ?. "_")
    (string-trim
     (symbol-name
      (symbol-at-point))
     "[.:]" "[.:]")))

(defun opennefia-describe-thing-at-point (arg)
  (interactive "P")
  (let ((sym (if arg
                 (symbol-name (symbol-at-point))
               (opennefia--dotted-symbol-at-point))))
    (opennefia--send "help" (list :query sym))))

(defun opennefia-jump-to-definition (arg)
  (interactive "P")
  (if (opennefia--game-running-p)
      (let* ((sym (if arg
                      (symbol-name (symbol-at-point))
                    (opennefia--dotted-symbol-at-point)))
             (result (if (string-equal sym "nil")
                         (opennefia--completing-read
                          "Jump to: "
                          (json-read-file (opennefia--apropos-file "data/apropos.json")))
                       sym)))
        (opennefia--send "jump_to" (list :query result)))
    (xref-find-definitions (opennefia--dotted-symbol-at-point))))

(defun opennefia-describe-apropos ()
  (interactive)
  (opennefia--send "apropos" '()))

(defun opennefia-eval-sexp-fu-setup ()
  (define-eval-sexp-fu-flash-command opennefia-send-defun
    (eval-sexp-fu-flash (opennefia--bounds-of-last-defun (point))))
  (define-eval-sexp-fu-flash-command opennefia-hotload-this-file
    (eval-sexp-fu-flash (opennefia--bounds-of-buffer)))
  (define-eval-sexp-fu-flash-command opennefia-require-this-file
    (eval-sexp-fu-flash (opennefia--bounds-of-buffer)))
  (define-eval-sexp-fu-flash-command opennefia-send-current-line
    (eval-sexp-fu-flash (opennefia--bounds-of-line)))

  (define-eval-sexp-fu-flash-command opennefia-eval-block
    (eval-sexp-fu-flash (opennefia--bounds-of-block)))
  (define-eval-sexp-fu-flash-command opennefia-eval-current-line
    (eval-sexp-fu-flash (opennefia--bounds-of-line)))

  (define-eval-sexp-fu-flash-command lua-send-buffer
    (eval-sexp-fu-flash (opennefia--bounds-of-buffer))))

(defvar opennefia--repl-errors-buffer "*opennefia-repl-errors*")
(defvar opennefia--repl-name "opennefia-repl")

(defun opennefia--repl-file ()
  (string-join (list (projectile-project-root) "src/repl.lua")))

(defun opennefia--test-repl ()
  (with-current-buffer (get-buffer-create opennefia--repl-errors-buffer)
    (erase-buffer)
    (apply 'call-process "luajit" nil
           (current-buffer)
           nil
           (list (opennefia--repl-file) "test"))))

(defun opennefia-start-repl (&optional arg)
  (interactive "P")
  (let* ((buffer-name (string-join (list "*" opennefia--repl-name "*")))
         (buffer (get-buffer buffer-name))
         (default-directory (file-name-directory (directory-file-name (opennefia--repl-file))))
         (switch (or (and arg "load") "")))
    (when-let ((buf (get-buffer opennefia--repl-errors-buffer))
               (dir default-directory))
      (with-current-buffer buf
        (setq-local default-directory dir)))
    (if (and (buffer-live-p buffer) (process-live-p (get-buffer-process buffer)))
        (progn
          (setq next-error-last-buffer (get-buffer buffer-name))
          (pop-to-buffer buffer)
          (comint-goto-process-mark))
      (let ((result (opennefia--test-repl)))
        (if (eq result 0)
            (progn
              (run-lua opennefia--repl-name "luajit" nil (opennefia--repl-file) switch)
              (setq next-error-last-buffer (get-buffer buffer-name))
              (pop-to-buffer buffer-name)
              (setq-local company-backends '(company-etags)))
          (progn
            (with-current-buffer opennefia--repl-errors-buffer
              (ansi-color-apply-on-region (point-min) (point-max)))
            (pop-to-buffer opennefia--repl-errors-buffer)
            (error "REPL startup failed with code %s." result)))))))

(defun opennefia-run-batch-script ()
  (interactive)
  (compile (format "%s repl.lua batch %s" lua-default-application (buffer-file-name))))

(defun opennefia-insert-template ()
  (interactive)
  (opennefia--send "template" '()))

(defun opennefia-insert-id ()
  (interactive)
  (opennefia--send "ids" '()))

(defun opennefia-make-scratch-buffer ()
  (interactive)
  (let* ((filename (format-time-string "%Y-%m-%d_%H-%M-%S.lua"))
         (dest-path (string-join (list (projectile-project-root) "src/scratch/" filename))))
    (find-file dest-path)
    (newline)
    (setq opennefia-always-send-to-repl t)
    (add-file-local-variable 'opennefia-always-send-to-repl t)
    (beginning-of-buffer)))

(provide 'opennefia)
