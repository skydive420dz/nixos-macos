;;; sk-git.el --- Git tools -*- lexical-binding: t; -*-

(use-package with-editor
  :defer t
  :config
  (when-let ((emacsclient (or (executable-find "emacsclient")
                              (let ((candidate (expand-file-name "emacsclient"
                                                                 invocation-directory)))
                                (and (file-executable-p candidate) candidate)))))
    (setq with-editor-emacsclient-executable emacsclient)))

(use-package magit
  :commands magit-status
  :bind (("C-c g" . magit-status))
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (evil-collection-init 'magit))

(provide 'sk-git)

;;; sk-git.el ends here
