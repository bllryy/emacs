;;; config.el --- General configuration -*- lexical-binding: t -*-

;;; UI
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)

;;; Font
(defun lily/get-font ()
  (cond
   ((eq system-type 'darwin)     "Iosevka Nerd Font-15")
   ((eq system-type 'gnu/linux)  "Iosevka Nerd Font-13")
   (t                            "Monospace-12")))

(add-to-list 'default-frame-alist `(font . ,(lily/get-font)))

;;; Frame size on startup
(add-to-list 'default-frame-alist '(width  . 200))
(add-to-list 'default-frame-alist '(height . 55))

;;; Editing
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq-default truncate-lines t)
(electric-pair-mode 1)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; C style
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode  . "awk")
                                (other     . "bsd")))

;;; Dired
(require 'dired-x)
(require 'dired-aux)
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
(setq-default dired-dwim-target t)
(setq dired-listing-switches "-alh")

;;; Make - and _ word chars in prog buffers
(add-hook 'prog-mode-hook
          (lambda ()
            (modify-syntax-entry ?- "w")
            (modify-syntax-entry ?_ "w")))

;;; Telescope (custom file finder — keep tony's impl)
(load (expand-file-name "telescope.el" user-emacs-directory))

;;; Base search dir (SPC c r to change)
(defvar lily/base-dir (expand-file-name "~"))

(defun lily/set-base-dir ()
  (interactive)
  (setq lily/base-dir (read-directory-name "Search root: " lily/base-dir))
  (message "Search root: %s" lily/base-dir))

(defun lily/find-files ()
  (interactive)
  (telescope-find-files lily/base-dir))

(defun lily/ripgrep ()
  (interactive)
  (consult-ripgrep lily/base-dir))

(defun lily/ripgrep-symbol ()
  (interactive)
  (consult-ripgrep lily/base-dir (thing-at-point 'symbol t)))

(defun lily/find-config ()
  (interactive)
  (telescope-find-files (expand-file-name "~/.emacs.d/")))

(defun lily/switch-project ()
  (interactive)
  (let* ((repos "~/repos/")
         (dirs (seq-filter
                (lambda (f) (file-directory-p (expand-file-name f repos)))
                (directory-files repos nil "^[^.]")))
         (chosen (completing-read "Project: " dirs nil t)))
    (when chosen
      (let ((dir (expand-file-name chosen repos)))
        (setq lily/base-dir dir)
        (dired dir)
        (message "Project: %s" dir)))))

(defun lily/vterm-here ()
  (interactive)
  (let ((default-directory (or (and buffer-file-name
                                    (file-name-directory buffer-file-name))
                               default-directory))
        (display-buffer-alist nil))
    (pop-to-buffer-same-window (vterm "*vterm*"))))

;;; Popup window layout (xref, compile, grep open below at 35%)
(setq display-buffer-alist
      '(("\\*xref\\*\\|\\*compilation\\*\\|\\*grep\\*"
         (display-buffer-reuse-window display-buffer-below-selected)
         (window-height . 0.35))))

(defun lily/close-popup ()
  (interactive)
  (dolist (win (window-list))
    (when (string-match-p "\\*xref\\*\\|\\*compilation\\*\\|\\*grep\\*\\|\\*Help\\*"
                          (buffer-name (window-buffer win)))
      (delete-window win))))
