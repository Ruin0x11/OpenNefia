;;; open-nefia-context.el --- Display context of regions of ported code  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Ruin0x11

;; Author: Ruin0x11 <ipickering2@gmail.com>
;; Keywords: tools

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

;; This will highlight the regions that look like ">>>>>>>> shade2/file.hsp:100"
;; in the source, and let you jump directly to the place in the code they're
;; ported from. It greatly helps for not getting lost if some part of the code
;; is buggy and we need to know where from the original it was taken from.
;;
;; This requires you to have the original HSP source code for Elona's last
;; development version, which you can obtain if you e-mail Noa. It's still
;; hosted on ylvania.org.
;;
;; It might be a good idea to ask Noa if we can host the orignal source
;; somewhere solely for documentation purposes.
;;
;; Most of the code is modified from smerge-mode.

;;; Code:

(defvar open-nefia-context-text-properties
  `())

(defcustom open-nefia-context-shade2-source-dir "~/build/study/elona122"
  "Location of Elona 1.22 HSP source.")

(defface open-nefia-context-body
  '((((class color) (min-colors 88) (background light))
     :background "#888888")
    (((class color) (min-colors 88) (background dark))
     :background "#303030")
    (((class color))
     :foreground "grey10"))
  "Face for the `body' version of a conflict.")
(defvar open-nefia-context-body-face 'open-nefia-context-body)

(defface open-nefia-context-todo-body
  '((((class color) (min-colors 88) (background light))
     :background "#aa8888")
    (((class color) (min-colors 88) (background dark))
     :background "#403030")
    (((class color))
     :foreground "red"))
  "Face for the `body' version of a conflict.")
(defvar open-nefia-context-todo-body-face 'open-nefia-context-todo-body)

(defface open-nefia-context-markers
  '((((background light))
     (:background "grey75"))
    (((background dark))
     (:background "grey25")))
  "Face for the conflict markers.")
