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
    (process-send-eof proc)))

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

(defun elona-next-send-defun (pos)
  (interactive "d")
  (save-excursion
    (let ((start (if (save-match-data (looking-at "^function[ \t]"))
                     (point)
                   (elona-next-beginning-of-proc)
                   (point)))
          (end (progn (elona-next-end-of-proc) (point))))

      (if (and (>= pos start) (< pos end))
          (elona-next-send-region start end)
        (error "Not on a function definition")))))

(provide 'elona-next)
