;;; open-nefia.el --- Emacs integration with OpenNefia  -*- lexical-binding: t; -*-

;; Copyright (C) 2019-2021  Ruin0x11

;; Author: Ruin0x11 <ipickering2@gmail.com>
;; Keywords: processes, tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A library that lets you interface with OpenNefia's debug server.

;;; Code:

(provide 'open-nefia)
;;; open-nefia.el ends here

(require 'lua-mode)
(require 'eval-sexp-fu nil t)
(require 'json)
(require 'dash)
(require 'company)
(require 'cl)
(require 'flycheck)
(require 'markdown-mode)
(require 'help-mode)

(defvar open-nefia-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-l" 'open-nefia-send-buffer)
    map))

(defvar-local open-nefia-always-send-to-repl nil
  "If non-nil, treat hotloading as evaluating the buffer in the REPL instead.")

(defcustom open-nefia-repl-address "127.0.0.1"
  "Address to use for connecting to the REPL.")

(defcustom open-nefia-repl-port 4567
  "Port to use for connecting to the REPL.")

;;;###autoload
(define-minor-mode open-nefia-minor-mode
  "Elona next debug server."
  :lighter " Open-Nefia" :keymap open-nefia-minor-mode-map)

(defun open-nefia--parse-response ()
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

(defun open-nefia--tcp-filter (proc chunk)
  (with-current-buffer (process-buffer proc)
    (goto-char (point-max))
    (insert chunk)
    (let ((response (process-get proc :response)))
      (unless response
        (when (setf response (open-nefia--parse-response))
          (delete-region (point-min) (point))
          (process-put proc :response response)))))
  (when-let ((response (process-get proc :response)))
    (with-current-buffer (process-buffer proc)
      (erase-buffer))
    (process-put proc :response nil)
    (with-demoted-errors "Error: %s"
        (open-nefia--process-response
         (process-get proc :command)
         (process-get proc :args)
         response))))

(defcustom open-nefia-completion-package 'ivy "Completion backend to use.")

(cl-defun open-nefia--do-completing-read (prompt cands &key prefix require-match caller)
  (interactive)
  (cond
   ((and (fboundp 'ivy-read) (eq open-nefia-completion-package 'ivy))
    (ivy-read prompt cands
              :caller caller
              :require-match require-match))
   (t (completing-read prompt cands prefix require-match))))

(defun open-nefia--completing-read (prompt list)
  (let ((cands (mapcar (lambda (c)
                         (cond
                          ((stringp c) c)
                          (t (append c nil))))
                       (append list nil))))
    (open-nefia--do-completing-read prompt cands :require-match t)))

(defun open-nefia--fontify-region (mode beg end)
  (let ((prev-mode major-mode))
    (delay-mode-hooks (funcall mode))
    (font-lock-default-function mode)
    (font-lock-default-fontify-region beg end nil)
    ;(delay-mode-hooks (funcall prev-mode))
    ))

(defun open-nefia--fontify-str (str mode)
  (with-temp-buffer
    (insert str)
    (open-nefia--fontify-region mode (point-min) (point-max))
    (buffer-string)))

(defvar open-nefia--eldoc-saved-message nil)
(defvar open-nefia--eldoc-saved-point nil)

(defun open-nefia--eldoc-message (&optional msg)
  (run-with-idle-timer 0 nil (lambda () (eldoc-message open-nefia--eldoc-saved-message))))

(defun open-nefia--eldoc-get ()
  (ignore-errors
    (let ((sym (open-nefia--dotted-symbol-at-point)))
      (if (and (not (string-empty-p sym))
               (open-nefia--game-running-p)
               (not (string-equal sym "nil")))
          (open-nefia--send "signature" sym))))
  eldoc-last-message)

(defun open-nefia-eldoc-function ()
  (if (and open-nefia--eldoc-saved-message
           (equal open-nefia--eldoc-saved-point (point)))
      open-nefia--eldoc-saved-message

    (setq open-nefia--eldoc-saved-message nil
          open-nefia--eldoc-saved-point nil)
    (open-nefia--eldoc-get)
    (let* ((sym-dotted (open-nefia--dotted-symbol-at-point))
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

(defun open-nefia--game-running-p ()
  (or
   (and (buffer-live-p lua-process-buffer) (get-buffer-process lua-process-buffer))
   (and compilation-in-progress)))

(defun open-nefia--process-response (cmd args response)
  (with-demoted-errors "Error: %s"
    (-let (((&alist 'success 'candidates 'message) response))
      (if (eq success t)
          (if candidates
              ; in pairs of ("api.Api.name", "api.api.name")
              (let* ((cand (open-nefia--completing-read "Candidate: " (append candidates nil)))
                     (args (pcase cmd
                             ("help" (list :query cand))
                             ("ids" (list :type cand))
                             ("template" (list :type cand))
                             ("hotload" (list :require_path cand))
                             (else (error "Candidates not supported for %s" cmd)))))
                (open-nefia--send cmd args))
            (pcase cmd
              ("help" (open-nefia--command-help args response))
              ("jump_to" (open-nefia--command-jump-to args response))
              ("signature" (open-nefia--command-signature response))
              ("apropos" (open-nefia--command-apropos response))
              ("completion" (open-nefia--command-completion response))
              ("template" (open-nefia--command-template response))
              ("ids" (open-nefia--command-ids args response))
              ("locale_search" (open-nefia--command-locale-search response))
              ("locale_key_search" (open-nefia--command-locale-key-search response))
              ("run" t)
              ("hotload" t)
              (else (error "No action for %s %s" cmd (prin1-to-string response)))))
        (error message)))))

;;
;; Commands
;;

(defun open-nefia--start-of-help-buffer ()
  (let* ((str (buffer-string))
         (pos (string-match "^\n  " str)))
    (or (and pos (+ 1 pos))
        (save-excursion
          (beginning-of-buffer)
          (next-line 3)
          (point)))))

(defun open-nefia--end-of-help-buffer ()
  (let ((str (buffer-string)))
    (or (string-match "\n= Parameters$" str)
        (string-match "\n= Returns$" str)
        (point-max))))

(defvar open-nefia--help-buffer-font-lock-keywords
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

(define-button-type 'open-nefia-file
  :supertype 'help-xref
  'help-function (lambda (file line)
                   (let ((path (string-join (list (projectile-project-root)
                                                  "src/"
                                                  file))))
                     (pop-to-buffer (find-file-noselect path))
                     (goto-line line)
                     (recenter)))
  'help-echo (purecopy "mouse-2, RET: find object's definition"))

(defvar open-nefia--file-regexp "defined in '\\(.*?\\)' on line \\([0-9]+\\)")

(defun open-nefia--format-help-buffer ()
  (save-excursion
    (beginning-of-buffer)
    (let ((paragraph-start "[ \t]*\n[ \t]*$\\|[ \t]*[-+*=] ")
          (fill-column 80)
          (start (open-nefia--start-of-help-buffer))
          (end (open-nefia--end-of-help-buffer))
          (inhibit-read-only t))
      (open-nefia--fontify-region 'markdown-mode start end)
      (font-lock-add-keywords nil open-nefia--help-buffer-font-lock-keywords)
      (font-lock-fontify-region (point-min) (point-max))
      (beginning-of-buffer)
      (next-line 3)
      (fill-region (point) (point-max))
      (beginning-of-buffer)
      (when (and (re-search-forward open-nefia--file-regexp nil t)
                 (match-string 1))
        (help-xref-button 1 'open-nefia-file (match-string 1) (string-to-number (match-string 2)))))))

(defvar open-nefia--signature-font-lock-keywords
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

(defun open-nefia--fontify-signature (str)
  (with-temp-buffer
    (insert str)
    (font-lock-add-keywords nil open-nefia--signature-font-lock-keywords)
    (font-lock-fontify-region (point-min) (point-max))
    (buffer-string)))

(defun open-nefia--command-help (args response)
  (-let (((&alist 'doc 'message) response)
         (buffer (get-buffer-create "*open-nefia-help*")))
    (with-help-window buffer
      (princ doc)
      (with-current-buffer buffer
        (open-nefia--format-help-buffer)))
    (message "%s" message)))

(defvar open-nefia--is-completing nil)

(defun open-nefia--command-completion (response)
  (when open-nefia--is-completing
    (-let* (((&alist 'results 'prefix) response)
            (candidates (mapcar (lambda (item)
                                  (open-nefia--make-completion-candidate item prefix))
                                results)))))
  (funcall open-nefia--is-completing candidates)
  (setq open-nefia--is-completing nil))

(defun open-nefia--company-candidates (prefix callback)
  (message (prin1-to-string prefix))
  (when (open-nefia--game-running-p)
    (progn
      (setq open-nefia--is-completing callback)
      (open-nefia--send "completion" prefix))))

;;;###autoload
(defun company-open-nefia (command &optional arg &rest _)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend #'company-open-nefia))
    (prefix (substring-no-properties (company-grab-symbol)))
    (candidates (cons :async (lambda (callback) (open-nefia--company-candidates arg callback))))
    ;(annotation (open-nefia--company-annotation arg))
    ;(quickhelp-string (open-nefia--company-quickhelp-string arg))
    ;; (doc-buffer (company-doc-buffer "*open-nefia-help*"))
    ))

(defun open-nefia--command-jump-to (args response)
  (-let* (((&alist 'success 'file 'line 'column) response))
    (if file
        (let* ((loc (xref-make-file-location file line column))
               (marker (xref-location-marker loc))
               (buf (marker-buffer marker)))
          (xref-push-marker-stack)
          (switch-to-buffer buf)
          (xref--goto-char marker))
      (xref-find-definitions (strip-text-properties (plist-get :query args))))))

(defun open-nefia--command-signature (response)
  (-let* (((&alist 'sig 'params 'summary) response))
    (when sig
      (setq open-nefia--eldoc-saved-message
            (format "%s :: %s%s" sig params (or (and (not (string-blank-p summary))
                                                     (format "\n%s" summary))
                                                ""))
            open-nefia--eldoc-saved-point (point))
      (open-nefia--eldoc-message open-nefia--eldoc-saved-message))))

(defvar open-nefia--apropos-candidates nil)

(defun open-nefia--apropos-file (path)
  (let ((base (if (open-nefia--headless-mode-p)
                  (string-trim-right (temporary-file-directory) "/")
                (getenv "HOME")))
        (sep (if (eq system-type 'windows-nt) "\\" "/"))
        (dir
         (if (eq system-type 'windows-nt)
             "AppData\\Roaming\\LOVE"
           ".local/share/love")))
    (string-join (list base dir "Open-Nefia" path) sep)))

(defun open-nefia--command-apropos (response)
  (-let* (((&alist 'path 'updated) response)
          (items (or
                  (and (not updated) open-nefia--apropos-candidates)
                  (json-read-file (open-nefia--apropos-file path)))))
    (setq open-nefia--apropos-candidates items)
    (let ((item (open-nefia--completing-read "Apropos: " items)))
      (open-nefia--send "help" item))))

(defvar open-nefia--locale-search-table nil)

(defun open-nefia--command-locale-search-transformer (id)
  (let ((text (gethash id open-nefia--locale-search-table)))
    (concat (propertize (format "\"%s\"" text) 'face 'font-lock-string-face)
            (format " (%s)" id))))

(defun open-nefia--command-locale-search (response)
  (let ((items (append (alist-get 'results response) nil)))
    (setq open-nefia--locale-search-table (make-hash-table))
    (mapc (lambda (i)
            (puthash (aref i 0) (aref i 1) open-nefia--locale-search-table))
          items)
    (let* ((cands (mapcar (lambda (i) (aref i 0)) items))
           (result (open-nefia--do-completing-read "Candidate: " cands
                                                   :require-match t
                                                   :caller 'open-nefia--command-locale-search)))
      (insert (format "\"%s\"" result)))))

(defun open-nefia--command-locale-key-search-transformer (id)
  (let ((text (gethash id open-nefia--locale-search-table)))
    (concat (format "%s" id)
            (propertize (format " (\"%s\")" text) 'face 'font-lock-string-face))))

(defun open-nefia--command-locale-key-search (response)
  (let ((items (append (alist-get 'results response) nil)))
    (setq open-nefia--locale-search-table (make-hash-table))
    (mapc (lambda (i)
            (puthash (aref i 1) (aref i 0) open-nefia--locale-search-table))
          items)
    (let* ((cands (mapcar (lambda (i) (aref i 1)) items))
           (result (open-nefia--do-completing-read "Candidate: " cands
                                                   :require-match t
                                                   :caller 'open-nefia--command-locale-key-search)))
      (insert (format "\"%s\"" result)))))

(when (require 'ivy nil t)
  (if (fboundp 'ivy-configure)
      (ivy-configure 'open-nefia--command-locale-search
        :display-transformer-fn #'open-nefia--command-locale-search-transformer)
      (ivy-configure 'open-nefia--command-locale-key-search
        :display-transformer-fn #'open-nefia--command-locale-key-search-transformer)))

(defun open-nefia--unbracket-string (pre post string)
  "Remove PRE/POST from the beginning/end of STRING.
Both PRE and POST must be pre-/suffixes of STRING, or neither is
removed.  Return the new string.  If STRING is nil, return nil."
  (declare (indent 2))
  (and string
       (if (and (string-prefix-p pre string)
		(string-suffix-p post string))
	   (substring string (length pre) (- (length post)))
	 string)))

(defsubst open-nefia--escape-string (str)
  "Escape quotes and newlines in STR."
  (replace-regexp-in-string
   "\n" "\\\\n"
   (replace-regexp-in-string
    "\"" "\\\\\""
    (replace-regexp-in-string
     "'" "\\\\'" str))))

(defsubst open-nefia--unescape-string (str)
  "Unescape escaped commas, semicolons and newlines in STR."
  (open-nefia--unbracket-string "'" "'"
    (replace-regexp-in-string
     "\\\\n" "\n"
     (replace-regexp-in-string
      "\\\\\\([,;]\\)" "\\1" str))))

(defun open-nefia--command-template (response)
  (insert (open-nefia--unescape-string (alist-get 'template response))))

(defun open-nefia--command-ids (type response)
  (let ((ids (alist-get 'ids response)))
    (insert
     (format "\"%s\""
             (completing-read (format "ID (%s): " type)
                              (append ids nil))))))

;;
;; Network
;;

(defun open-nefia--tcp-sentinel (proc message)
  "Runs when a client closes the connection."
  (when (string-match-p "^open " message)
    (let ((buffer (process-buffer proc)))
      (when buffer
        (kill-buffer buffer)))))

(defun open-nefia--make-tcp-connection (host port)
  (make-network-process :name "Open-Nefia"
                        :buffer "*Open-Nefia*"
                        :host host
                        :service port
                        :filter 'open-nefia--tcp-filter
                        :sentinel 'open-nefia--tcp-sentinel
                        :coding 'utf-8))

(defun open-nefia--headless-mode-p ()
  (and (buffer-live-p lua-process-buffer)
       (get-buffer-process lua-process-buffer)))

(defun open-nefia--send (cmd args)
  (let ((proc (open-nefia--make-tcp-connection open-nefia-repl-address open-nefia-repl-port))
        (json (json-encode (list :command cmd :args args))))
    (when (process-live-p proc)
      (process-put proc :command cmd)
      (process-put proc :args args)
      (comint-send-string proc (format "%s\n" json))
      (process-send-eof proc)
      ;; In REPL mode, run the server for one step to ensure the
      ;; response is received (it's supposed to run every frame as
      ;; a coroutine in LOVE)
      (when (open-nefia--headless-mode-p)
        (lua-send-string "require('internal.elona_repl').step_server()"))))

  ;; Show the REPL if we're executing code.
  (when (string-equal cmd "run")
    (let ((win (get-buffer-window lua-process-buffer))
          (compilation-win (get-buffer-window compilation-last-buffer))
          (buf (if compilation-in-progress
                   (if (buffer-live-p compilation-last-buffer)
                       compilation-last-buffer
                     (get-buffer "*compilation*"))
                 lua-process-buffer)))
      ;; (when (not (or (and compilation-win (window-live-p win)) (and lua-process-buffer win (window-live-p win))))
      ;;   (when (and (buffer-live-p buf) (not (window-live-p (get-buffer-window buf))))
      ;;     (popwin:popup-buffer buf :stick t :noselect t :height 0.3)))
      (if-let ((win (get-buffer-window buf)))
          (save-excursion
            (with-selected-window win
              (end-of-buffer)))))))

(defun open-nefia--get-lua-result ()
  "Gets the last line of the current Lua buffer."
  (with-current-buffer lua-process-buffer
    (sleep-for 0 200)
    (goto-char (point-max))
    (forward-line -1)
    (let ((line (thing-at-point 'line t)))
      (substring line 2 (max 3 (- (length line) 1))))))

(defun open-nefia--send-to-repl (str)
  (if (open-nefia--headless-mode-p)
      (progn
        (lua-send-string str)
        (message (open-nefia--get-lua-result)))
    (open-nefia--send "run" (list :code (format "local success, err = require('api.Repl').send(\"%s\"); if not success then error(err) end" (open-nefia--escape-string str))))))

(defun open-nefia-send-region (start end)
  (interactive "r")
  (setq start (lua-maybe-skip-shebang-line start))
  (let* ((lineno (line-number-at-pos start))
         (region-str (buffer-substring-no-properties start end)))
    (open-nefia--send-to-repl region-str)))

(defun open-nefia-send-buffer ()
  (interactive)
  (open-nefia-send-region (point-min) (point-max)))

(defun open-nefia-send-current-line ()
  (interactive)
  (open-nefia-send-region (line-beginning-position) (line-end-position)))

(defun open-nefia--bounds-of-last-defun (pos)
  (save-excursion
    (let ((start (if (save-match-data (looking-at "^function[ \t]"))
                     (point)
                   (lua-beginning-of-proc)
                   (point)))
          (end (progn (lua-end-of-proc) (point))))

      (if (and (>= pos start) (< pos end))
          (cons start end)
        (cons 0 1)))))

(defun open-nefia--bounds-of-buffer ()
  (cons (point-min) (point-max)))

(defun open-nefia--bounds-of-line ()
  (cons (point-at-bol) (point-at-eol)))

(defun open-nefia-send-defun (pos)
  (interactive "d")
  (let ((bounds (open-nefia--bounds-of-last-defun pos)))
    (open-nefia-send-region (car bounds) (cdr bounds))))

(defun open-nefia--require-path-of-file (file)
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

(defun open-nefia-hotload-this-file ()
  (interactive)
  (if open-nefia-always-send-to-repl
      (open-nefia-eval-buffer)
    (let* ((lua-path (car (open-nefia--require-path-of-file (buffer-file-name)))))
      (save-buffer)
      (open-nefia--send "hotload" (list :require_path lua-path))
      (message "Hotloaded %s." lua-path))))

(defun open-nefia--require-file (file)
  (let* ((pair (open-nefia--require-path-of-file file))
         (lua-path (car pair))
         (lua-name (cdr pair))
         (cmd (format
               "%s = require(\"%s\")"
               lua-name
               lua-path)))
    (save-buffer)
    (open-nefia--send-to-repl cmd)
    (message "%s" cmd)))

(defun open-nefia-require-this-file ()
  (interactive)
  (open-nefia--require-file (buffer-file-name)))

(defun open-nefia-require-file ()
  (interactive)
  (let* ((files (open-nefia--api-file-cands))
         (file (projectile-completing-read "File: " files)))
    (when file
      (open-nefia--require-file
       (string-join (list (projectile-project-root) file))))))

(defun open-nefia--require-path (file)
  (let* ((pair (open-nefia--require-path-of-file file))
         (lua-path (car pair))
         (lua-name (cdr pair))
         (local (if open-nefia-always-send-to-repl "" "local ")))
    (format
     "%s%s = require(\"%s\")\n"
     local
     lua-name
     lua-path)))

(defun open-nefia-copy-require-path ()
  (interactive)
  (let ((src (open-nefia--require-path (buffer-file-name))))
    (message "%s" src)
    (kill-new src)))

(defun open-nefia-insert-require-for-file (file)
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (beginning-of-line)
    (insert (open-nefia--require-path
             (string-join (list project-root file))))
    (indent-region (point-at-bol) (point-at-eol))))

(defun open-nefia--api-dir-cands (&optional mod-name)
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (-filter (lambda (f)
               (and (or
                     (string-prefix-p "src/api" f)
                     (string-prefix-p "src/mod" f)
                     (string-prefix-p "src/internal" f))
                    (if mod-name (string-match-p (format "^src/mod/%s/" mod-name) f) t)))
             (projectile-project-dirs project-root))))

(defun open-nefia--api-file-cands (&optional mod-name)
  (let ((project-root (projectile-ensure-project (projectile-project-root))))
    (-filter (lambda (f)
               (and (not (string-prefix-p "lib/" f))
                    (string-equal "lua" (file-name-extension f))
                    (if mod-name (string-match-p (format "^src/mod/%s/" mod-name) f) t)))
             (projectile-project-files project-root))))

(defun open-nefia-insert-require ()
  (interactive)
  (let* ((files (open-nefia--api-file-cands))
         (file (projectile-completing-read "File: " files)))
    (when file
      (open-nefia-insert-require-for-file file))))

(defun open-nefia--extract-missing-api (flycheck-error)
  (let ((message (flycheck-error-message flycheck-error)))
    (when (string-match "accessing undefined variable '\\(.+\\)'" message)
      (match-string 1 message))))

(defun open-nefia--api-name-to-path (api-name cands &optional mod-name)
  (let* ((regexp (format "/%s\\(\\|/init\\).lua$" api-name))
         (case-fold-search nil)
         (filter (lambda (f)
                   (and (string-match-p regexp f)
                        (not (string-match-p "src/test/" f))
                        (not (string-match-p "mod/.*/test/" f)))))
         (filtered (-filter filter cands)))
    (cl-case (length filtered)
      (0 (if (and (not mod-name) (string-match "\\(.+\\)_\\([a-zA-Z0-9]+\\)" api-name))
             (let ((mod-name (match-string 1 api-name))
                   (api-name (match-string 2 api-name))
                   (cands (open-nefia--api-file-cands mod-name)))
               (message api-name (prin1-to-string cands))
               ;(open-nefia--api-name-to-path api-name cands mod-name)
               nil)
             nil))
      (1 (car filtered))
      (t (completing-read (format "Path for '%s': " api-name) filtered)))))

(defun open-nefia-insert-missing-requires ()
  (interactive)
  (let* ((errors flycheck-current-errors)
         (apis (-uniq (-non-nil (-map 'open-nefia--extract-missing-api errors))))
         (cands (open-nefia--api-file-cands))
         (paths (-non-nil (-map (lambda (n) (open-nefia--api-name-to-path n cands)) apis))))
    (save-excursion
      (beginning-of-buffer)
      (forward-paragraph)
      (-each paths 'open-nefia-insert-require-for-file)
      (save-buffer)
      (flycheck-buffer))))

(defun open-nefia--extract-unused-api (flycheck-error)
  (let ((message (flycheck-error-message flycheck-error))
        (line (flycheck-error-line flycheck-error)))
    (when (string-match "unused variable '\\([A-Z][a-zA-Z]+\\)'" message)
      line)))

(defun open-nefia-remove-unused-requires ()
  (interactive)
  (let* ((errors flycheck-current-errors)
         (lines (sort (-non-nil (-map 'open-nefia--extract-unused-api errors)) '>))
         (kill-whole-line t))
    (save-excursion
      (-each lines
        (lambda (line)
          (goto-line line)
          (beginning-of-line)
          (kill-line)))
      (save-buffer)
      (flycheck-buffer))))

(defvar open-nefia--eval-expression-history '())

(defun open-nefia-eval-expression (exp)
  (interactive
   (list
    (read-from-minibuffer "Eval (lua): " nil nil nil 'open-nefia--eval-expression-history)))
  (open-nefia--send-to-repl exp))

(defun open-nefia-eval-region (start end)
  (interactive "r")
  (open-nefia--send-to-repl (buffer-substring start end)))

(defun open-nefia-eval-buffer ()
  (interactive)
  (open-nefia--send-to-repl (buffer-string)))

(defun open-nefia-eval-current-line ()
  (interactive)
  (open-nefia-eval-region (line-beginning-position) (line-end-position)))

(defun open-nefia--bounds-of-block ()
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

(defun open-nefia-eval-block ()
  (interactive)
  (let ((pos (open-nefia--bounds-of-block)))
    (open-nefia-eval-region (car pos) (cdr pos))))

(defun open-nefia--dotted-symbol-at-point ()
  (interactive)
  (with-syntax-table (copy-syntax-table)
    (modify-syntax-entry ?. "_")
    (string-trim
     (symbol-name
      (symbol-at-point))
     "[.:]" "[.:]")))

(defun open-nefia-describe-thing-at-point (arg)
  (interactive "P")
  (let ((sym (if arg
                 (symbol-name (symbol-at-point))
               (open-nefia--dotted-symbol-at-point))))
    (open-nefia--send "help" (list :query sym))))

(defun open-nefia-jump-to-definition (arg)
  (interactive "P")
  (if (open-nefia--game-running-p)
      (let* ((sym (if arg
                      (symbol-name (symbol-at-point))
                    (open-nefia--dotted-symbol-at-point)))
             (result (if (string-equal sym "nil")
                         (open-nefia--completing-read
                          "Jump to: "
                          (json-read-file (open-nefia--apropos-file "data/apropos.json")))
                       sym)))
        (open-nefia--send "jump_to" (list :query result)))
    (xref-find-definitions (open-nefia--dotted-symbol-at-point))))

(defun open-nefia-describe-apropos ()
  (interactive)
  (open-nefia--send "apropos" '()))

(defun open-nefia-eval-sexp-fu-setup ()
  (define-eval-sexp-fu-flash-command open-nefia-send-defun
    (eval-sexp-fu-flash (open-nefia--bounds-of-last-defun (point))))
  (define-eval-sexp-fu-flash-command open-nefia-hotload-this-file
    (eval-sexp-fu-flash (open-nefia--bounds-of-buffer)))
  (define-eval-sexp-fu-flash-command open-nefia-require-this-file
    (eval-sexp-fu-flash (open-nefia--bounds-of-buffer)))
  (define-eval-sexp-fu-flash-command open-nefia-send-current-line
    (eval-sexp-fu-flash (open-nefia--bounds-of-line)))

  (define-eval-sexp-fu-flash-command open-nefia-eval-block
    (eval-sexp-fu-flash (open-nefia--bounds-of-block)))
  (define-eval-sexp-fu-flash-command open-nefia-eval-current-line
    (eval-sexp-fu-flash (open-nefia--bounds-of-line)))

  (define-eval-sexp-fu-flash-command lua-send-buffer
    (eval-sexp-fu-flash (open-nefia--bounds-of-buffer))))

(defvar open-nefia--repl-errors-buffer "*open-nefia-repl-errors*")
(defvar open-nefia--repl-name "open-nefia-repl")
(defvar open-nefia--repl-entrypoint "src/opennefia.lua")

(defun open-nefia--executable-name ()
  (if (eq system-type 'windows-nt) "./OpenNefia.bat" "./OpenNefia"))

(defun open-nefia--lua-headless-executable-name ()
  (if (eq system-type 'windows-nt) "luajit.exe" "luajit"))

(defun open-nefia--repl-file (file)
  (string-join (list (projectile-project-root) file)))

(defun open-nefia--test-repl (file)
  (with-current-buffer (get-buffer-create open-nefia--repl-errors-buffer)
    (erase-buffer)
    (apply 'call-process (open-nefia--lua-headless-executable-name) nil
           (current-buffer)
           nil
           (list (open-nefia--repl-file file) "verify"))))

(defun open-nefia--repl-buffer-name ()
  (string-join (list "*" open-nefia--repl-name "*")))

(defun open-nefia--repl-buffer ()
  (get-buffer (open-nefia--repl-buffer-name)))

(defun open-nefia--run-lua (file switches)
  ;; Windows blocks the process I/O preventing the buffer from ever showing.
  (if (eq system-type 'windows-nt)
      (with-current-buffer (get-buffer-create (open-nefia--repl-buffer-name))
        (erase-buffer)
        (apply 'call-process (open-nefia--lua-headless-executable-name) nil
               (current-buffer)
               nil
               (append (list (open-nefia--repl-file file)) switches)))
    (apply 'run-lua (append (list open-nefia--repl-name
                                  (open-nefia--lua-headless-executable-name)
                                  nil
                                  (open-nefia--repl-file file))
                            switches))))

(defun open-nefia--start-repl-1 (file &rest switches)
  (save-some-buffers (not compilation-ask-about-save)
                     compilation-save-buffers-predicate)
  (let* ((buffer (open-nefia--repl-buffer))
         (default-directory (file-name-directory (directory-file-name (open-nefia--repl-file open-nefia--repl-entrypoint)))))
    (when-let ((buf (get-buffer open-nefia--repl-errors-buffer))
               (dir default-directory))
      (with-current-buffer buf
        (setq-local default-directory dir)))
    (if (and (buffer-live-p buffer) (process-live-p (get-buffer-process buffer)))
        (progn
          (setq next-error-last-buffer (open-nefia--repl-buffer))
          (pop-to-buffer buffer)
          (comint-goto-process-mark))
      (let ((result (open-nefia--test-repl file)))
        (if (eq result 0)
            (progn
              (open-nefia--run-lua  file switches)
              (setq next-error-last-buffer (open-nefia--repl-buffer))
              (pop-to-buffer (open-nefia--repl-buffer))
              (setq-local company-backends '(company-etags)))
          (progn
            (with-current-buffer open-nefia--repl-errors-buffer
              (ansi-color-apply-on-region (point-min) (point-max)))
            (pop-to-buffer open-nefia--repl-errors-buffer)
            (error "REPL startup failed with code %s." result)))))))

(defun open-nefia-start-repl (&optional arg)
  (interactive "P")
  (open-nefia--start-repl-1 open-nefia--repl-entrypoint "repl"))

(defvar open-nefia--previous-test-filter nil)

(defun open-nefia--run-tests (filter &optional arg)
  (if-let ((repl-buffer (open-nefia--repl-buffer)))
      (kill-buffer repl-buffer))
  (setq open-nefia--previous-test-filter filter)
  (apply
   #'open-nefia--start-repl-1
   (append
    (list open-nefia--repl-entrypoint "test" "-f" filter)
    (when arg '("-d")))))

(defun open-nefia-run-tests (&optional arg)
  (interactive "P")
  (open-nefia--run-tests ".*:.*:.*" arg))

(defun open-nefia-run-tests-this-file (&optional arg)
  (interactive "P")
  (let ((mod-id (open-nefia--containing-mod-id-this-file)))
    (open-nefia--run-tests
     (format "%s:%s:%s" mod-id (format "/%s.lua$" (file-name-base (buffer-file-name))) ".*") arg)))

(defun open-nefia-run-test-at-point (&optional arg)
  (interactive "P")
  (let ((mod-id (open-nefia--containing-mod-id-this-file))
        (func-at-point (which-function)))
    (if func-at-point
        (open-nefia--run-tests
         (format "%s:%s:%s" mod-id (format "/%s.lua$" (file-name-base (buffer-file-name))) (format "^%s$" func-at-point) arg))
      (message "No function at point."))))

(defun open-nefia-run-previous-tests (&optional arg)
  (interactive "P")
  (if open-nefia--previous-test-filter
      (open-nefia--run-tests open-nefia--previous-test-filter arg)
    (open-nefia-run-tests)))

(defun open-nefia-insert-template ()
  (interactive)
  (open-nefia--send "template" (list :type "")))

(defun open-nefia-insert-id ()
  (interactive)
  (open-nefia--send "ids" '()))

(defun open-nefia-make-scratch-buffer ()
  (interactive)
  (let* ((filename (format-time-string "%Y-%m-%d_%H-%M-%S.lua"))
         (dest-path (string-join (list (projectile-project-root) "src/scratch/" filename))))
    (find-file dest-path)
    (newline)
    (setq open-nefia-always-send-to-repl t)
    (add-file-local-variable 'open-nefia-always-send-to-repl t)
    (beginning-of-buffer)))

(defun open-nefia-run-headlessly (arg)
  (interactive "P")
  (let* ((path (file-relative-name
                (buffer-file-name)
                (string-join (list (projectile-project-root) "src"))))
         (script (open-nefia--executable-name))
         (cmd (format "%s exec %s %s" script path (if arg "-m" "")))
         (default-directory (projectile-project-root)))
    (compile cmd)))

(defun open-nefia-run-headlessly-repl (arg)
  (interactive "P")
  (let* ((path (file-relative-name
                (buffer-file-name)
                (string-join (list (projectile-project-root) "src"))))
         (script (open-nefia--executable-name))
         (cmd (format "%s exec %s -r %s" script path (if arg "-m" "")))
         (default-directory (projectile-project-root)))
    (compile cmd)))

(defun open-nefia-start-game ()
  (interactive)
  (let* ((cmd (open-nefia--executable-name))
         (default-directory (projectile-project-root)))
    (setq compilation-search-path (list nil "src"))
    (compile cmd)))

(defun open-nefia-reset-draw-layers ()
  (interactive)
  (open-nefia--send "run" (list :code "require('api.Input').back_to_field()")))

(defun open-nefia-locale-search (query)
  (interactive "sSearch localized strings: \n")
  (open-nefia--send "locale_search" (list :query query)))

(defun open-nefia-locale-key-search (query)
  (interactive "sSearch locale keys: \n")
  (open-nefia--send "locale_key_search" (list :query query)))

(defun open-nefia--containing-mod-id-this-file ()
  (let* ((path (file-relative-name
                (buffer-file-name)
                (string-join (list (projectile-project-root) "src")))))
    (if (string-match "^mod/\\([a-z0-9][a-z0-9_]+\\)/" path)
        (match-string 1 path)
      "@base@")))

(provide 'open-nefia)
