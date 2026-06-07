;;; sk-git.el --- Git tools -*- lexical-binding: t; -*-

(use-package magit
  :commands magit-status
  :bind (("C-c g" . magit-status))
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (evil-collection-init 'magit))

(provide 'sk-git)

;;; sk-git.el ends here
