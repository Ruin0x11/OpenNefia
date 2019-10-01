(require 'lua-mode)
(require 'eval-sexp-fu nil t)

(defvar elona-next-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-l" 'elona-next-send-buffer)
    map))

;;;###autoload
(define-minor-mode elona-next-minor-mode
  "Elona next debug server."
  :lighter " Elona" :keymap elona-next-minor-mode-map)

(defun elona-next--make-tcp-connection (host port)
  (make-network-process :name "elona next"
                        :buffer "*elona next*"
                        :host host
                        :service port
                        :nowait t
                        :coding 'utf-8))

(defun elona-next--send (str)
  (when (buffer-live-p lua-process-buffer)
    (lua-send-string str))
  (let ((proc (elona-next--make-tcp-connection "127.0.0.1" 4567)))
    (comint-send-string proc str)
    (process-send-eof proc)
    (with-current-buffer (process-buffer proc)
      (buffer-string)))
  (when (not (or (get-buffer-window compilation-last-buffer) (get-buffer-window lua-process-buffer)))
    (let ((buf (if compilation-in-progress compilation-last-buffer lua-process-buffer)))
      (if (and (buffer-live-p buf) (not (get-buffer-window buf)))
          (popwin:display-buffer buf)))))

(defun elona-next-send-region (start end)
  (interactive "r")
  (setq start (lua-maybe-skip-shebang-line start))
  (let* ((lineno (line-number-at-pos start))
         (region-str (buffer-substring-no-properties start end)))
    (elona-next--send region-str)))

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

(defun elona-next-send-defun (pos)
  (interactive "d")
  (let ((bounds (elona-next--bounds-of-last-defun pos)))
    (elona-next-send-region (car pos) (cdr pos))))

(defun elona-next-hotload-this-file ()
  (interactive)
  (let* ((prefix
          (file-relative-name
           (file-name-sans-extension (buffer-file-name))
           (string-join (list (projectile-project-root) "src/"))))
         (lua-path (replace-regexp-in-string "/" "." prefix))
         (cmd (format
               "local ok, hotload = pcall(function() return require('hotload') end); if ok then hotload('%s') else require('internal.env').hotload('%s') end"
               lua-path
               lua-path)))
    (save-buffer)
    (elona-next--send cmd)
    (message "Hotloaded %s." lua-path)))

(defun elona-next-run-this-file ()
  (interactive)
  (lua-send-string (format "dofile \"%s\"" (buffer-file-name))))

(defun elona-next-eval-sexp-fu-setup ()
  (define-eval-sexp-fu-flash-command elona-next-send-defun
    (eval-sexp-fu-flash (elona-next--bounds-of-last-defun (point))))
  (define-eval-sexp-fu-flash-command elona-next-hotload-this-file
    (eval-sexp-fu-flash (elona-next--bounds-of-buffer))))

(defvar elona-next--repl-errors-buffer "*elona-next-repl-errors*")
(defvar elona-next--repl-name "elona-next-repl")

(defun elona-next--repl-file ()
(string-join (list (projectile-project-root) "src/repl.lua")))

(defun elona-next--test-repl ()
  (with-current-buffer (get-buffer-create elona-next--repl-errors-buffer)
    (delete-region (point-min) (point-max))
      (let ((result (apply 'call-process "luajit" nil
                           (current-buffer)
                           nil
                           (list (elona-next--repl-file) "test"))))
        (equal 0 result))))

(defun elona-next-start-repl ()
  (interactive)
  (let* ((buffer-name (string-join (list "*" elona-next--repl-name "*")))
         (buffer (get-buffer buffer-name))
         (default-directory (file-name-directory (directory-file-name (elona-next--repl-file)))))
    (if (and (buffer-live-p buffer) (process-live-p (get-buffer-process buffer)))
        (progn
          (setq next-error-last-buffer (get-buffer buffer-name))
          (pop-to-buffer buffer)
          (comint-goto-process-mark))
      (if (elona-next--test-repl)
          (progn
            (run-lua elona-next--repl-name "luajit" nil (elona-next--repl-file))
            (setq next-error-last-buffer (get-buffer buffer-name))
            (pop-to-buffer buffer-name))
        (progn
          (pop-to-buffer elona-next--repl-errors-buffer)
          (error "REPL startup failed."))))))

(provide 'elona-next)
