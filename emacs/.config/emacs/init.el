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

  ;; list of possible font weights
  ;; thin ultralight extralight light semilight regular
  ;; medium semibold bold bold heavy extrabold ultrabold
  (modus-themes-prompts '(bold))
  (modus-themes-completions nil)
  (modus-themes-headings
   '(
     (0 . (1.296))
     (1 . (1.215))
     (2 . (1.138))
     (3 . (1.067))
     (t . (1.0))

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

TO can be 'light or 'dark"
    (pcase to
      ('light (load-theme 'modus-operandi-tinted t))
      ('dark (load-theme 'modus-vivendi-tinted t)))
    (desktop-save user-emacs-directory))
  
  (add-hook 'ns-system-appearance-change-functions #'oe/change-appearance))

(use-package emacs
  :ensure nil
  :custom
  (inhibit-startup-message t)
  (mac-option-modifier 'none)
  (mac-function-modifier 'meta)
  (default-input-method "MacOSX")
  (custom-file (locate-user-emacs-file "custom.el"))
  (default-frame-alist
   (append '((left-fringe . 0)
	     (right-fringe . 0)
	     (internal-border-width . 8))
	   ()))
  :config
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font:size=14")
  (set-face-attribute 'fixed-pitch nil :font (face-attribute 'default :font))
  (desktop-save-mode)
  (desktop-read)

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

  :bind
  ("s-r" . oe/reload-config))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :init
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

(if (executable-find "rg")
    (use-package rg
      :ensure t)
  (message "Please install ripgrep via `brew install rg`"))
		     
