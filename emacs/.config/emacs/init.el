;; -*- lexical-binding: t; -*-

;; TODO
;; bash shellcheck
;; LaTeX schreiben, Export
;; ChatGPT für Elja

(use-package modus-themes
  :ensure t
  :demand t
  :custom
  (modus-themes-custom-auto-reload t)
  (modus-themes-disable-other-themes t)

  (modus-themes-bold-constructs t)

  (modus-themes-italic-constructs t)

  (modus-themes-to-toggle
   '(modus-operandi modus-vivendi))
  (modus-themes-to-rotate
   modus-themes-items)

  (modus-themes-mixed-fonts t)

  (modus-themes-prompts '(bold))
  (modus-themes-completions nil)
  (modus-themes-headings
   '(
     (0 . (variable-pitch 1.296))
     (1 . (variable-pitch 1.215))
     (2 . (variable-pitch 1.138))
     (3 . (variable-pitch 1.067))
     (t . (variable-pitch 1.0))

     (agenda-date . (variable-pitch light 1.138))
     (agenda-structure . (variable-pitch 1.215))))

  (modus-themes-variable-pitch-ui t)

  (modus-themes-common-palette-overrides
   '(
     (border-mode-line-active bg-mode-line-active)
     (border-mode-line-inactive bg-mode-line-inactive)
     ))
  :init
  (load-theme 'modus-operandi :no-confirm)

  (defun oe/change-appearance (to)
    "Change theme based on TO

TO can be \\='light or \\='dark"
    (pcase to
      ('light (load-theme 'modus-operandi-tinted t))
      ('dark (load-theme 'modus-vivendi-tinted t))))
  
  (add-hook 'ns-system-appearance-change-functions #'oe/change-appearance))

