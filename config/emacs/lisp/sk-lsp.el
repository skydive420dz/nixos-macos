;;; sk-lsp.el --- Language server client -*- lexical-binding: t; -*-

;; Start with Eglot because it is built into Emacs and keeps the clean config
;; smaller. Nix owns the external language-server executables.

(require 'cl-lib)
(require 'seq)
(require 'eglot)

(cl-defmethod eglot-register-capability
  (server (method (eql :workspace/didChangeWatchedFiles)) id &rest params)
  "Accept qmlls' colon-prefixed watched-file registration method."
  (apply #'eglot-register-capability
         server 'workspace/didChangeWatchedFiles id params))

(cl-defmethod eglot-unregister-capability
  (server (method (eql :workspace/didChangeWatchedFiles)) id &rest params)
  "Accept qmlls' colon-prefixed watched-file unregistration method."
  (apply #'eglot-unregister-capability
         server 'workspace/didChangeWatchedFiles id params))

(defconst sk/eglot-managed-modes
  '(c-mode c++-mode c-ts-mode c++-ts-mode
    rust-mode rust-ts-mode
    python-mode python-ts-mode
    lua-mode lua-ts-mode
    nix-mode nix-ts-mode
    qml-mode sk-qml-ts-mode
    js-mode js-ts-mode typescript-mode typescript-ts-mode tsx-ts-mode
    web-mode html-mode html-ts-mode mhtml-mode css-mode css-ts-mode
    sh-mode bash-ts-mode
    glsl-mode glsl-ts-mode
    haskell-mode haskell-ts-mode
    yaml-mode yaml-ts-mode
    json-mode json-ts-mode
    markdown-mode markdown-ts-mode org-mode text-mode)
  "Major modes that should start Eglot when their server is available.")

(defconst sk/eglot-server-programs
  '((((qml-mode :language-id "qml")
      (sk-qml-ts-mode :language-id "qml"))
     . ("qmlls-wrapped"))
    (((lua-mode :language-id "lua")
      (lua-ts-mode :language-id "lua"))
     . ("lua-language-server"))
    (((nix-mode :language-id "nix")
      (nix-ts-mode :language-id "nix"))
     . ("nixd"))
    (((json-mode :language-id "json")
      (json-ts-mode :language-id "json")
      (js-json-mode :language-id "json"))
     . ("vscode-json-language-server" "--stdio"))
    (((yaml-mode :language-id "yaml")
      (yaml-ts-mode :language-id "yaml"))
     . ("yaml-language-server" "--stdio"))
    (((glsl-mode :language-id "glsl")
      (glsl-ts-mode :language-id "glsl"))
     . ("glsl_analyzer" "--stdio"))
    (((haskell-mode :language-id "haskell")
      (haskell-ts-mode :language-id "haskell"))
     . ("haskell-language-server-wrapper" "--lsp"))
    (((python-mode :language-id "python")
      (python-ts-mode :language-id "python"))
     . ("basedpyright-langserver" "--stdio"))
    (((web-mode :language-id "html")
      (html-mode :language-id "html")
      (html-ts-mode :language-id "html")
      (mhtml-mode :language-id "html"))
     . ("vscode-html-language-server" "--stdio"))
    ((css-mode css-ts-mode) . ("vscode-css-language-server" "--stdio"))
    (((js-mode :language-id "javascript")
      (js-ts-mode :language-id "javascript")
      (typescript-mode :language-id "typescript")
      (typescript-ts-mode :language-id "typescript")
      (tsx-ts-mode :language-id "typescriptreact"))
     . ("typescript-language-server" "--stdio"))
    (((markdown-mode :language-id "markdown")
      (markdown-ts-mode :language-id "markdown")
      (org-mode :language-id "org")
      (text-mode :language-id "plaintext"))
     . ("harper-ls" "--stdio")))
  "Sky-specific Eglot server mappings, ordered from specific to broad.")

(defvar sk/org-agenda-generating-p nil
  "Non-nil while Org is collecting agenda buffers.")

(defvar sk/lua-neovim-runtime-path
  (expand-file-name "lua/neovim-runtime" user-emacs-directory)
  "Nix-linked Neovim runtime path used by LuaLS for `vim.*' metadata.")

(defun sk/lua-workspace-library ()
  "Return LuaLS library directories for Neovim-aware Lua buffers."
  (seq-filter
   #'file-directory-p
   (list
    (expand-file-name "lua" sk/lua-neovim-runtime-path)
    (expand-file-name "lua/vim/_meta" sk/lua-neovim-runtime-path)
    (expand-file-name "lua/vim/lsp/_meta" sk/lua-neovim-runtime-path)
    (expand-file-name "lua/uv" sk/lua-neovim-runtime-path))))

(defun sk/without-eglot-during-org-agenda (orig-fn &rest args)
  "Call ORIG-FN with prose Eglot autostart paused for agenda collection."
  (let ((sk/org-agenda-generating-p t))
    (apply orig-fn args)))

(defun sk/eglot-workspace-configuration (server)
  "Return per-server workspace configuration for SERVER.

Keep config payloads scoped to the server that requested them. Some language
servers are strict about unknown configuration shapes, so avoid sending the Nix
server config to prose servers like Harper."
  (let ((language-ids (eglot--language-ids server)))
    (cond
     ((member "lua" language-ids)
      (list :Lua
            (list :runtime (list :version "LuaJIT")
                  :diagnostics (list :globals ["vim" "hl"])
                  :workspace (list :checkThirdParty :json-false
                                   :library (vconcat (sk/lua-workspace-library))))))
     ((member "nix" language-ids)
      nil)
     ((member "haskell" language-ids)
      (list :haskell (make-hash-table :test 'equal)))
     ((seq-intersection '("markdown" "org" "plaintext") language-ids #'string=)
      '(:harper-ls (:userDictPath ""
                    :workspaceDictPath ""
                    :fileDictPath ""
                    :linters (:SpellCheck t
                              :SpelledNumbers :json-false
                              :AnA t
                              :SentenceCapitalization t
                              :UnclosedQuotes t
                              :WrongQuotes :json-false
                              :LongSentences t
                              :RepeatedWords t
                              :Spaces t
                              :Matcher t
                              :CorrectNumberSuffix t)
                    :codeActions (:ForceStable :json-false)
                    :markdown (:IgnoreLinkTitle :json-false)
                    :diagnosticSeverity "hint"
                    :isolateEnglish :json-false
                    :dialect "American"
                    :maxFileLength 120000
                    :ignoredLintsPath ""
                    :excludePatterns [])))
     (t nil))))

(defun sk/eglot-buffer-eligible-p ()
  "Return non-nil when the current buffer is a real file buffer for Eglot."
  (and buffer-file-name
       (not sk/org-agenda-generating-p)
       (not (string-prefix-p " " (buffer-name)))
       (or (not (memq major-mode '(rust-mode rust-ts-mode)))
           (locate-dominating-file default-directory "Cargo.toml")
           (locate-dominating-file default-directory "rust-project.json"))))

(defun sk/eglot-configure ()
  "Apply Sky Eglot defaults immediately and for new buffers."
  (setq-default eglot-autoshutdown nil
                eglot-workspace-configuration
                #'sk/eglot-workspace-configuration)
  (setq eglot-autoshutdown nil
        eglot-workspace-configuration
        #'sk/eglot-workspace-configuration)
  (dolist (server sk/eglot-server-programs)
    (setq eglot-server-programs
          (seq-remove (lambda (entry)
                        (equal (car entry) (car server)))
                      eglot-server-programs)))
  (setq eglot-server-programs
        (append sk/eglot-server-programs eglot-server-programs)))

(sk/eglot-configure)

(defun sk/eglot-ensure ()
  "Start Eglot for supported buffers."
  (when (and (memq major-mode sk/eglot-managed-modes)
             (sk/eglot-buffer-eligible-p)
             (not (eglot-managed-p)))
    (condition-case err
        (progn
          (apply #'eglot (eglot--guess-contact))
          (when (fboundp 'sk/capf-code-defaults)
            (sk/capf-code-defaults)))
      (error
       (message "Eglot skipped for %s: %s"
                major-mode
                (error-message-string err))))))

(use-package eglot
  :ensure nil
  :hook ((c-mode c++-mode c-ts-mode c++-ts-mode
          rust-mode rust-ts-mode
          python-mode python-ts-mode
          lua-mode lua-ts-mode
          nix-mode nix-ts-mode
          qml-mode sk-qml-ts-mode
          js-mode js-ts-mode typescript-mode typescript-ts-mode tsx-ts-mode
          web-mode html-mode html-ts-mode mhtml-mode css-mode css-ts-mode
          sh-mode bash-ts-mode
          glsl-mode glsl-ts-mode
          haskell-mode haskell-ts-mode
          yaml-mode yaml-ts-mode
          json-mode json-ts-mode
          markdown-mode markdown-ts-mode org-mode text-mode) . sk/eglot-ensure)
  :config
  (sk/eglot-configure))

(with-eval-after-load 'org-agenda
  (advice-remove 'org-agenda #'sk/without-eglot-during-org-agenda)
  (advice-add 'org-agenda :around #'sk/without-eglot-during-org-agenda))

(provide 'sk-lsp)

;;; sk-lsp.el ends here
