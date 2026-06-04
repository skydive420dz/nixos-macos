;;; init.el -*- lexical-binding: t; -*-

(doom! :input
       :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       (vc-gutter +pretty)
       vi-tilde-fringe
       window-select
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       snippets

       :emacs
       dired
       electric
       eww
       ibuffer
       undo
       vc

       :term
       eshell
       vterm

       :checkers
       syntax
       spell

       :tools
       (eval +overlay)
       lookup
       lsp
       magit
       tree-sitter

       :lang
       (haskell +lsp)
       emacs-lisp
       (cc +lsp)
       (json +lsp +tree-sitter)
       (javascript +lsp +tree-sitter)
       (lua +lsp +tree-sitter)
       (markdown +lsp)
       (nix +lsp +tree-sitter)
       (org +pretty)
       (python +lsp +pyright +tree-sitter)
       (qt +lsp)
       (rust +lsp +tree-sitter)
       (sh +lsp +tree-sitter)
       (web +lsp +tree-sitter)
       (yaml +lsp +tree-sitter)

       :email
       (mu4e +org +gmail)

       :app
       calendar
       emms
       (rss +org)

       :config
       literate
       (default +bindings +smartparens))
