;;; dockspec.el --- run tests through docker

;; Copyright 2016 John Cinnamond

;; Author: John Cinnamond
;; Version: 1.0.0

;;; Commentary:
;;
;; Run rspec (or in theory any test framework?) via a docker container.
;;
;; See README.md for more details.

;;; License:

;; This file is not part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(defgroup dockspec nil
  "Minor mode for running tests using docker containers."
  :group 'languages)

(defcustom dockspec-docker-command "docker-compose"
  "The name of the docker-compose executable."
  :type 'string
  :group 'dockspec)

(defcustom dockspec-run-command "run"
  "The command to pass to docker-compose. You shouldn't need to change this."
  :type 'string
  :group 'dockspec)

(defcustom dockspec-run-flags "--rm"
  "Arguments to pass to the run command."
  :type 'string
  :group 'dockspec)

(defcustom dockspec-service-name "test"
  "The name of the service to run. This must exist in the compose file."
  :type 'string
  :group 'dockspec)

(defcustom dockspec-test-command "rspec"
  "The command used to run the tests. This will be run inside the docker container."
  :type 'string
  :group 'dockspec)

(defcustom dockspec-project-root nil
  "Base directory for the project. This is normally calculated but can be overridden by setting this explicitly."
  :type 'string
  :group 'dockspec)

(defcustom dockspec-key-command-prefix (kbd "C-c ,")
  "The prefix for all dockspec related key commands."
  :type 'string
  :group 'dockspec)

(define-prefix-command 'dockspec-prefix-keymap)
(define-key dockspec-prefix-keymap (kbd "v") 'dockspec-run-current-file)
(define-key dockspec-prefix-keymap (kbd "s") 'dockspec-run-current-line)
(define-key dockspec-prefix-keymap (kbd "a") 'dockspec-run-all)
(defvar dockspec-keymap (make-sparse-keymap))
(define-key dockspec-keymap dockspec-key-command-prefix dockspec-prefix-keymap)

(defun dockspec--project-root ()
  (if (bound-and-true-p dockspec-project-root)
      dockspec-project-root
    (dockspec--find-project-root)))

(defun dockspec--filesystem-root-p (directory)
  (string-equal directory (file-name-directory (directory-file-name directory))))

(defun dockspec--find-project-root (&optional directory)
  "Finds the root directory of the project by walking the directory tree until it finds a rake file."
  (let ((directory (file-name-as-directory (or directory default-directory))))
    (cond ((dockspec--filesystem-root-p directory)
	   (error "Could not determine the project root."))
	  ((file-exists-p (expand-file-name "Rakefile" directory)) directory)
	  ((file-exists-p (expand-file-name "Gemfile" directory)) directory)
	  ((file-exists-p (expand-file-name ".git" directory)) directory)
	  (t (dockspec--find-project-root (file-name-directory (directory-file-name directory)))))))

(defun dockspec--spec-path ()
  (file-relative-name buffer-file-name (dockspec--project-root)))

(defun dockspec--run (path)
  (let ((default-directory (dockspec--project-root)))
    (compile (format "%s %s %s %s %s %s"
		     dockspec-docker-command
		     dockspec-run-command
		     dockspec-run-flags
		     dockspec-service-name
		     dockspec-test-command
		     path))))

(defun dockspec-run-current-file ()
  (interactive)
  (dockspec--run (dockspec--spec-path)))

(defun dockspec-run-current-line ()
  (interactive)
  (dockspec--run (format "%s:%s" (dockspec--spec-path) (count-lines 1 (point)))))

(defun dockspec-run-all ()
  (interactive)
  (dockspec--run ""))

(define-minor-mode dockspec
  "Run tests in a docker container"
  :lighter " dockspec"
  :keymap dockspec-keymap)

(provide 'dockspec)
;;; dockspec.el ends here
