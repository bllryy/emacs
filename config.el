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
;;(defun lily/get-font ()
;;  (cond
;;   ((eq system-type 'darwin)     "Iosevka Nerd Font-15")
;;   ((eq system-type 'gnu/linux)  "Iosevka Nerd Font-13")
;;   (t                            "Monospace-12")))

;;(add-to-list 'default-frame-alist `(font . ,(lily/get-font)))

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

;;; Git gutter indicators (diff-hl — VS Code-style green/red bars)
(global-diff-hl-mode 1)
(diff-hl-margin-mode 1)    ; show in margin (fringe next to line numbers)
(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

;;; Magit diff fine-tuning
(setq magit-diff-refine-hunk t)      ; word-level diffs within changed lines
(setq magit-diff-paint-whitespace nil)

;;; Ediff — VS Code-style side-by-side diff with red (old) / green (new)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-diff-options "-w")       ; ignore whitespace

;; Cleaner ediff: kill the control panel on quit
(defun lily/ediff-cleanup ()
  (when (and (boundp 'ediff-control-buffer)
             (buffer-live-p ediff-control-buffer))
    (kill-buffer ediff-control-buffer)))
(add-hook 'ediff-quit-hook 'lily/ediff-cleanup)

;; VS Code-style red/green backgrounds for ediff diffs
(custom-set-faces
 '(ediff-current-diff-A ((t (:background "#553333"))))   ; old (red-ish)
 '(ediff-current-diff-B ((t (:background "#335533"))))   ; new (green-ish)
 '(ediff-current-diff-C ((t (:background "#335555"))))   ; combined
 '(ediff-fine-diff-A    ((t (:background "#773333"))))   ; old word-level
 '(ediff-fine-diff-B    ((t (:background "#337733"))))   ; new word-level
 '(ediff-even-diff-A    ((t (:background "#2a2a2a"))))   ; old even
 '(ediff-even-diff-B    ((t (:background "#2a2a2a"))))   ; new even
 '(ediff-odd-diff-A     ((t (:background "#333333"))))   ; old odd
 '(ediff-odd-diff-B     ((t (:background "#333333")))))  ; new odd

;;; Show commit diff — prompts for a commit and opens its changes (like VS Code)
(defun lily/show-commit-diff (commit)
  "Show the full diff of COMMIT via magit."
  (interactive
   (list (let ((default (or (ignore-errors
                              (car (process-lines "git" "rev-parse" "HEAD")))
                            "")))
           (magit-read-branch-or-commit "Show commit" default))))
  (magit-show-commit commit))
