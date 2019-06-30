(require 'lua-mode)
(require 'eval-sexp-fu nil t)

(defvar elona-next-minor-mode-map
  (let ((map (make-sparse-keymap)))
    ;(define-key map "\M-:"  'elona-next-eval-expression)
    ;(define-key map "\M-\C-x"  'elona-next-eval-defun)
    ;(define-key map "\C-x\C-e" 'elona-next-eval-last-sexp)
    ;(define-key map "\C-c\C-e" 'elona-next-eval-defun)
    ;(define-key map "\C-c\C-r" 'elona-next-eval-region)
    ;(define-key map "\C-c\C-n" 'elona-next-eval-form-and-next)
    ;(define-key map "\C-c\C-p" 'elona-next-eval-paragraph)
    ;(define-key map "\C-c\C-s" 'elona-next-connect)
    (define-key map "\C-c\C-l" 'elona-next-send-buffer)
    ;(define-key map "\C-c\C-d" 'elona-next-describe-sym)
    ;(define-key map "\C-c\C-f" 'elona-next-show-function-documentation)
    ;(define-key map "\C-c\C-v" 'elona-next-show-variable-documentation)
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
  (let ((proc (elona-next--make-tcp-connection "127.0.0.1" 4567)))
    (comint-send-string proc str)
    (process-send-eof proc)
    (with-current-buffer (process-buffer proc)
      (buffer-string))))

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
           (concat (getenv "HOME") "/build/next/src/src")))
         (lua-path (replace-regexp-in-string "/" "." prefix)))
    (save-buffer)
    (elona-next--send (format "require('internal.env').hotload('%s')" lua-path))
    (message "Hotloaded %s." lua-path)))

(defun elona-next-eval-sexp-fu-setup ()
  (define-eval-sexp-fu-flash-command elona-next-send-defun
    (eval-sexp-fu-flash (elona-next--bounds-of-last-defun (point))))
  (define-eval-sexp-fu-flash-command elona-next-hotload-this-file
    (eval-sexp-fu-flash (elona-next--bounds-of-buffer))))

(provide 'elona-next)