(use-package emacs
  :ensure nil
  :custom
  (gc-cons-threshold most-positive-fixnum)
  (gc-cons-percentage 1.0)
  (inhibit-startup-message t)
  (inhibit-compacting-font-caches t)
  (frame-resize-pixelwise t)
  (mac-option-modifier 'none)
  (mac-function-modifier 'meta)
  (default-input-method "MacOSX")
  (custom-file (locate-user-emacs-file "custom.el"))
  (default-frame-alist
   (append '((left-fringe . 0)
	     (right-fringe . 0)
	     (internal-border-width . 8)
	     (ns-transparent-titlebar t))
	   ()))
  (recentf-exclude '(".excluded"))
  (recentf-max-menu-items 10)
  (recentf-max-saved-items 10)
  (calendar-week-start-day 1)
  (delete-by-moving-to-trash t)
  (mac-system-move-file-to-trash-use-finder t)
  ;; (global-auto-revert-mode t)
  (backup-directory-alist '(("." . "~/emacs-backups")))
  (enable-recursive-minibuffers t)
  :config
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil
		      :family "JetBrainsMono Nerd Font"
		      :height 140)
  (set-face-attribute 'fixed-pitch nil
		      :family (face-attribute 'default :family))
  (set-face-attribute 'variable-pitch nil
		      :family "SF Pro"
		      :height 140)
  (desktop-save-mode)
  (recentf-mode)
  (pixel-scroll-mode)

  :init
  (setq-default line-spacing 0.15)
  
  (require 'package)
  (add-to-list 'package-archives
	       '("melpa" . "https://melpa.org/packages/"))

  (defun oe/reload-config ()
    "Reload the init.el file"
    (interactive)
    (load-file user-init-file)
    (oe/change-appearance ns-system-appearance)
    (message "Configuration reloaded"))

  (defun oe/add-to-path (paths)
    "Add existing directories from PATHS to exec-path and the environment path."
    (dolist (path paths)
      (let ((expanded-path (expand-file-name path)))
        (if (file-directory-p expanded-path)
      	  (progn
      	    (add-to-list 'exec-path expanded-path)
    	    (setenv "PATH" (concat expanded-path ":" (getenv "PATH")))
      	    (message "Added to path: %s" expanded-path))
      	(message "Path does not exist: %s" expanded-path)))))

  (oe/add-to-path '("~/nonexistant"
		    "/opt/homebrew/bin"
		    "~/.ghcup/bin"
		    "~/.pyenv/shims"
		    "/Library/TeX/texbin/"))

  (defun -oe/url-at-point ()
    "Return the URL at point, or nil if none is found."
    (let ((url-regexp "<?\\(https?://[[:alnum:]/._~%-]+\\)>?"))
      (when (thing-at-point-looking-at url-regexp)
	(match-string 1))))

  (defun oe/browse-incognito (url &rest _args)
    "Opens URL in an incognito Chrome instance.
Prompt for URL when called interactively."
    (interactive
     (list
      (or
       (-oe/url-at-point)
       (if (use-region-p)
	   (buffer-substring-no-properties (region-beginning) (region-end))) ; get selected text
       (read-string "Enter URL: "))))	; promp for URL if no region is selected
    (let ((browse-url-generic-program "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
	  (browse-url-generic-args '("--incognito")))
      (browse-url-generic url)))

  (defun oe/browse-url-handlers-safe-value-p (_val)
    "FIXME: write this fucntion"
    t)

  (put 'browse-url-handlers 'safe-local-variable
       'oe/browse-url-handlers-safe-value-p)

  (defun oe/kill-unsafe-buffers ()
    (interactive)
    (let ((buffers-to-kill
	   (seq-filter
	    (lambda (buffer)
	      (let ((name (buffer-name buffer)))
		(and name (string-match-p "gpg" name))))
	    (buffer-list))))
      (if buffers-to-kill
	  (progn
	    (dolist (buffer buffers-to-kill)
	      (kill-buffer buffer))
	    (message "Killed %d buffer(s) containing 'gpg' in their name." (length buffers-to-kill)))
	(message "No buffers found containing 'gpg' in their name")))
    (desktop-save user-emacs-directory))
  
  (defun oe/startup-message ()
    ""
    (message "Emacs loaded in %s with %d garbage collections."
	     (format "%.2f seconds"
		     (float-time
		      (time-subtract after-init-time before-init-time)))
	     gcs-done))

  (defun oe/olivetti-body-width-safe-value-p (val)
    (and
     (integerp val)
     (>= val 80)
     (<= val 120)))

  (put 'olivetti-body-width 'safe-local-variable
       'oe/olivetti-body-width-safe-value-p)

  (if (executable-find "gls")
      (setq insert-directory-program "gls")
    (message "Please install GNU coreutils via `brew install coreutils`"))
  
  :hook
  (emacs-startup . (lambda ()
		     (setq gc-cons-threshold (* 100 1024 1024))
		     (setq gc-cons-percentage 0.2)
		     (oe/startup-message)))
  (kill-emacs . oe/kill-unsafe-buffers)
  
  :bind
  (("s-." . (lambda () (interactive) (find-file user-init-file)))
   ("s-r" . oe/reload-config)
   ("C-c r" . recentf-open-files)))

(use-package autorevert
  :ensure nil
  :custom
  (auto-revert-verbose t)
  :hook
  (after-init . global-auto-revert-mode))

(use-package dired
  :ensure nil
  :hook
  (dired-mode . dired-hide-details-mode))

(use-package server
  :ensure nil
  :defer 1
  :config
  (unless (server-running-p)
    (server-start)))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :after vertico
  :config
  (marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  :init
  (global-corfu-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook
  (prog-mode . rainbow-delimiters-mode))

(use-package yasnippet
  :ensure t)

(use-package eglot
  :ensure t
  :init
  (defun oe/eglot-ensure ()
    "Fixme: document"
    (unless (member major-mode '(emacs-lisp-mode))
      (eglot-ensure)))
  :hook
  (prog-mode . oe/eglot-ensure))

(if (executable-find "rg")
    (use-package rg
      :ensure t
      :demand t				; this ensures that the docstring is
					; available without running the
					; function, first.
      :init
      (defun oe/rg-folding ()
	"Enable outline-minor-mode on file entries in rg.el results."
	(setq-local outline-regexp "^File: ")
	(outline-minor-mode t))
      :hook
      (rg-filter . oe/rg-folding)
      :bind
      (:map rg-mode-map
	    ("<tab>" . outline-cycle)))
  (message "Please install ripgrep via `brew install rg`"))
		     
(use-package which-key
  :ensure t
  :custom
  (which-key-idle-delay 0.2)
  :delight
  :config
  (which-key-mode))

(use-package org
  :custom
  (org-return-follows-link t)
  ;; (org-blank-before-new-entry '((heading . t) (plain-list-item . auto)))
  :commands
  (org-mode)
  :config
  (require 'org-mouse)
  (use-package ob-swift
    :ensure t)
  (use-package ob-swiftui
    :ensure t)
  (use-package haskell-mode
    :ensure t)
  (require 'org-tempo)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (C . t)
     (haskell . t)
     (swift . t)
     (swiftui . t)
     (python . t)
     (groovy . t)
     (java . t)
     (latex . t)))
  (dolist (template
	   '(("el" . "src emacs-lisp")
	     ("sh" . "src shell")
	     ("cl" . "src C :includes '(stdio.h) :flags -std=c90")
	     ("cpp" . "src C++ :includes '(iostream) :flags -std=c++23")
	     ("hs" . "src haskell")
	     ("sw" . "src swift")
	     ("swui" . "src swiftui")
	     ("py" . "src python")
	     ("gr" . "src groovy")
	     ("ja" . "src java")
	     ("la" . "src latex")))
    (add-to-list 'org-structure-template-alist template)))

(use-package olivetti
  :ensure t
  :custom
  (olivetti-body-width 80)
  :hook
  (org-mode . olivetti-mode))

(use-package magit
  :ensure t)

(use-package reveal-in-osx-finder
  :ensure t
  :commands
  (reveal-in-osx-finder)
  :bind
  ("C-c f" . reveal-in-osx-finder))

(use-package chatgpt-shell
  :ensure t
  :commands
  (chatgpt-shell-prompt-compose)	; should not be necessary
  :custom
  (chatgpt-shell-openai-key
   (lambda ()
     (auth-source-pick-first-password 'secret "openai-key"))))

(use-package denote
  :ensure t
  :load-path "local/denote/"		; FIXME: Let's go with git for now.
  :defer t
  :custom
  (denote-directory (expand-file-name "~/denote"))
  (denote-known-keywords nil)
  :hook
  (dired-mode . denote-dired-mode)
  :bind
  ( :map global-map
    ("C-c n n" . denote-open-or-create)
    ("C-c n r" . denote-rename-file)

    :map text-mode-map
    ("C-c n i" . denote-link-or-create)))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))
