;;; my-config.el --- Node.js Emacs config  -*- lexical-binding: t -*-

;;; Commentary:

;; This file sets up js2-mode, prettier-js, flycheck, smartparens, company, and projectile
;; for professional Node.js development.

;;; Code:

;; Your Emacs Lisp code goes here

(require 'package)
;; Add MELPA for modern packages
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

;; Initialize  package system
(package-initialize)

;; Refresh package list automatically if empty
(unless package-archive-contents
  (package-refresh-contents))

(defvar my-packages
  '(flycheck
    smartparens
    js2-mode
    diff-hl
    origami
    typescript-mode
    all-the-icons-dired
    diredfl
    dired-git-info
    dired-subtree
    treemacs
    prettier-js
    eglot
    projectile
    company
    yaml-mode
    git-messenger 
    multiple-cursors
    magit))

;; Install missing packages automatically
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; Load yaml-mode
(require 'yaml-mode)
;; Automatically use yaml-mode for .yml and .yaml files
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

;; Copy from outside of window
;; macOS clipboard support for Terminal Emacs
(setq interprogram-cut-function
      (lambda (text)
        (with-temp-buffer
          (insert text)
          (call-process-region (point-min) (point-max)
                               "pbcopy"))))

(setq interprogram-paste-function
      (lambda ()
        (when (executable-find "pbpaste")
          (shell-command-to-string "pbpaste"))))

;; Manualy proving path for ctags
(setq tags-revert-without-query t)
(setq projectile-tags-command
      "/opt/homebrew/bin/ctags -R -e -f \"%s\" %s")


;; Configuring diff-hl for magit
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode)
  (diff-hl-margin-mode)) ;; or diff-hl-fringe-mode
(add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)
(set-face-attribute 'mode-line nil :height 1.1)


;; Cofiguring
(use-package origami
  :ensure t
  :hook (prog-mode . origami-mode)
  :bind
  ("M-g a" . origami-recursively-toggle-node)
  ("M-g s" . origami-toggle-all-nodes))

;; Haft screen move
(defun move-cursor-6-lines-forward ()
  "Move cursor forward (down) by 6 lines."
  (interactive)
  (forward-line 6))

(defun move-cursor-6-lines-backward ()
  "Move cursor backward (up) by 6 lines."
  (interactive)
  (forward-line -6))
;; Bind to C-v and M-v
(global-set-key (kbd "C-v") #'move-cursor-6-lines-forward)
(global-set-key (kbd "M-v") #'move-cursor-6-lines-backward)


;; File path in buffer
(setq-default mode-line-buffer-identification
              '(:eval (abbreviate-file-name buffer-file-name)))
;; Enable global line number
(global-display-line-numbers-mode t)

;; Use js2-mode instead of built-in js-mode
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;; Open directories in dired automatically
(add-to-list 'auto-mode-alist '("/$" . dired-mode))

;; Dired enhancements
(add-hook 'dired-mode-hook 'diredfl-mode)
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;;(add-hook 'dired-mode-hook 'dired-git-info-mode)
;;(add-hook 'dired-mode-hook #'dired-subtree-mode)


;;  project awareness
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :custom
  (projectile-completion-system 'auto))

;; Smartparens
(require 'smartparens-config)
(smartparens-global-mode 1)

;; Flycheck
(require 'flycheck)
(global-flycheck-mode)

;; Company Auto completion
(require 'company)
(global-company-mode 1)

;; JS files
(add-hook 'js2-mode-hook 'prettier-js-mode)

;; TS files
(add-hook 'typescript-mode-hook 'prettier-js-mode)
;; Linting on save
(add-hook 'js2-mode-hook
          (lambda ()
            (prettier-js-mode)
            (add-hook 'before-save-hook 'prettier-js nil t)))
;; Linting on save
(add-hook 'dired-mode
          (lambda ()
            (prettier-js-mode)
            (add-hook 'before-save-hook 'prettier-js nil t)))

(add-hook 'typescript-mode-hook
          (lambda ()
            (prettier-js-mode)
            (add-hook 'before-save-hook 'prettier-js nil t)))

;; Install lsp-mode (and optionally lsp-ui for nicer UI)
(use-package lsp-mode
  :hook ((js-mode . lsp)
         (js2-mode . lsp)   ;; if using js2-mode
         (typescript-mode . lsp))
  :commands lsp)

;; Optional: better UI for peek / docs
(use-package lsp-ui
  :commands lsp-ui-mode)

;; ----------------------------
;; Desktop session (save buffers and window layout)
;; ----------------------------
(require 'desktop)

;; Directory and file for desktop session
(setq desktop-dirname             "~/.emacs.d/")
(setq desktop-base-file-name      "emacs-desktop")
(setq desktop-path                (list desktop-dirname))

;; Save automatically on exit
(setq desktop-save 'always)  ;; always save, even if file exists
(setq desktop-load-locked-desktop t) ;; allow load if locked

;; Git commit review pop up
(global-set-key (kbd "C-c m") #'git-messenger:popup-message)

;; Restore first N buffers eagerly
(setq desktop-restore-eager 20)

;; Restore window layout
(setq desktop-restore-frames t)

;; Ignore some buffers (optional)
(setq desktop-buffers-not-to-save "^\\*") ;; skip special buffers

;; Activate desktop save mode
(desktop-save-mode 1)

;; Optional: autosave desktop every 5 minutes
(run-at-time "5 min" 300 'desktop-save-in-desktop-dir)
;; Include *scratch* and other unsaved buffers
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history     . 100)
                (grep-history          . 30)
                (compile-history       . 30)
                (query-replace-history . 30)
                (register-alist        . 30)
                (kill-ring             . 50)
                (search-ring           . 30)
                (regexp-search-ring    . 30)
                (recentf-list          . 100)
                (desktop-saved-buffer-name-list . 50)
                )
              desktop-globals-to-save))



;; UI Configuration
(set-face-attribute 'default nil :font "JetBrainsMonoNL-Italic")

;; Optional: Fixed-pitch for programming
(set-face-attribute 'fixed-pitch nil :font "JetBrainsMonoNL-Italic")

;; Optional: Variable-pitch for prose
(set-face-attribute 'variable-pitch nil :font "SF Pro Text-16" :weight 'light)

;; ABOVE IS STABLE
;; Ignore node_modules and .webpack
(dolist (dir '("node_modules" ".webpack"))
  (add-to-list 'grep-find-ignored-directories dir))

(require 'multiple-cursors)

(global-set-key (kbd "C-c l") 'mc/edit-lines)
(global-set-key (kbd "C-.") 'mc/mark-next-like-this)
(global-set-key (kbd "C-,") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-,") 'mc/mark-all-like-this)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

