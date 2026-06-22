;;; keybinds.el --- All keybindings -*- lexical-binding: t -*-

;;; Escape insert with C-c
(define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)

;;; Multiple cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)

;;; Move lines
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

;;; Dired
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file
    "." 'dired-create-empty-file
    "n" 'evil-search-next
    "N" 'evil-search-previous))

;;; LSP
(with-eval-after-load 'eglot
  (evil-define-key 'normal eglot-mode-map
    "K"  'eldoc-box-help-at-point
    "gd" 'xref-find-definitions
    "gr" 'xref-find-references
    "gi" 'eglot-find-implementation
    "gD" 'xref-find-definitions-other-window))

;;; Org
(with-eval-after-load 'org
  (evil-define-key 'normal org-mode-map
    (kbd "RET") 'org-open-at-point
    "t"         'org-todo))

;;; ─────────────────────────────────────────
;;; LEADER KEYS  (SPC ...)
;;; ─────────────────────────────────────────
(evil-leader/set-key

  ;; FILES
  "ff" 'lily/find-files              ; SPC ff  — fuzzy find files from root
  "fg" 'lily/ripgrep                 ; SPC fg  — ripgrep from root
  "fs" 'lily/ripgrep-symbol          ; SPC fs  — ripgrep symbol at point
  "fo" 'consult-recent-file          ; SPC fo  — recent files
  "fl" 'consult-line                 ; SPC fl  — search lines in buffer
  "fi" 'lily/find-config             ; SPC fi  — find file in emacs config
  "fp" 'lily/switch-project          ; SPC fp  — switch project (~/repos)
  "fr" 'lily/set-base-dir            ; SPC fr  — change search root

  ;; BUFFERS
  "bb" 'consult-buffer               ; SPC bb  — switch buffer
  "bp" 'previous-buffer              ; SPC bp  — previous buffer
  "bn" 'next-buffer                  ; SPC bn  — next buffer
  "bd" 'kill-current-buffer          ; SPC bd  — kill buffer
  "bm" 'ibuffer                      ; SPC bm  — buffer list

  ;; WINDOWS
  "wv" 'split-window-right           ; SPC wv  — split vertical
  "ws" 'split-window-below           ; SPC ws  — split horizontal
  "wd" 'delete-window                ; SPC wd  — close window
  "wo" 'delete-other-windows         ; SPC wo  — close others (maximize)
  "wh" 'evil-window-left             ; SPC wh  — focus left
  "wj" 'evil-window-down             ; SPC wj  — focus down
  "wk" 'evil-window-up               ; SPC wk  — focus up
  "wl" 'evil-window-right            ; SPC wl  — focus right
  "w=" 'balance-windows              ; SPC w=  — equalize window sizes

  ;; GIT (magit)
  "ms" 'magit-status                 ; SPC ms  — git status
  "ml" 'magit-log                    ; SPC ml  — git log
  "mb" 'magit-blame                  ; SPC mb  — git blame
  "md" 'magit-diff                   ; SPC md  — git diff

  ;; COMPILE / ERRORS
  "cc" 'compile                      ; SPC cc  — compile
  "cm" 'recompile                    ; SPC cm  — recompile (repeat last)
  "cn" 'next-error                   ; SPC cn  — next error
  "cp" 'previous-error               ; SPC cp  — prev error
  "cl" 'lily/close-popup             ; SPC cl  — close popup windows

  ;; LSP
  "lr" 'eglot-rename                 ; SPC lr  — rename symbol
  "la" 'eglot-code-actions           ; SPC la  — code actions
  "lf" 'eglot-format-buffer          ; SPC lf  — format buffer
  "lR" 'eglot-reconnect              ; SPC lR  — restart LSP

  ;; TERMINAL
  "to" 'lily/vterm-here              ; SPC to  — open vterm here

  ;; ORG
  "oa" 'org-agenda                   ; SPC oa  — org agenda
  "oc" 'org-capture                  ; SPC oc  — org capture

  ;; MISC
  ";" 'execute-extended-command      ; SPC ;   — M-x
  "u" 'universal-argument            ; SPC u   — C-u prefix
)
