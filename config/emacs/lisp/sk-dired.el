;;; sk-dired.el --- File management -*- lexical-binding: t; -*-

(defun sk/dired-next-line ()
  "Move to the next Dired line and refresh preview immediately."
  (interactive)
  (dired-next-line 1)
  (when (bound-and-true-p dired-preview-mode)
    (dired-preview-trigger :no-delay)))

(defun sk/dired-previous-line ()
  "Move to the previous Dired line and refresh preview immediately."
  (interactive)
  (dired-previous-line 1)
  (when (bound-and-true-p dired-preview-mode)
    (dired-preview-trigger :no-delay)))

(use-package dired
  :ensure nil
  :config
  (setq dired-kill-when-opening-new-dired-buffer t
        dired-listing-switches "-alh --group-directories-first"
        delete-by-moving-to-trash t)
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'hl-line-mode)
  (add-hook 'dired-mode-hook
            (lambda ()
              (when (fboundp 'evil-local-set-key)
                (evil-local-set-key 'normal (kbd "h") #'dired-up-directory)
                (evil-local-set-key 'normal (kbd "j") #'sk/dired-next-line)
                (evil-local-set-key 'normal (kbd "k") #'sk/dired-previous-line)
                (evil-local-set-key 'normal (kbd "l") #'dired-find-file)
                (evil-local-set-key 'normal (kbd "RET") #'dired-find-file)
                (evil-local-set-key 'normal (kbd "SPC m h") #'dired-omit-mode)
                (evil-local-set-key 'normal (kbd "SPC m p") #'dired-preview-mode)))))

(use-package dired-preview
  :after dired
  :commands (dired-preview-mode dired-preview-global-mode)
  :config
  (setq dired-preview-delay 0.15
        dired-preview-display-action-alist
        '((display-buffer-in-side-window)
          (side . bottom)
          (window-height . 0.12)
          (preserve-size . (nil . t)))
        dired-preview-max-size (expt 2 25)
        dired-preview-image-extensions-regexp
        "\\.\\(png\\|jpe?g\\|webp\\|gif\\|tiff?\\|svg\\|xpm\\|xbm\\|pbm\\)\\'"
        dired-preview-ignored-extensions-regexp
        (concat "\\."
                "\\(gz\\|zst\\|tar\\|xz\\|rar\\|zip\\|iso\\|epub\\)"
                "\\'")
        dired-preview-trigger-commands
        '(dired-next-line
          dired-previous-line
          dired-flag-file-deletion
          dired-mark
          dired-unmark
          dired-unmark-backward
          dired-del-marker
          dired-goto-file
          dired-find-file
          evil-next-line
          evil-previous-line
          evil-next-visual-line
          evil-previous-visual-line
          next-line
          previous-line
          scroll-up-command
          scroll-down-command)))

(provide 'sk-dired)

;;; sk-dired.el ends here
