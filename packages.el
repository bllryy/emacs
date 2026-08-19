;;; packages.el --- Package configuration -*- lexical-binding: t -*-

;;; Evil
(setq evil-want-keybinding nil)
(setq evil-search-module 'evil-search)
(setq evil-undo-system 'undo-redo)
(rc/require 'evil 'evil-leader 'evil-collection 'evil-commentary)
(global-evil-leader-mode)
(evil-leader/set-leader "<SPC>")
(evil-mode 1)
(evil-collection-init)
(evil-commentary-mode 1)

;;; Vertico + Consult + Orderless
(rc/require 'vertico 'consult 'orderless 'marginalia 'vertico-posframe)
(vertico-mode 1)
(vertico-posframe-mode 1)
(marginalia-mode 1)
(recentf-mode 1)

(setq vertico-posframe-parameters
      '((left-fringe . 8)
        (right-fringe . 8)))
(setq vertico-posframe-poshandler #'posframe-poshandler-frame-center)

(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles . (partial-completion)))))
(setq orderless-matching-styles '(orderless-literal orderless-flex))

;;; Corfu (inline autocomplete)
(rc/require 'corfu 'corfu-terminal)
(setq corfu-auto t
      corfu-auto-delay 0.15
      corfu-auto-prefix 1
      corfu-cycle t
      corfu-quit-no-match t)
(global-corfu-mode 1)
(unless (display-graphic-p)
  (corfu-terminal-mode 1))

;;; Cape (completion backends)
(rc/require 'cape)
(add-to-list 'completion-at-point-functions #'cape-file)
(add-to-list 'completion-at-point-functions #'cape-dabbrev)

;;; Tree-sitter
(rc/require 'tree-sitter 'tree-sitter-langs 'evil-textobj-tree-sitter)
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
(define-key evil-outer-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.outer"))
(define-key evil-inner-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.inner"))
(define-key evil-outer-text-objects-map "c" (evil-textobj-tree-sitter-get-textobj "class.outer"))
(define-key evil-inner-text-objects-map "c" (evil-textobj-tree-sitter-get-textobj "class.inner"))

;;; Diff HL (gutter indicators for git changes)
(rc/require 'diff-hl)

;;; Magit
(rc/require 'magit)
(setq magit-auto-revert-mode nil)

;;; Multiple cursors
(rc/require 'multiple-cursors)

;;; Move text
(rc/require 'move-text)

;;; Language modes
(rc/require 'rust-mode 'typescript-mode 'go-mode 'python-mode 'web-mode)

;;; LSP via eglot (built-in Emacs 29+)
(require 'eglot)
(rc/require 'eldoc-box)

(add-hook 'rust-mode-hook       'eglot-ensure)
(add-hook 'typescript-mode-hook 'eglot-ensure)
(add-hook 'tsx-ts-mode-hook     'eglot-ensure)
(add-hook 'js-mode-hook         'eglot-ensure)
(add-hook 'python-mode-hook     'eglot-ensure)
(add-hook 'go-mode-hook         'eglot-ensure)
(add-hook 'c-mode-hook          'eglot-ensure)
(add-hook 'c++-mode-hook        'eglot-ensure)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(typescript-mode . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(tsx-ts-mode . ("typescript-language-server" "--stdio"))))

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.py\\'"  . python-mode))

;; Format on save
(add-hook 'go-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'eglot-format-buffer nil t)))
(add-hook 'rust-mode-hook
          (lambda ()
            (setq-local eglot-workspace-configuration
                        '(:rust-analyzer
                          (:cargo (:allFeatures t)
                           :rustfmt (:extraArgs ["--edition" "2021"]))))
            (add-hook 'before-save-hook 'eglot-format-buffer nil t)))

;;; Flymake inline errors
(rc/require 'flymake-popon)
(add-hook 'flymake-mode-hook #'flymake-popon-mode)
(add-hook 'eglot-managed-mode-hook #'flymake-mode)

;;; vterm
(rc/require 'vterm)
(setq vterm-shell (or (getenv "SHELL") "/bin/bash"))
(setq vterm-kill-buffer-on-exit t)

;;; Org mode
(rc/require 'org-superstar 'org-fancy-priorities)
(setq org-directory "~/org/")
(add-hook 'org-mode-hook #'org-superstar-mode)
(add-hook 'org-mode-hook #'org-fancy-priorities-mode)
(add-hook 'org-mode-hook #'org-indent-mode)
(add-hook 'org-mode-hook 'visual-line-mode)
(setq org-superstar-headline-bullets-list '("◉" "●" "○" "◆"))
(setq org-fancy-priorities-list '("⚑" "▲" "»"))
(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-hide-emphasis-markers t
      org-ellipsis " ▾"
      org-return-follows-link t)

;;; Rainbow delimiters
(rc/require 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;;; Topsy (sticky function header)
(rc/require 'topsy)
(add-hook 'prog-mode-hook 'topsy-mode)

;;; Theme
;; (rc/require 'gruber-darker-theme)
;; (load-theme 'gruber-darker t)
(rc/require 'doom-themes)
(load-theme 'doom-one t)

;;; Clean modeline
(setq eldoc-minor-mode-string nil)
(with-eval-after-load 'flymake
  (setq flymake-mode-line-format nil))
(with-eval-after-load 'evil-commentary
  (setq evil-commentary-mode-lighter nil))

;;; java Language
(add-to-list 'eglot-server-programs
             '(java-mode . ("~/.local/share/jdtls/bin/jdtls")))
(add-hook 'java-mode-hook 'eglot-ensure)

;;; Discord Rich Presence
(rc/require 'elcord)
(setq elcord-refresh-rate 15)
(setq elcord-idle-message "")
(elcord-mode 1)
