;;; elona-custom-text-mode.el --- Major mode for editing Elona Custom Text files  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Ruin0x11

;; Author: Ruin0x11 <ipickering2@gmail.com>
;; Package-Requires: ((emacs "24"))

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

;;

;;; Code:

(require 'rx)

(defgroup elona-custom-text nil
  "elona-custom-text code editing commands for Emacs."
  :link '(custom-group-link :tag "Font Lock Faces group" font-lock-faces)
  :prefix "elona-custom-text-"
  :group 'languages)

(defcustom elona-custom-text-mode-hook nil
  "*Hook called by `elona-custom-text-mode'."
  :type 'hook
  :group 'elona-custom-text)

(defconst elona-custom-text--from-regex
  (rx "from " (group (+? nonl)) (or " " eol) (? "as " (group (1+ nonl)))))

(defvar elona-custom-text-font-lock-keywords
  `(("^\\(%\\)\\(txt[^,]*\\),\\(.*\\)"
     (1 font-lock-keyword-face)
     (2 font-lock-function-name-face)
     ;; (3 font-lock-constant-face)
     )
    ("%END" (0 font-lock-keyword-face))
    ("^.*$"
     (0 font-lock-string-face))
    ("\\({.*?}\\)"
     (1 font-lock-constant-face t))
    )
  "Default `font-lock-keywords' for `elona-custom-text mode'.")

(defvar elona-custom-text-mode-map
  (let ((map (make-sparse-keymap)))
    map))

(defvar elona-custom-text-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?/  ". 124b" table)
    (modify-syntax-entry ?\n "> b"    table)
    (modify-syntax-entry ?\^m "> b"   table)
    (modify-syntax-entry ?= "." table)
    table)
  "Syntax table for `elona-custom-text-mode'.")

(define-abbrev-table 'elona-custom-text-mode-abbrev-table nil
  "Abbrev table used while in `elona-custom-text-mode'.")

(unless elona-custom-text-mode-abbrev-table
  (define-abbrev-table 'elona-custom-text-mode-abbrev-table ()))

(defun elona-custom-text-indent-line-function ()
  "Indent lines in a Elona-Custom-Text.

Lines beginning with a keyword are ignored, and any others are
indented by one `tab-width'."
  (unless (member (get-text-property (point-at-bol) 'face)
                  '(font-lock-comment-delimiter-face font-lock-keyword-face))
    (save-excursion
      (beginning-of-line)
      (skip-chars-forward "[ \t]" (point-at-eol))
      (unless (equal (point) (point-at-eol)) ; Ignore empty lines.
        ;; Delete existing whitespace.
        (delete-char (- (point-at-bol) (point)))
        (indent-to tab-width)))))

;;;###autoload
(define-derived-mode elona-custom-text-mode prog-mode "Elona Custom Text"
  "A major mode to edit Elona-Custom-Texts.
\\{elona-custom-text-mode-map}
"
  (set-syntax-table elona-custom-text-mode-syntax-table)
  (set (make-local-variable 'imenu-generic-expression)
       `(("Stage" elona-custom-text--imenu-function 1)))
  (set (make-local-variable 'require-final-newline) mode-require-final-newline)
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-start-skip) "//+ *")
  (set (make-local-variable 'parse-sexp-ignore-comments) t)
  (set (make-local-variable 'font-lock-defaults)
       '(elona-custom-text-font-lock-keywords nil t))
  (setq local-abbrev-table elona-custom-text-mode-abbrev-table)
  (set (make-local-variable 'indent-line-function) #'elona-custom-text-indent-line-function))

(provide 'elona-custom-text-mode)

;; elona-custom-text-mode.el ends here
