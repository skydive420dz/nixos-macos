;;; init.el -*- lexical-binding: t; -*-

(doom! :input
       :completion
       company
       vertico

       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       vc-gutter
       vi-tilde-fringe
       window-select
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets

       :emacs
       dired
       electric
       ibuffer
       undo
       vc

       :term
       vterm

       :checkers
       syntax
       spell

       :tools
       (eval +overlay)
       lookup
       lsp
       magit

       :lang
       emacs-lisp
       cc
       (json +tree-sitter)
       (lua +tree-sitter)
       markdown
       (nix +tree-sitter)
       (org +pretty)
       (qt +lsp)
       (rust +lsp +tree-sitter)
       (sh +tree-sitter)
       (yaml +tree-sitter)

       :config
       (default +bindings +smartparens))
