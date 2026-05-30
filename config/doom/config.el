;;; config.el -*- lexical-binding: t; -*-

(require 'org)
(require 'ob-tangle)

(let* ((config-org (expand-file-name "config.org" doom-user-dir))
       (config-cache-dir (expand-file-name ".local" doom-user-dir))
       (config-el (expand-file-name "config.el" config-cache-dir)))
  (make-directory config-cache-dir t)
  (when (file-newer-than-file-p config-org config-el)
    (org-babel-tangle-file config-org config-el "emacs-lisp"))
  (load-file config-el))
