;;; sk-core.el --- Core editor behavior -*- lexical-binding: t; -*-

(setq user-full-name "skydive420dz"
      user-mail-address "r0liveira@icloud.com")

(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      use-dialog-box nil
      confirm-kill-emacs #'y-or-n-p
      font-lock-maximum-decoration t
      treesit-font-lock-level 4
      read-process-output-max (* 1024 1024))

(fset #'yes-or-no-p #'y-or-n-p)

(setq backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t))
      create-lockfiles nil)

(make-directory (expand-file-name "backups/" user-emacs-directory) t)
(make-directory (expand-file-name "auto-save/" user-emacs-directory) t)

(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100)

(setq standard-indent 2)
(electric-pair-mode 1)
(electric-indent-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)

(provide 'sk-core)

;;; sk-core.el ends here
