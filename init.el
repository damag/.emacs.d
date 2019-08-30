(setq custom-safe-themes '("c9809fdb29cfdcb5c0c126e4f6e0e8d23281a2e9964bdefc5776b8560f39bcc1" default))
(load-theme 'delight)

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(eval-when-compile (require 'use-package))

(set-frame-parameter nil 'undecorated t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(tool-bar-mode 0)
(menu-bar-mode 0)
(split-window-horizontally)
(setq split-height-threshold nil)
(setq split-width-threshold nil)
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq column-number-mode t)
(setq initial-major-mode 'text-mode)
(add-hook 'text-mode-hook 'visual-line-mode)
(add-hook 'text-mode-hook 'flyspell-mode)

(fset 'yes-or-no-p 'y-or-n-p)
(setq make-backup-files nil)
(server-start)

(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-x k") 'kill-this-buffer)
(global-set-key (kbd "C-c C-f") 'ff-find-other-file)
(global-set-key (kbd "C-c m") 'man-follow)
(global-set-key (kbd "C-c c") 'recompile)

(use-package magit)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)

(setq compile-command "ninja -C $(git rev-parse --show-toplevel || echo .)/build")
(setq electric-pair-mode t)
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq c-default-style
      (quote
       ((c-mode . "linux")
	(java-mode . "java")
	(awk-mode . "awk")
	(other . "linux"))))
(add-hook 'c-mode-hook '(lambda () (setq show-trailing-whitespace t)))
(add-hook 'python-mode-hook '(lambda () (setq show-trailing-whitespace t)))

(defun yank-and-indent ()
  "Yank and then indent the newly formed region according to mode."
  (interactive)
  (yank)
  (call-interactively 'indent-region))
(global-set-key (kbd "C-y") 'yank-and-indent)

(ido-mode 1)
(ido-everywhere 1)
(setq ido-enable-flex-matching t)
;; disable auto searching for files unless called explicitly
(setq ido-auto-merge-delay-time 99999)
(define-key ido-file-dir-completion-map (kbd "C-c C-s")
  (lambda()
    (interactive)
    (ido-initiate-auto-merge (current-buffer))))

(require 'use-package-ensure)
(setq use-package-always-ensure t)

(use-package which-key
  :config
  (which-key-mode))

(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

;; Rtags
(use-package rtags)
(require 'rtags)
(rtags-enable-standard-keybindings)
(define-key c-mode-base-map (kbd "M-.")
  (function rtags-find-symbol-at-point))
(define-key c-mode-base-map (kbd "M-,")
  (function rtags-find-references-at-point))
(define-key c-mode-base-map (kbd "M-[")
  (function rtags-location-stack-back))
(define-key c-mode-base-map (kbd "M-]")
  (function rtags-location-stack-forward))

;; Irony
(use-package company-irony)
(add-hook 'after-init-hook 'global-company-mode)
;; (eval-after-load 'company
;;   '(add-to-list 'company-backends 'company-irony))
(eval-after-load 'company
  '(add-to-list
    'company-backends 'company-irony))
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(add-hook 'irony-mode-hook 'irony-eldoc)

;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)

(setq company-idle-delay 0)

;; Disaster
(use-package disaster)
(require 'disaster)
(define-key c-mode-base-map (kbd "C-c d") 'disaster)


;; pkgbuild
(use-package pkgbuild-mode)
(autoload 'pkgbuild-mode "pkgbuild-mode.el" "PKGBUILD mode." t)
(setq auto-mode-alist (append '(("/PKGBUILD$" . pkgbuild-mode))
			      auto-mode-alist))

;; Python
(use-package elpy)
(elpy-enable)
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")

;; Web
(use-package web-mode)
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  ;; (setq web-mode-markup-indent-offset 2)
  (setq-default indent-tabs-mode nil))
(add-hook 'web-mode-hook 'my-web-mode-hook)

;; Dart
(use-package dart-mode)
(setq dart-enable-analysis-server t)

;; Go
(use-package go-eldoc)
(require 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)
(add-hook 'go-mode-hook (lambda ()
			  (set (make-local-variable 'company-backends) '(company-go))
			  (company-mode)))
(add-hook 'go-mode-hook (lambda ()
			  (local-set-key (kbd "M-.") 'godef-jump)
			  (local-set-key (kbd "C-x 4 M-.") 'godef-jump-other-window)
			  (local-set-key (kbd "C-c C-d") 'godoc-at-point)))
(add-hook 'before-save-hook 'gofmt-before-save)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-golangci-lint-setup))


;; Language Server Protocol
;; (use-package company-lsp)
;; (push 'company-lsp company-backends)

;; Meson
(use-package meson-mode)
(add-hook 'meson-mode-hook 'company-mode)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (org flycheck-irony flycheck-golangci-lint lsp-clangd lsp-css lsp-go lsp-html lsp-python lsp-typescript company-lsp go-eldoc company-go omnisharp go-mode dart-mode elpy company-tern web-mode cmake-mode disaster which-key json-mode ein pkgbuild-mode meson-mode irony-eldoc company-irony company http magit rg))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
