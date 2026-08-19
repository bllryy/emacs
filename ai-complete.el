;;; ai-complete.el --- AI code completion via Anthropic or DeepSeek -*- lexical-binding: t; -*-

;; Author: you
;; Version: 0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: convenience, completion

;;; Commentary:
;; TAB to complete at point. C-c C-a to generate from a leading comment.
;; Set ANTHROPIC_API_KEY or DEEPSEEK_API_KEY in your env, or customize
;; `ai-complete-provider' and the corresponding key variable.

;;; Code:

(require 'json)
(require 'url)
(require 'cl-lib)

(defgroup ai-complete nil "AI code completion." :group 'tools)

(defcustom ai-complete-provider 'anthropic
  "Which provider to use: `anthropic' or `deepseek'."
  :type '(choice (const anthropic) (const deepseek)))

(defcustom ai-complete-anthropic-model "claude-opus-4-5"
  "Anthropic model." :type 'string)

(defcustom ai-complete-deepseek-model "deepseek-coder"
  "DeepSeek model." :type 'string)

(defcustom ai-complete-max-tokens 512
  "Max tokens per completion." :type 'integer)

(defcustom ai-complete-context-chars 4000
  "Chars of buffer context sent before/after point." :type 'integer)

(defcustom ai-complete-idle-delay 0.6
  "Seconds of idle time before auto-triggering a suggestion.
Set to nil to disable automatic (Copilot-style) triggering and
rely only on manually invoking `ai-complete-suggest'."
  :type '(choice (const :tag "Disabled" nil) number))

(defcustom ai-complete-anthropic-key (getenv "ANTHROPIC_API_KEY")
  "Anthropic API key (defaults to env var)." :type 'string)

(defcustom ai-complete-deepseek-key (getenv "DEEPSEEK_API_KEY")
  "DeepSeek API key (defaults to env var)." :type 'string)

(defvar ai-complete--overlay nil)
(defvar ai-complete--last-completion nil)
(defvar-local ai-complete--pending nil
  "Non-nil while a request is in flight for the current buffer.")
(defvar ai-complete--global-idle-timer nil
  "Single idle timer shared across all `ai-complete-mode' buffers.")

(defface ai-complete-ghost-face
  '((t :inherit shadow :slant italic))
  "Face for inline suggestion.")

(defun ai-complete--lang ()
  (let ((n (symbol-name major-mode)))
    (replace-regexp-in-string "-mode$\\|-ts-mode$" "" n)))

(defun ai-complete--context ()
  (let* ((half ai-complete-context-chars)
         (before (buffer-substring-no-properties
                  (max (point-min) (- (point) half)) (point)))
         (after (buffer-substring-no-properties
                 (point) (min (point-max) (+ (point) half)))))
    (cons before after)))

(defun ai-complete--build-prompt (before after)
  (format "You are a code completion engine for %s. Continue the code at the <CURSOR> position. Output ONLY the raw code to insert at the cursor, no explanations, no markdown fences, no repeated context. Keep it short and idiomatic. Stop at a natural boundary (end of function/block).

<CODE>
%s<CURSOR>%s
</CODE>"
          (ai-complete--lang) before after))

(defun ai-complete--strip-fences (s)
  (let ((s (string-trim s)))
    (when (string-match "\\````[a-zA-Z0-9_+-]*\n?\\(\\(?:.\\|\n\\)*?\\)\n?```\\'" s)
      (setq s (match-string 1 s)))
    s))

(defun ai-complete--request-anthropic (prompt cb)
  (unless ai-complete-anthropic-key
    (user-error "Set ANTHROPIC_API_KEY or `ai-complete-anthropic-key'"))
  (let* ((url-request-method "POST")
         (url-request-extra-headers
          `(("content-type" . "application/json")
            ("x-api-key" . ,ai-complete-anthropic-key)
            ("anthropic-version" . "2023-06-01")))
         (url-request-data
          (encode-coding-string
           (json-encode
            `(("model" . ,ai-complete-anthropic-model)
              ("max_tokens" . ,ai-complete-max-tokens)
              ("messages" . [,`(("role" . "user") ("content" . ,prompt))])))
           'utf-8)))
    (url-retrieve "https://api.anthropic.com/v1/messages"
                  (lambda (status)
                    (ai-complete--handle status cb
                                         (lambda (j)
                                           (let-alist j
                                             (alist-get 'text (aref .content 0))))))
                  nil t)))

(defun ai-complete--request-deepseek (prompt cb)
  (unless ai-complete-deepseek-key
    (user-error "Set DEEPSEEK_API_KEY or `ai-complete-deepseek-key'"))
  (let* ((url-request-method "POST")
         (url-request-extra-headers
          `(("content-type" . "application/json")
            ("authorization" . ,(concat "Bearer " ai-complete-deepseek-key))))
         (url-request-data
          (encode-coding-string
           (json-encode
            `(("model" . ,ai-complete-deepseek-model)
              ("max_tokens" . ,ai-complete-max-tokens)
              ("messages" . [,`(("role" . "user") ("content" . ,prompt))])))
           'utf-8)))
    (url-retrieve "https://api.deepseek.com/chat/completions"
                  (lambda (status)
                    (ai-complete--handle status cb
                                         (lambda (j)
                                           (let-alist j
                                             (alist-get 'content
                                                        (alist-get 'message (aref .choices 0)))))))
                  nil t)))

(defun ai-complete--handle (status cb extractor)
  (let ((buf (current-buffer)))
    (unwind-protect
        (if (plist-get status :error)
            (message "ai-complete: %S" (plist-get status :error))
          (goto-char (point-min))
          (re-search-forward "\n\n" nil t)
          (let* ((body (decode-coding-string
                        (buffer-substring-no-properties (point) (point-max)) 'utf-8))
                 (json-object-type 'alist)
                 (json-array-type 'vector)
                 (parsed (json-read-from-string body))
                 (text (funcall extractor parsed)))
            (funcall cb (ai-complete--strip-fences (or text "")))))
      (kill-buffer buf))))

(defun ai-complete--request (prompt cb)
  (pcase ai-complete-provider
    ('anthropic (ai-complete--request-anthropic prompt cb))
    ('deepseek  (ai-complete--request-deepseek prompt cb))
    (_ (user-error "Unknown provider: %s" ai-complete-provider))))

(defun ai-complete--clear ()
  (when (overlayp ai-complete--overlay)
    (delete-overlay ai-complete--overlay))
  (setq ai-complete--overlay nil
        ai-complete--last-completion nil))

(defun ai-complete--show (text)
  (ai-complete--clear)
  (when (and text (> (length text) 0))
    (setq ai-complete--last-completion text)
    (let ((ov (make-overlay (point) (point) nil t t)))
      (overlay-put ov 'after-string
                   (propertize text 'face 'ai-complete-ghost-face 'cursor t))
      (setq ai-complete--overlay ov))))

;;;###autoload
(defun ai-complete-suggest ()
  "Ask the model for a suggestion at point and show it as ghost text."
  (interactive)
  (ai-complete--clear)
  (let* ((ctx (ai-complete--context))
         (prompt (ai-complete--build-prompt (car ctx) (cdr ctx)))
         (target (current-buffer))
         (pos (point)))
    (setq ai-complete--pending t)
    (when (called-interactively-p 'interactive)
      (message "ai-complete: thinking..."))
    (ai-complete--request
     prompt
     (lambda (text)
       (when (buffer-live-p target)
         (with-current-buffer target
           (setq ai-complete--pending nil)
           (when (= (point) pos)
             (ai-complete--show text)
             (message "ai-complete: TAB to accept, any key to dismiss"))))))))

;;;###autoload
(defun ai-complete-accept ()
  "Accept the current ghost suggestion."
  (interactive)
  (unless ai-complete--last-completion
    (user-error "No suggestion"))
  (let ((text ai-complete--last-completion))
    (ai-complete--clear)
    (insert text)))

;;;###autoload
(defun ai-complete-dismiss ()
  "Dismiss the current suggestion."
  (interactive)
  (ai-complete--clear))

(defun ai-complete--tab-dwim ()
  "If a suggestion is showing, accept it. Otherwise fall back to indent."
  (interactive)
  (if (and ai-complete--last-completion (overlayp ai-complete--overlay))
      (ai-complete-accept)
    (call-interactively (or (local-key-binding (kbd "TAB"))
                            #'indent-for-tab-command))))

(defvar ai-complete-mode-map
  (let ((m (make-sparse-keymap)))
    (define-key m (kbd "C-c C-a") #'ai-complete-suggest)
    (define-key m (kbd "C-c C-d") #'ai-complete-dismiss)
    (define-key m (kbd "<tab>")   #'ai-complete--tab-dwim)
    (define-key m (kbd "TAB")     #'ai-complete--tab-dwim)
    m))

(defun ai-complete--pre-command ()
  (when (and ai-complete--overlay
             (not (memq this-command
                        '(ai-complete-accept ai-complete--tab-dwim
                          ai-complete-suggest ai-complete-dismiss))))
    (ai-complete--clear)))

(defun ai-complete--idle-trigger ()
  "Auto-suggest in the current buffer if conditions allow it."
  (when (and (bound-and-true-p ai-complete-mode)
             ai-complete-idle-delay
             (not ai-complete--pending)
             (not ai-complete--overlay)
             (not buffer-read-only)
             (not (minibufferp)))
    (ai-complete-suggest)))

(defun ai-complete--ensure-global-timer ()
  (unless ai-complete--global-idle-timer
    (setq ai-complete--global-idle-timer
          (run-with-idle-timer (or ai-complete-idle-delay 0.6) t
                                #'ai-complete--idle-trigger))))

;;;###autoload
(define-minor-mode ai-complete-mode
  "Minor mode for AI code completion."
  :lighter " AIc"
  :keymap ai-complete-mode-map
  (if ai-complete-mode
      (progn
        (add-hook 'pre-command-hook #'ai-complete--pre-command nil t)
        (ai-complete--ensure-global-timer))
    (remove-hook 'pre-command-hook #'ai-complete--pre-command t)
    (ai-complete--clear)))

;;;###autoload
(define-globalized-minor-mode global-ai-complete-mode
  ai-complete-mode
  (lambda () (when (derived-mode-p 'prog-mode) (ai-complete-mode 1))))

(provide 'ai-complete)
;;; ai-complete.el ends here
