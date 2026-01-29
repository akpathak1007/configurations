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
    magit))

;; Install missing packages automatically
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

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
  ("C-+" . origami-open-node-recursively)
  ("C-_" . origami-toggle-all-nodes))


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


;; Projectile project awareness
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


;; UI Configuration
(set-face-attribute 'default nil :font "JetBrainsMonoNL-Italic")

;; Optional: Fixed-pitch for programming
(set-face-attribute 'fixed-pitch nil :font "JetBrainsMonoNL-Italic")

;; Optional: Variable-pitch for prose
(set-face-attribute 'variable-pitch nil :font "SF Pro Text-16" :weight 'light)


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

