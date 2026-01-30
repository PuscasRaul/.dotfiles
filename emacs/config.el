(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))

(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))

                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))

  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))


;;When installing a package used in the init file itself,
;;e.g. a package which adds a use-package key word,
;;use the :wait recipe keyword to block until that package is installed/configured.
;;For example:
;;(use-package general :ensure (:wait t) :demand t)
;; Expands to: (elpaca evil (use-package evil :demand t))

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  :config
  (evil-mode))


(use-package evil-collection
  :ensure t
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

;;Turns off elpaca-use-package-mode current declaration
;;Note this will cause evaluate the declaration immediately. It is not deferred.
;;Useful for configuring built-in emacs features.
(use-package emacs
  :ensure nil
  :config
  (setq ring-bell-function #'ignore))

(defun rp/flycheck-errors ()
  (interactive)
  (if (get-buffer-window "*Flycheck errors*")
      (delete-window (get-buffer-window "*Flycheck errors*"))
    (flycheck-list-errors))) 

(use-package general
  :ensure t
  :config
  (general-evil-setup)
    (general-define-key
     :states '(normal visual emacs)
     "K" 'lsp-ui-doc-glance
     "gd" 'lsp-ui-peek-find-definitions)

  (general-define-key
   :states '(normal visual emacs)
   "K" 'lsp-ui-doc-glance
   "gd" 'lsp-ui-peek-find-definitions)

  ;; SET SPC as leader key
  (general-create-definer rp/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (rp/leader-keys
    "b" '(:ignore t :wk "buffer")
    "bi" '(ibuffer :wk "ibuffer")
    "bb" '(switch-to-buffer :wk "Switch buffer")
    "bk" '(kill-current-buffer :wk "Kill this buffer")
    "bn" '(next-buffer :wk "Next buffer")
    "bp" '(previous-buffer :wk "Previous buffer")
    "br" '(revert-buffer :wk "Reload buffer"))

  (rp/leader-keys
    "e" '(:ignore t :wk "Evaluate")
    "eb" '(eval-buffer :wk "Evaluate elisp in buffer")
    "ed" '(eval-defun :wk "Evaluate defun containing or after point")
    "ee" '(eval-expression :wk "Evaluate elisp expression")
    "el" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "er" '(eval-region :wk "Evaluate elisp region"))

  (rp/leader-keys
    "." '(find-file :wk "Find file")
    "fc" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
    "fr" '(counsel-recentf :wk "Find recent files")
    "TAB TAB" '(comment-line :wk "Comment lines"))

  (rp/leader-keys
    "h" '(:ignore t :wk "Help")
    "hf" '(describe-function :wk "Describe function")
    "hv" '(describe-variable :wk "Describe variable")
    "hrr" '(reload-init-file :wk "Reload emacs config"))

  (rp/leader-keys
    "d" '(:ignore t :wk "Dired")
    "dd" '(dired :wk "Open dired")
    "dj" '(dired-jump :wk "Dired jump to current")
    "dn" '(neotree-dir :wk "Open directory in neotree")
    "dp" '(peep-dired :wk "Peep-dired"))

  (rp/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (rp/leader-keys
    "p" '(projectile-command-map :wk "Projectile"))

  (rp/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "te" '(eshell-toggle :wk "Toggle eshell")
    "tf" '(rp/flycheck-errors :wk "List errors")
    "tv" '(vterm-toggle :wk "Vterm toggle")
    "tn" '(neotree-toggle :wk "Toggle neotree file viewer")
    "tl" '(display-line-numbers-mode :wk "Toggle line numbers")
    "tt" '(visual-line-mode :wk "Toggle truncated lines"))
  
  (rp/leader-keys
    "p" '(:ignore t :wk "Fuzzy find")
	"pg" '(fzf-grep :wk "Fuzzy grep")
	"pf" '(fzf-find-file :wk "Fuzzy find file")
  )
  
  (rp/leader-keys
    "w" '(:ignore t :wk "Windows")
    "wc" '(evil-window-delete :wk "Close window")
    "wn" '(evil-window-new :wk "New window")
    "ws" '(evil-window-split :wk "Horizontal split window")
    "wv" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "wh" '(evil-window-left :wk "Window left")
    "wj" '(evil-window-down :wk "Window down")
    "wl" '(evil-window-right :wk "Window right")
    "wk" '(evil-window-up :wk "Window up")

    ;; Move windows
    "wH" '(buf-move-left :wk "Move window left")
    "wJ" '(buf-move-down :wk "Move window down")
    "wL" '(buf-move-right :wk "Move window right")
    "wK" '(buf-move-up :wk "Move window up"))
  )

(require 'windmove)
;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
  ;;  "Switches between the current buffer, and the buffer above the
  ;;  split, if possible."
  (interactive)

  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))


;;;###autoload

(defun buf-move-down ()
  "Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))
;;;###autoload

(defun buf-move-left ()
  "Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))
;;;###autoload

(defun buf-move-right ()
  "Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))

    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(use-package lsp-mode
  :ensure t
  :hook ((python-mode . lsp-deferred)
         (c-mode      . lsp-deferred)
         (c++-mode    . lsp-deferred)
	 (java-mode . lsp-deferred)
	 (csharp-mode . lsp-deferred)
         (rust-mode   . lsp-deferred))
  :custom
  ;; This is the magic line for pylsp + virtualenvs
  (lsp-pylsp-plugins-jedi-environment "./venv") 
  :config
  (setq lsp-pylsp-server-command '("pylsp")))

(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :config 
  (setq lsp-ui-doc-position 'bottom)
  :init (lsp-ui-mode t))

(use-package electric
  :config
  (electric-pair-mode 1))

(use-package company
  :ensure t
  :after lsp-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection)
              ("TAB" . company-complete-selection))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  :config
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-ui-doc-enable nil)
  (setq lsp-eldoc-enable-hover nil)   
  (global-company-mode t))

(use-package company-box
  :ensure t
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package dashboard
  :ensure t 
  :config
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner (concat user-emacs-directory "images/dtmacs-logo.png"))  ;; use custom image as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  (dashboard-modify-heading-icons '((recents . "file-text")
                                  (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package diminish :ensure t)

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode t)
  :config 
  (add-to-list 'display-buffer-alist
               `(,(rx bos "*Flycheck errors*" eos)
               (display-buffer-reuse-window
                display-buffer-in-side-window)
               (side            . bottom)
               (reusable-frames . visible)
               (window-height   . 0.25))))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(defun my/apply-fonts ()
  (interactive)
  (let ((my-font "JetBrainsMono Nerd Font"))
    (set-face-attribute 'default nil
                        :font my-font
                        :height 140
                        :weight 'medium)
    (set-face-attribute 'fixed-pitch nil
                        :font my-font
                        :height 130
                        :weight 'medium)
    ;; Ensure italics are set here too
    (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
    (set-face-attribute 'font-lock-keyword-face nil :slant 'italic)))
;; Apply to the current session
(add-hook 'after-init-hook #'my/apply-fonts)
;; Apply to any future frames (critical for emacsclient)
(add-hook 'server-after-make-frame-hook #'my/apply-fonts)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(use-package catppuccin-theme
  :ensure t
  :init
  (setq catppuccin-flavor 'mocha) ;; Options: 'latte, 'frappe, 'macchiato, or 'mocha
  :config
  (load-theme 'catppuccin t))

(use-package neotree
  :ensure t
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
  ;; truncate long file names in neotree
  (add-hook 'neo-after-create-hook
            #'(lambda (_)
  		(with-current-buffer (get-buffer neo-buffer-name)
                  (setq truncate-lines t)
                  (setq word-wrap nil)
                  (make-local-variable 'auto-hscroll-mode)
                  (setq auto-hscroll-mode nil)))))
(setq neo-smart-open t)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
(evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
(evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)
(evil-define-key 'normal neotree-mode-map (kbd "d") 'neotree-create-node)

(use-package counsel
  :ensure t
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :ensure t
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))
(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))
(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
              ivy-rich-switch-buffer-align-virtual-buffer t
              ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package toc-org
  :ensure t
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets :ensure t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(electric-indent-mode -1)

(require 'org-tempo)

(use-package projectile
  :ensure t
  :config
  (projectile-mode 1))

(use-package rainbow-mode
  :ensure t
  :diminish
  :hook 
  ((org-mode prog-mode) . rainbow-mode))

(use-package eshell-syntax-highlighting
  :ensure t
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))
;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.
(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm 
  :ensure t)
(setq shell-file-name "/usr/bin/zsh" 
      vterm-max-scrollback 5000)

(use-package vterm-toggle
  :ensure t
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 ;;(display-buffer-reuse-window display-buffer-in-direction)
                 ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                 ;;(direction . bottom)
                 ;;(dedicated . t) ;dedicated is supported in emacs27
                 (reusable-frames . visible)
                 (window-height . 0.3))))

(add-to-list 'default-frame-alist '(alpha-background . 90)) ; For all new frames henceforth

(use-package sudo-edit
  :ensure t
  :config 
  (rp/leader-keys
    "fu" '(sudo-edit-find-file :wk "Sudo find file")
    "fU" '(sudo-edit :wk "Sudo edit file")))

;;; Also have direnv installed through apt
(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))



(setq make-backup-files nil)     
(setq auto-save-default nil)

;; Minimal fix - just ensure directories exist
(make-directory "~/.emacs.d/auto-save" t)
(make-directory "~/.emacs.d/backups" t)

(setq backup-directory-alist '(("." . "~/.emacs.d/backups/")))
(setq auto-save-file-name-transforms 
      '((".*" "~/.emacs.d/auto-save/\\1" t)))
(setq create-lockfiles nil)



(use-package evil-multiedit
  :ensure t  
  :config
  (evil-multiedit-default-keybinds))

(use-package fzf
  :ensure t)
