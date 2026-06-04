;;; config.el -*- lexical-binding: t; -*-

(setq user-full-name "skydive420dz"
      user-mail-address "r0liveira@icloud.com")

(load-file (expand-file-name "theme.el" doom-user-dir))

(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 16)
      doom-variable-pitch-font (font-spec :family "Inter" :size 16)
      doom-theme (sk/current-doom-theme)
      display-line-numbers-type 'relative)

(sk/load-sky-theme)

(add-to-list 'default-frame-alist '(alpha-background . 98))
(add-to-list 'default-frame-alist '(alpha . 98))
(set-frame-parameter nil 'alpha-background 98)
(set-frame-parameter nil 'alpha 98)
(setq frame-resize-pixelwise t)

(setq fancy-splash-image (expand-file-name "assets/emacs-logo.png" doom-user-dir))

(defconst sk/terminal-frame-colors
  '((background . "color-234")
    (foreground . "color-255")
    (mode-line . "color-235")
    (mode-line-inactive . "color-233")
    (muted . "color-245")
    (border . "color-237"))
  "256-color-safe fallback colors for terminal Emacs frames.")

(defun sk/terminal-frame-color (name)
  (alist-get name sk/terminal-frame-colors))

(defun sk/terminal-frame-direct-color-p (frame)
  (> (display-color-cells frame) 256))

(defun sk/frame-color (frame sky-color fallback-color)
  (if (sk/terminal-frame-direct-color-p frame)
      (sk/theme-color sky-color)
    (sk/terminal-frame-color fallback-color)))

(defun sk/apply-terminal-frame-theme (&optional frame)
  (let ((target-frame (or frame (selected-frame))))
    (with-selected-frame target-frame
      (unless (display-graphic-p)
        (set-frame-parameter target-frame 'background-color (sk/frame-color target-frame 'background 'background))
        (set-frame-parameter target-frame 'foreground-color (sk/frame-color target-frame 'foreground 'foreground))
        (set-face-background 'default (sk/frame-color target-frame 'background 'background) target-frame)
        (set-face-foreground 'default (sk/frame-color target-frame 'foreground 'foreground) target-frame)
        (set-face-background 'mode-line (sk/frame-color target-frame 'surface 'mode-line) target-frame)
        (set-face-foreground 'mode-line (sk/frame-color target-frame 'foreground 'foreground) target-frame)
        (set-face-background 'mode-line-inactive (sk/frame-color target-frame 'background-alt 'mode-line-inactive) target-frame)
        (set-face-foreground 'mode-line-inactive (sk/frame-color target-frame 'muted 'muted) target-frame)
        (set-face-background 'vertical-border (sk/frame-color target-frame 'border 'border) target-frame)
        (set-face-foreground 'vertical-border (sk/frame-color target-frame 'border 'border) target-frame)))))

(add-hook 'after-make-frame-functions #'sk/apply-terminal-frame-theme)
(sk/apply-terminal-frame-theme)

(setq-default indent-tabs-mode nil
              tab-width 2)
(setq standard-indent 2)
(electric-indent-mode 1)

(setq-default c-basic-offset 2
              css-indent-offset 2
              js-indent-level 2
              sh-basic-offset 2)

(after! lua-mode
  (setq lua-indent-level 2))

(after! qml-mode
  (setq qml-indent-level 2))

(after! rust-mode
  (setq rust-indent-offset 2))

(setq ispell-dictionary "en_US"
      ispell-local-dictionary "en_US"
      ispell-program-name "aspell"
      ispell-personal-dictionary (expand-file-name "spell/en_US.pws" doom-user-dir)
      ispell-extra-args '("--sug-mode=ultra"))

(defun sk/disable-line-numbers ()
  (display-line-numbers-mode -1))

(defun sk/add-disable-line-numbers-hook (hook)
  (remove-hook hook #'sk/disable-line-numbers)
  (add-hook hook #'sk/disable-line-numbers t))

(map! :leader
      :desc "Reload Sky theme"
      "h r t" #'sk/load-sky-theme)

(dolist (hook '(org-mode-hook
                doom-docs-org-mode-hook
                markdown-mode-hook
                text-mode-hook
                dired-mode-hook
                help-mode-hook
                helpful-mode-hook
                Info-mode-hook))
  (sk/add-disable-line-numbers-hook hook))

(after! evil-snipe
  (evil-snipe-mode -1)
  (evil-snipe-override-mode -1))

(after! evil-escape
  (evil-escape-mode -1))

(after! evil
  (define-key evil-normal-state-map (kbd "s") #'evil-substitute)
  (define-key evil-normal-state-map (kbd "S") #'evil-change-whole-line))

(after! evil-org
  (map! :map evil-org-mode-map
        :n "[[" #'org-previous-visible-heading
        :n "]]" #'org-next-visible-heading))

(after! which-key
  (setq which-key-idle-delay 0.25
        which-key-idle-secondary-delay 0.05))

(after! corfu
  (setq corfu-auto t
        corfu-auto-delay 0.05
        corfu-auto-prefix 2
        corfu-cycle t
        corfu-preview-current nil)
  (global-corfu-mode 1))

(after! cape
  (defun sk/add-cape-completions ()
    "Add general completion sources for buffers without rich LSP data."
    (add-hook 'completion-at-point-functions #'cape-file 10 t)
    (add-hook 'completion-at-point-functions #'cape-dabbrev 20 t)
    (add-hook 'completion-at-point-functions #'cape-keyword 30 t))

  (dolist (hook '(prog-mode-hook
                  conf-mode-hook
                  text-mode-hook))
    (add-hook hook #'sk/add-cape-completions)))

(after! lsp-mode
  (setq lsp-completion-provider :none
        lsp-idle-delay 0.15)
  (add-to-list 'lsp-disabled-clients 'glslls)
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("glsl_analyzer" "--stdio"))
    :activation-fn (lsp-activate-on "glsl")
    :server-id 'glsl-analyzer)))

(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right)

(after! vterm
  (map! :map vterm-mode-map
        :i "C-h" #'evil-window-left
        :i "C-j" #'evil-window-down
        :i "C-k" #'evil-window-up
        :i "C-l" #'evil-window-right))

(set-popup-rule! "^\\*\\(?:doom:vterm-popup\\|vterm\\|terminal\\|term\\|shell\\|eshell\\).*\\*$"
  :side 'bottom :size 0.32 :select t :quit nil :ttl nil)

(set-popup-rule! "^\\*\\(?:Help\\|helpful\\|Apropos\\|Info\\|Warnings\\|Messages\\).*\\*$"
  :side 'right :size 0.42 :select t :quit t :ttl nil)

(set-popup-rule! "^\\*\\(?:xref\\|Occur\\|grep\\|rg\\|compilation\\|Flycheck errors\\).*\\*$"
  :side 'bottom :size 0.30 :select t :quit nil :ttl nil)

(setq xref-search-program 'ripgrep
      grep-command "rg -nS --no-heading ")

(defvar sk/centered-text-width 96
  "Target text width for centered prose buffers.")

(defun sk/centered-text-adjust-margins ()
  (when sk/centered-text-mode
    (let ((margin (max 0 (truncate (/ (- (window-width) sk/centered-text-width) 2.0)))))
      (set-window-margins nil margin margin))))

(define-minor-mode sk/centered-text-mode
  "Center prose buffers with window margins."
  :lighter " Center"
  (if sk/centered-text-mode
      (progn
        (visual-line-mode 1)
        (add-hook 'window-configuration-change-hook #'sk/centered-text-adjust-margins nil t)
        (sk/centered-text-adjust-margins))
    (remove-hook 'window-configuration-change-hook #'sk/centered-text-adjust-margins t)
    (set-window-margins nil nil nil)))

(dolist (hook '(org-mode-hook
                doom-docs-org-mode-hook
                markdown-mode-hook
                text-mode-hook))
  (add-hook hook #'sk/centered-text-mode))

(defun sk/project-root ()
  "Return the current Projectile project root, or nil outside a project."
  (when (bound-and-true-p projectile-mode)
    (ignore-errors (projectile-project-root))))

(defun sk/project-vterm ()
  "Open vterm from the project root when possible."
  (interactive)
  (let ((default-directory (or (sk/project-root) default-directory)))
    (+vterm/here)))

(defun sk/project-notes ()
  "Open the dotfiles project notes."
  (interactive)
  (find-file (expand-file-name "org/dotfiles.org" doom-user-dir)))

(map! :leader
      (:prefix ("s" . "search")
       :desc "Symbols in buffer" "i" #'consult-imenu
       :desc "Symbols in open buffers" "I" #'consult-imenu-multi)
      (:prefix ("p" . "project")
       :desc "Find file" "f" #'projectile-find-file
       :desc "Search project" "s" #'projectile-ripgrep
       :desc "Switch project" "p" #'projectile-switch-project
       :desc "Magit status" "g" #'magit-status
       :desc "Project terminal" "t" #'sk/project-vterm
       :desc "Project notes" "n" #'sk/project-notes))

(use-package! flycheck-inline
  :after flycheck
  :hook (flycheck-mode . flycheck-inline-mode)
  :config
  (setq flycheck-inline-display-function
        #'flycheck-inline-display-inline))

(after! doom-modeline
  (setq doom-modeline-height 28
        doom-modeline-bar-width 4
        doom-modeline-window-width-limit 80
        doom-modeline-buffer-file-name-style 'relative-to-project
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-vcs-max-length 24
        doom-modeline-modal-icon nil
        doom-modeline-enable-word-count nil)
  (sk/load-sky-theme))

(use-package! rainbow-mode
  :hook ((css-mode
          css-ts-mode
          emacs-lisp-mode
          js-mode
          js-ts-mode
          json-mode
          json-ts-mode
          lua-mode
          lua-ts-mode
          nix-mode
          nix-ts-mode
          org-mode
          qml-mode
          qml-ts-mode
          typescript-mode
          typescript-ts-mode
          web-mode) . rainbow-mode))

(use-package! indent-bars
  :hook ((prog-mode conf-mode) . indent-bars-mode)
  :config
  (setq indent-bars-color '(highlight :face-bg t :blend 0.18)
        indent-bars-color-by-depth nil
        indent-bars-highlight-current-depth nil
        indent-bars-display-on-blank-lines nil
        indent-bars-pattern "."
        indent-bars-width-frac 0.12
        indent-bars-pad-frac 0.12))

(after! evil-goggles
  (setq evil-goggles-duration 0.18
        evil-goggles-pulse nil)
  (sk/load-sky-theme))

(after! avy
  (sk/load-sky-theme))

(setq org-directory (expand-file-name "org" doom-user-dir)
      org-agenda-files (list org-directory)
      org-default-notes-file (expand-file-name "inbox.org" org-directory)
      org-startup-indented t
      org-hide-emphasis-markers t
      org-log-done 'time
      org-image-actual-width nil)

(setq org-capture-templates
      '(("t" "Todo" entry
         (file+headline "inbox.org" "Inbox")
         "* TODO %?\n  %U\n")
        ("q" "Quickshell note" entry
         (file+headline "quickshell.org" "Notes")
         "* %?\n  %U\n")
        ("d" "Dotfiles note" entry
         (file+headline "dotfiles.org" "Notes")
         "* %?\n  %U\n")))

(after! org
  (setq org-ellipsis "")
  (require 'org-tempo)
  (dolist (template '(("sh" . "src sh")
                      ("el" . "src emacs-lisp")
                      ("nix" . "src nix")
                      ("lua" . "src lua")
                      ("qml" . "src qml")
                      ("rs" . "src rust")
                      ("c" . "src c")
                      ("json" . "src json")
                      ("yaml" . "src yaml")))
    (setq org-structure-template-alist
          (assoc-delete-all (car template) org-structure-template-alist))
    (add-to-list 'org-structure-template-alist template))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (emacs-lisp . t)
     (lua . t)
     (rust . t)
     (shell . t))))

(setq vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=Off"
      vterm-always-compile-module t
      vterm-shell "zsh"
      dired-listing-switches "-alh --group-directories-first"
      delete-by-moving-to-trash t)

(after! dired
  (setq dired-dwim-target t
        dired-kill-when-opening-new-dired-buffer t
        dired-omit-verbose nil)
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'hl-line-mode)
  (map! :map dired-mode-map
        :n "h" #'dired-up-directory
        :n "l" #'dired-find-file
        :n "RET" #'dired-find-file))

(after! vterm
  (sk/load-sky-theme)
  (add-hook 'vterm-mode-hook #'evil-insert-state)
  (sk/add-disable-line-numbers-hook 'vterm-mode-hook))

(dolist (hook '(term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (sk/add-disable-line-numbers-hook hook))

;; A function for easily creating multiple buffers of 'eshell'.
;; NOTE: `C-u M-x eshell` would also create new 'eshell' buffers.
(defun eshell-new (name)
  "Create new eshell buffer named NAME."
  (interactive "sName: ")
  (setq name (concat "$" name))
  (eshell)
  (rename-buffer name))

(use-package! eshell-syntax-highlighting
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
      eshell-visual-commands '("bash" "fish" "ssh" "top" "zsh"))

(after! corfu
  (add-hook 'eshell-mode-hook (lambda () (corfu-mode -1))))

(after! apheleia
  (setq +format-on-save-disabled-modes
        '(org-mode
          doom-docs-org-mode
          markdown-mode
          text-mode
          vterm-mode))
  (setf (alist-get 'c-mode apheleia-mode-alist) 'clang-format
        (alist-get 'c-ts-mode apheleia-mode-alist) 'clang-format
        (alist-get 'c++-mode apheleia-mode-alist) 'clang-format
        (alist-get 'c++-ts-mode apheleia-mode-alist) 'clang-format
        (alist-get 'lua-mode apheleia-mode-alist) 'stylua
        (alist-get 'nix-mode apheleia-mode-alist) 'nixfmt
        (alist-get 'nix-ts-mode apheleia-mode-alist) 'nixfmt
        (alist-get 'qml-mode apheleia-mode-alist) 'qmlformat
        (alist-get 'rust-mode apheleia-mode-alist) 'rustfmt
        (alist-get 'rust-ts-mode apheleia-mode-alist) 'rustfmt
        (alist-get 'sh-mode apheleia-mode-alist) 'shfmt)
  (setf (alist-get 'qmlformat apheleia-formatters)
        '("qmlformat" "--indent-width" "2" "-w" "-1" filepath)))

(after! lsp-mode
  (require 'lsp-qml)
  (setq lsp-clients-lua-language-server-command '("lua-language-server")
        lsp-nix-nil-auto-eval-inputs t
        lsp-qml-server-command "qmlls-wrapped")
  (lsp-register-custom-settings
   '(("nil.nix.flake.autoArchive" t t)))
  (add-hook 'qml-mode-hook #'lsp-deferred)
  (add-to-list 'lsp-language-id-configuration '(org-mode . "org"))
  (add-to-list 'lsp-language-id-configuration '(doom-docs-org-mode . "org"))
  (add-to-list 'lsp-language-id-configuration '(markdown-mode . "markdown"))
  (add-to-list 'lsp-language-id-configuration '(text-mode . "plaintext"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("harper-ls" "--stdio"))
    :activation-fn (lsp-activate-on "org" "markdown" "plaintext")
    :server-id 'harper-ls))
  (dolist (hook '(org-mode-hook doom-docs-org-mode-hook markdown-mode-hook text-mode-hook))
    (add-hook hook #'lsp-deferred)))

(after! lsp-pyright
  (setq lsp-pyright-langserver-command "basedpyright"))

(after! magit
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))