(defvar open-nefia-context-markers-face 'open-nefia-context-markers)

(defconst open-nefia-context-begin-re "^ *-- >>>>>>>> shade2/\\([^:]*\\):\\([0-9]+\\)\\(:\\(DONE\\)\\)?\\(.*\\)\n")
(defconst open-nefia-context-end-re "^ *-- <<<<<<<< shade2/\\([^:]*\\):\\([0-9]+\\)\\(.*\\)\n")

(defvar open-nefia-context-conflict-style nil
  "Keep track of which style of conflict is in use.
Can be nil if the style is undecided, or else:
- `diff3-E'
- `diff3-A'")

(defun open-nefia-context-match-conflict ()
  "Get info about the conflict.  Puts the info in the `match-data'.
The submatches contain:
 0:  the whole conflict.
 1:  upper version of the code.
 2:  base version of the code.
 3:  lower version of the code.
An error is raised if not inside a conflict."
  (save-excursion
    (condition-case nil
	(let* ((orig-point (point))

	       (_ (forward-line 1))
	       (_ (re-search-backward open-nefia-context-begin-re))

	       (start (match-beginning 0))
	       (upper-start (match-end 0))
	       (filename (or (match-string 1) ""))
	       (done (or (match-string 3) ""))

	       (upper-end (match-beginning 0))
	       (lower-start (match-end 0))

	       (_ (re-search-forward open-nefia-context-end-re))
	       (_ (cl-assert (< orig-point (match-end 0))))

	       (lower-end (match-beginning 0))
	       (end (match-end 0))

	       (base-start 0)
         (base-end 0))

	  ;; handle the various conflict styles
	  (cond
	   ((save-excursion
	      (goto-char upper-start)
	      (re-search-forward open-nefia-context-begin-re end t))
	    ;; There's a nested conflict and we're after the beginning
	    ;; of the outer one but before the beginning of the inner one.
	    ;; Of course, maybe this is not a nested conflict but in that
	    ;; case it can only be something nastier that we don't know how
	    ;; to handle, so may as well arbitrarily decide to treat it as
	    ;; a nested conflict.  --Stef
	    (error "There is a nested conflict"))

	   ((string= filename (file-name-nondirectory
			       (or buffer-file-name "")))
	    ;; a 2-parts conflict
	    (set (make-local-variable 'open-nefia-context-conflict-style) 'diff3-E))

	   ((and (not base-start)
		 (or (eq open-nefia-context-conflict-style 'diff3-A)
		     (equal filename "ANCESTOR")
		     (string-match "\\`[.0-9]+\\'" filename)))
	    ;; a same-diff conflict
	    (setq base-start upper-start
	          base-end   upper-end
	          upper-start lower-start
	          upper-end   lower-end)))

    (when (not (string= done ":DONE"))
      (setq base-start lower-start
            base-end lower-end))

	  (store-match-data (list start end
				  upper-start upper-end
				  lower-start lower-end
          lower-end end
          base-start base-end
				  ))
	  t)
      (search-failed (user-error "Point not in conflict region")))))

(defun open-nefia-context-conflict-overlay (pos)
  "Return the conflict overlay at POS if any."
  (let ((ols (overlays-at pos))
        conflict)
    (dolist (ol ols)
      (if (and (eq (overlay-get ol 'open-nefia-context) 'conflict)
               (> (overlay-end ol) pos))
          (setq conflict ol)))
    conflict))

(defun open-nefia-context-remove-props (beg end)
  (remove-overlays beg end 'open-nefia-context 'refine)
  (remove-overlays beg end 'open-nefia-context 'conflict)
  ;; Now that we use overlays rather than text-properties, this function
  ;; does not cause refontification any more.  It can be seen very clearly
  ;; in buffers where jit-lock-contextually is not t, in which case deleting
  ;; the "<<<<<<< foobar" leading line leaves the rest of the conflict
  ;; highlighted as if it were still a valid conflict.  Note that in many
  ;; important cases (such as the previous example) we're actually called
  ;; during font-locking so inhibit-modification-hooks is non-nil, so we
  ;; can't just modify the buffer and expect font-lock to be triggered as in:
  ;; (put-text-property beg end 'open-nefia-context-force-highlighting nil)
  (with-silent-modifications
    (remove-text-properties beg end '(fontified nil))))

(defun open-nefia-context-find-conflict (&optional limit)
  "Find and match a conflict region.  Intended as a font-lock MATCHER.
The submatches are the same as in `open-nefia-context-match-conflict'.
Returns non-nil if a match is found between point and LIMIT.
Point is moved to the end of the conflict."
  (let ((found nil)
        (pos (point))
        conflict)
    ;; First check to see if point is already inside a conflict, using
    ;; the conflict overlays.
    (while (and (not found) (setq conflict (open-nefia-context-conflict-overlay pos)))
      ;; Check the overlay's validity and kill it if it's out of date.
      (condition-case nil
          (progn
            (goto-char (overlay-start conflict))
            (open-nefia-context-match-conflict)
            (goto-char (match-end 0))
            (if (<= (point) pos)
                (error "Matching backward!")
              (setq found t)))
        (error (open-nefia-context-remove-props
                (overlay-start conflict) (overlay-end conflict))
               (goto-char pos))))
    ;; If we're not already inside a conflict, look for the next conflict
    ;; and add/update its overlay.
    (while (and (not found) (re-search-forward open-nefia-context-begin-re limit t))
      (condition-case nil
          (progn
            (open-nefia-context-match-conflict)
            (goto-char (match-end 0))
            (let ((conflict (open-nefia-context-conflict-overlay (1- (point)))))
              (if conflict
                  ;; Update its location, just in case it got messed up.
                  (move-overlay conflict (match-beginning 0) (match-end 0))
                (setq conflict (make-overlay (match-beginning 0) (match-end 0)
                                             nil 'front-advance nil))
                (overlay-put conflict 'evaporate t)
                (overlay-put conflict 'open-nefia-context 'conflict)
                (let ((props open-nefia-context-text-properties))
                  (while props
                    (overlay-put conflict (pop props) (pop props))))))
            (setq found t))
        (error nil)))
    found))

(defun open-nefia-context-get-file-and-bounds ()
  (save-excursion
    (condition-case nil
        (let ((_ (forward-line 1))
              (_ (re-search-backward open-nefia-context-begin-re))
              (filename (match-string-no-properties 1))
              (start-pos (string-to-number (match-string 2)))

              (_ (re-search-forward open-nefia-context-end-re))

              (end-pos (string-to-number (match-string 2)))
              )
          (list
           (format "%s/shade2/%s" open-nefia-context-shade2-source-dir filename)
           start-pos end-pos))
      (search-failed (user-error "Point not in context region")))))

(defun open-nefia-context--point-at-line (line)
  (save-excursion
    (goto-char (point-min))
    (forward-line line)
    (point)))

(defun open-nefia-context-show (arg)
  (interactive "P")
  (let* ((res (open-nefia-context-get-file-and-bounds))
         (filename (nth 0 res))
         (start-line (nth 1 res))
         (end-line (nth 2 res))
         (buf (find-file-noselect filename)))
    (if arg
        (progn
          (pop-to-buffer buf)
          (recenter))
      (display-buffer buf))
    (with-current-buffer buf
      (widen)
      (let ((start-pos (open-nefia-context--point-at-line (1- start-line)))
            (end-pos (open-nefia-context--point-at-line end-line)))
        (narrow-to-region start-pos end-pos)
        (goto-char (point-min)))))
  (redraw-display))

(defun open-nefia-context-goto (arg)
  (interactive "P")
  (let* ((res (open-nefia-context-get-file-and-bounds))
         (filename (nth 0 res))
         (start-line (nth 1 res))
         (buf (find-file-noselect filename)))
    (if arg
        (display-buffer buf)
      (progn
        (pop-to-buffer buf)
        (recenter)))
    (with-current-buffer buf
      (widen)
      (let ((start-pos (open-nefia-context--point-at-line (1- start-line))))
        (goto-char start-pos)))))

(defconst open-nefia-context-font-lock-keywords
  '((open-nefia-context-find-conflict
     (1 open-nefia-context-markers-face prepend t)
     (2 open-nefia-context-body-face append t)
     ;; FIXME: `keep' doesn't work right with syntactic fontification.
     (3 open-nefia-context-markers-face prepend t)
     (4 open-nefia-context-todo-body-face append t)
     ;(3 nil t t)
     ;(4 open-nefia-context-lower-face prepend t)
     ))
  "Font lock patterns for `open-nefia-context-mode'.")

;;;###autoload
(define-minor-mode open-nefia-context-mode
  "Minor mode for displaying and jumping to regions of ported code in OpenNefia's codebase."
  :group 'open-nefia-context :lighter " ONContext"
  (save-excursion
    (if open-nefia-context-mode
        (font-lock-add-keywords nil open-nefia-context-font-lock-keywords 'append)
      (font-lock-remove-keywords nil open-nefia-context-font-lock-keywords))
    (goto-char (point-min))
    (while (open-nefia-context-find-conflict)
      (save-excursion
        (font-lock-fontify-region (match-beginning 0) (match-end 0) nil))))
  (unless open-nefia-context-mode
    (open-nefia-context-remove-props (point-min) (point-max))))

(provide 'open-nefia-context)
;;; open-nefia-context.el ends here
