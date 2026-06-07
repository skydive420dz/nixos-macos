;;; sk-languages.el --- Language modes -*- lexical-binding: t; -*-

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package nix-ts-mode
  :commands nix-ts-mode)

(use-package lua-mode
  :mode "\\.lua\\'")

(use-package qml-mode
  :mode "\\.qml\\'")

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package haskell-mode
  :mode "\\.hs\\'")

(use-package haskell-ts-mode
  :commands haskell-ts-mode)

(use-package typescript-mode
  :mode ("\\.ts\\'" "\\.tsx\\'"))

(use-package web-mode
  :mode "\\.html\\'")

(use-package json-mode
  :mode "\\.json\\'")

(use-package markdown-mode
  :mode "\\.md\\'")

(use-package markdown-ts-mode
  :commands markdown-ts-mode)

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package glsl-mode
  :mode "\\.glsl\\'")

(use-package yasnippet
  :demand t
  :config
  (setq yas-snippet-dirs (list (expand-file-name "snippets" sk/user-directory)))
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (define-key yas-minor-mode-map (kbd "<tab>") nil)
  (define-key yas-minor-mode-map (kbd "<backtab>") nil)
  (define-key yas-minor-mode-map (kbd "S-TAB") nil)
  (define-key yas-keymap (kbd "TAB") #'yas-next-field-or-maybe-expand)
  (define-key yas-keymap (kbd "<tab>") #'yas-next-field-or-maybe-expand)
  (define-key yas-keymap (kbd "<backtab>") #'yas-prev-field)
  (define-key yas-keymap (kbd "S-TAB") #'yas-prev-field)
  (yas-global-mode 1))

(provide 'sk-languages)

;;; sk-languages.el ends here
