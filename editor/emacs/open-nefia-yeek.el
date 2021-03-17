;;; open-nefia-yeek.el -- Interface to yeek, a source code analyzer for OpenNefia
;;
;; Copyright (C) 2021 Ruin0x11
;;
;; Author: Ruin0x11 <ipickering2@gmail.com>
;; Keywords: tools
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))

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
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;; Code:

(require 'open-nefia)

(defcustom open-nefia-yeek-executable-name "yeek"
  "Executable to use for yeek.")

(defcustom open-nefia-yeek-executable-arguments '()
  "Extra program arguments for yeek.")

(defun open-nefia-yeek--run (cmd &rest args)
  (compile
   (mapconcat 'identity
              (append (list open-nefia-yeek-executable-name cmd)
                      open-nefia-yeek-executable-arguments
                      args) " ")))

(defun open-nefia-yeek-move (file dir)
  "Runs yeek to move module FILE to DIR."
  (interactive
   (list
    (projectile-completing-read "Module file: " (open-nefia--api-file-cands))
    (projectile-completing-read "New directory: " (open-nefia--api-dir-cands))))

  (let* ((root (projectile-project-root))
         (dir (concat root dir))
         (file (concat root file)))
    (open-nefia-yeek--run "move" file dir)))

(provide 'open-nefia-yeek)
;;; open-nefia-yeek.el ends here
