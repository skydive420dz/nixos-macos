;;; sky-theme-common.el -*- lexical-binding: t; -*-

(defun sky--color (name colors)
  (alist-get name colors))

(defun sky--runtime-color (name)
  (or (and (boundp 'sk/theme)
           (alist-get name sk/theme))
      (and (boundp 'sk/theme-default)
           (alist-get name sk/theme-default))))

(defun sky-theme-current-colors ()
  "Return native theme colors from the generated Sky runtime tokens."
  `((bg . ,(sky--runtime-color 'background))
    (bg-alt . ,(sky--runtime-color 'background-alt))
    (surface . ,(sky--runtime-color 'surface))
    (surface-strong . ,(sky--runtime-color 'surface-strong))
    (border . ,(sky--runtime-color 'border))
    (border-active . ,(sky--runtime-color 'border-active))
    (fg . ,(sky--runtime-color 'foreground))
    (fg-alt . ,(sky--runtime-color 'foreground-alt))
    (muted . ,(sky--runtime-color 'muted))
    (accent . ,(sky--runtime-color 'accent))
    (accent-alt . ,(sky--runtime-color 'accent-alt))
    (success . ,(sky--runtime-color 'success))
    (warning . ,(sky--runtime-color 'warning))
    (danger . ,(sky--runtime-color 'danger))
    (selection-fg . ,(sky--runtime-color 'selection-foreground))
    (selection-bg . ,(sky--runtime-color 'selection-background))
    (string . ,(sky--runtime-color 'string))
    (function . ,(sky--runtime-color 'function))
    (keyword . ,(sky--runtime-color 'keyword))
    (number . ,(sky--runtime-color 'number))
    (type . ,(sky--runtime-color 'type))
    (builtin . ,(sky--runtime-color 'builtin))
    (preprocessor . ,(sky--runtime-color 'preprocessor))
    (comment . ,(sky--runtime-color 'comment))
    (black . ,(sky--runtime-color 'black))
    (red . ,(sky--runtime-color 'red))
    (green . ,(sky--runtime-color 'green))
    (yellow . ,(sky--runtime-color 'yellow))
    (blue . ,(sky--runtime-color 'blue))
    (magenta . ,(sky--runtime-color 'magenta))
    (cyan . ,(sky--runtime-color 'cyan))
    (white . ,(sky--runtime-color 'white))))

(defconst sky-theme-managed-faces
  '(default cursor fringe highlight hl-line region secondary-selection
    lazy-highlight isearch match minibuffer-prompt escape-glyph homoglyph
    link link-visited error warning success shadow tooltip vertical-border
    window-divider window-divider-first-pixel window-divider-last-pixel
    line-number line-number-current-line font-lock-builtin-face
    font-lock-comment-face font-lock-comment-delimiter-face
    font-lock-constant-face font-lock-doc-face font-lock-function-name-face
    font-lock-keyword-face font-lock-negation-char-face font-lock-number-face
    font-lock-preprocessor-face font-lock-regexp-grouping-backslash
    font-lock-regexp-grouping-construct font-lock-string-face
    font-lock-type-face font-lock-variable-name-face font-lock-warning-face
    tree-sitter-hl-face:attribute tree-sitter-hl-face:comment
    tree-sitter-hl-face:constant tree-sitter-hl-face:constant.builtin
    tree-sitter-hl-face:constructor tree-sitter-hl-face:doc
    tree-sitter-hl-face:embedded tree-sitter-hl-face:escape
    tree-sitter-hl-face:function tree-sitter-hl-face:function.call
    tree-sitter-hl-face:function.macro tree-sitter-hl-face:keyword
    tree-sitter-hl-face:label tree-sitter-hl-face:number
    tree-sitter-hl-face:operator tree-sitter-hl-face:property
    tree-sitter-hl-face:punctuation tree-sitter-hl-face:punctuation.bracket
    tree-sitter-hl-face:punctution tree-sitter-hl-face:string
    tree-sitter-hl-face:tag tree-sitter-hl-face:type
    tree-sitter-hl-face:type.builtin tree-sitter-hl-face:variable
    tree-sitter-hl-face:variable.parameter tree-sitter-hl-face:variable.special
    mode-line mode-line-inactive mode-line-buffer-id header-line tab-line
    tab-line-tab tab-line-tab-current tab-line-tab-inactive show-paren-match
    show-paren-mismatch trailing-whitespace whitespace-space whitespace-tab
    whitespace-newline whitespace-trailing solaire-default-face
    ansi-color-black ansi-color-red ansi-color-green ansi-color-yellow
    ansi-color-blue ansi-color-magenta ansi-color-cyan ansi-color-white
    ansi-color-bright-black ansi-color-bright-red ansi-color-bright-green
    ansi-color-bright-yellow ansi-color-bright-blue ansi-color-bright-magenta
    ansi-color-bright-cyan ansi-color-bright-white
    term-color-black term-color-red term-color-green term-color-yellow
    term-color-blue term-color-magenta term-color-cyan term-color-white
    vterm-color-default vterm-color-black vterm-color-red vterm-color-green
    vterm-color-yellow vterm-color-blue vterm-color-magenta vterm-color-cyan
    vterm-color-white vterm-color-inverse-video
    solaire-fringe-face solaire-line-number-face solaire-hl-line-face
    doom-modeline-bar doom-modeline-bar-inactive doom-modeline-buffer-file
    doom-modeline-buffer-major-mode doom-modeline-buffer-minor-mode
    doom-modeline-buffer-modified doom-modeline-info doom-modeline-warning
    doom-modeline-urgent doom-modeline-debug doom-dashboard-banner
    doom-dashboard-footer doom-dashboard-footer-icon doom-dashboard-menu-desc
    doom-dashboard-menu-title which-key-key-face
    which-key-group-description-face which-key-command-description-face
    which-key-local-map-description-face which-key-separator-face
    completions-common-part completions-first-difference vertico-current
    marginalia-documentation marginalia-key marginalia-symbol
    orderless-match-face-0 orderless-match-face-1 orderless-match-face-2
    orderless-match-face-3 corfu-default corfu-current corfu-bar corfu-border
    corfu-annotations corfu-deprecated company-tooltip company-tooltip-selection
    company-tooltip-common company-tooltip-annotation company-scrollbar-bg
    company-scrollbar-fg flycheck-error flycheck-warning flycheck-info
    flycheck-inline-error flycheck-inline-warning flycheck-inline-info
    flyspell-incorrect flyspell-duplicate lsp-face-highlight-read
    lsp-face-highlight-textual lsp-face-highlight-write
    lsp-ui-doc-background lsp-ui-doc-header org-block org-block-begin-line
    org-block-end-line org-code org-date org-document-info org-document-title
    org-done org-headline-done org-hide org-level-1 org-level-2 org-level-3
    org-level-4 org-level-5 org-level-6 org-level-7 org-link org-meta-line
    org-special-keyword org-table org-todo org-verbatim markdown-code-face
    markdown-header-face markdown-header-face-1 markdown-header-face-2
    magit-section-heading magit-branch-current magit-branch-local
    magit-branch-remote magit-diff-added magit-diff-added-highlight
    magit-diff-removed magit-diff-removed-highlight magit-diff-context
    magit-diff-context-highlight magit-diff-file-heading
    magit-diff-hunk-heading magit-diff-hunk-heading-highlight diff-added
    diff-removed diff-changed diff-header diff-file-header dired-directory
    dired-flagged dired-header dired-ignored dired-marked dired-perm-write
    dired-symlink dired-warning evil-goggles-default-face
    evil-goggles-yank-face evil-goggles-paste-face evil-goggles-delete-face
    evil-goggles-change-face evil-goggles-indent-face evil-goggles-join-face
    avy-background-face avy-lead-face avy-lead-face-0 avy-lead-face-1
    avy-lead-face-2)
  "Faces owned by the native Sky themes.")

(defun sky-define-theme (theme colors)
  "Define THEME from Sky COLORS."
  (let* ((bg (sky--color 'bg colors))
         (bg-alt (sky--color 'bg-alt colors))
         (surface (sky--color 'surface colors))
         (surface-strong (sky--color 'surface-strong colors))
         (border (sky--color 'border colors))
         (border-active (sky--color 'border-active colors))
         (fg (sky--color 'fg colors))
         (fg-alt (sky--color 'fg-alt colors))
         (muted (sky--color 'muted colors))
         (accent (sky--color 'accent colors))
         (accent-alt (sky--color 'accent-alt colors))
         (success (sky--color 'success colors))
         (warning (sky--color 'warning colors))
         (danger (sky--color 'danger colors))
         (selection-fg (sky--color 'selection-fg colors))
         (selection-bg (sky--color 'selection-bg colors))
         (string (sky--color 'string colors))
         (function (sky--color 'function colors))
         (keyword (sky--color 'keyword colors))
         (number (sky--color 'number colors))
         (type (sky--color 'type colors))
         (builtin (sky--color 'builtin colors))
         (preprocessor (sky--color 'preprocessor colors))
         (comment (sky--color 'comment colors))
         (black (sky--color 'black colors))
         (red (sky--color 'red colors))
         (green (sky--color 'green colors))
         (yellow (sky--color 'yellow colors))
         (blue (sky--color 'blue colors))
         (magenta (sky--color 'magenta colors))
         (cyan (sky--color 'cyan colors))
         (white (sky--color 'white colors)))
    (custom-theme-set-faces
     theme
     `(default ((t (:background ,bg :foreground ,fg))))
     `(cursor ((t (:background ,accent))))
     `(fringe ((t (:background ,bg :foreground ,muted))))
     `(highlight ((t (:background ,surface))))
     `(hl-line ((t (:background ,surface))))
     `(region ((t (:background ,selection-bg :foreground ,selection-fg))))
     `(secondary-selection ((t (:background ,surface-strong :foreground ,fg))))
     `(lazy-highlight ((t (:background ,surface-strong :foreground ,fg))))
     `(isearch ((t (:background ,warning :foreground ,selection-fg :weight bold))))
     `(match ((t (:background ,surface-strong :foreground ,accent :weight bold))))
     `(minibuffer-prompt ((t (:foreground ,accent :weight bold))))
     `(escape-glyph ((t (:foreground ,warning))))
     `(homoglyph ((t (:foreground ,warning))))
     `(link ((t (:foreground ,accent :underline t))))
     `(link-visited ((t (:foreground ,accent-alt :underline t))))
     `(error ((t (:foreground ,danger :weight bold))))
     `(warning ((t (:foreground ,warning :weight bold))))
     `(success ((t (:foreground ,success :weight bold))))
     `(shadow ((t (:foreground ,muted))))
     `(tooltip ((t (:background ,surface-strong :foreground ,fg))))
     `(vertical-border ((t (:foreground ,border))))
     `(window-divider ((t (:foreground ,border))))
     `(window-divider-first-pixel ((t (:foreground ,border))))
     `(window-divider-last-pixel ((t (:foreground ,border))))
     `(line-number ((t (:background ,bg :foreground ,muted))))
     `(line-number-current-line ((t (:background ,bg :foreground ,accent :weight bold))))
     `(font-lock-builtin-face ((t (:foreground ,builtin :weight medium))))
     `(font-lock-comment-face ((t (:foreground ,comment :slant italic))))
     `(font-lock-comment-delimiter-face ((t (:foreground ,comment :slant italic))))
     `(font-lock-constant-face ((t (:foreground ,number))))
     `(font-lock-doc-face ((t (:foreground ,string))))
     `(font-lock-function-name-face ((t (:foreground ,function))))
     `(font-lock-keyword-face ((t (:foreground ,keyword :weight bold))))
     `(font-lock-negation-char-face ((t (:foreground ,warning :weight bold))))
     `(font-lock-number-face ((t (:foreground ,number))))
     `(font-lock-preprocessor-face ((t (:foreground ,preprocessor))))
     `(font-lock-regexp-grouping-backslash ((t (:foreground ,warning :weight bold))))
     `(font-lock-regexp-grouping-construct ((t (:foreground ,accent :weight bold))))
     `(font-lock-string-face ((t (:foreground ,string))))
     `(font-lock-type-face ((t (:foreground ,type))))
     `(font-lock-variable-name-face ((t (:foreground ,accent-alt))))
     `(font-lock-warning-face ((t (:foreground ,danger :weight bold))))
     `(tree-sitter-hl-face:attribute ((t (:foreground ,accent-alt))))
     `(tree-sitter-hl-face:comment ((t (:foreground ,comment :slant italic))))
     `(tree-sitter-hl-face:constant ((t (:foreground ,number))))
     `(tree-sitter-hl-face:constant.builtin ((t (:foreground ,builtin :weight medium))))
     `(tree-sitter-hl-face:constructor ((t (:foreground ,type))))
     `(tree-sitter-hl-face:doc ((t (:foreground ,string :slant italic))))
     `(tree-sitter-hl-face:embedded ((t (:foreground ,fg))))
     `(tree-sitter-hl-face:escape ((t (:foreground ,warning :weight bold))))
     `(tree-sitter-hl-face:function ((t (:foreground ,function))))
     `(tree-sitter-hl-face:function.call ((t (:foreground ,function))))
     `(tree-sitter-hl-face:function.macro ((t (:foreground ,preprocessor :weight medium))))
     `(tree-sitter-hl-face:keyword ((t (:foreground ,keyword :weight bold))))
     `(tree-sitter-hl-face:label ((t (:foreground ,accent-alt))))
     `(tree-sitter-hl-face:number ((t (:foreground ,number))))
     `(tree-sitter-hl-face:operator ((t (:foreground ,fg-alt))))
     `(tree-sitter-hl-face:property ((t (:foreground ,accent-alt))))
     `(tree-sitter-hl-face:punctuation ((t (:foreground ,muted))))
     `(tree-sitter-hl-face:punctuation.bracket ((t (:foreground ,muted))))
     `(tree-sitter-hl-face:punctution ((t (:foreground ,muted))))
     `(tree-sitter-hl-face:string ((t (:foreground ,string))))
     `(tree-sitter-hl-face:tag ((t (:foreground ,keyword :weight medium))))
     `(tree-sitter-hl-face:type ((t (:foreground ,type))))
     `(tree-sitter-hl-face:type.builtin ((t (:foreground ,builtin :weight medium))))
     `(tree-sitter-hl-face:variable ((t (:foreground ,fg))))
     `(tree-sitter-hl-face:variable.parameter ((t (:foreground ,fg-alt))))
     `(tree-sitter-hl-face:variable.special ((t (:foreground ,accent-alt))))
     `(mode-line ((t (:background ,surface :foreground ,fg :box nil))))
     `(mode-line-inactive ((t (:background ,bg :foreground ,muted :box nil))))
     `(mode-line-buffer-id ((t (:foreground ,fg :weight bold))))
     `(header-line ((t (:background ,surface :foreground ,fg :box nil))))
     `(tab-line ((t (:background ,bg-alt :foreground ,fg :box nil))))
     `(tab-line-tab ((t (:background ,surface :foreground ,fg :box nil))))
     `(tab-line-tab-current ((t (:background ,surface-strong :foreground ,fg :box nil :weight bold))))
     `(tab-line-tab-inactive ((t (:background ,bg-alt :foreground ,muted :box nil))))
     `(show-paren-match ((t (:background ,surface-strong :foreground ,accent :weight bold))))
     `(show-paren-mismatch ((t (:background ,danger :foreground ,selection-fg :weight bold))))
     `(trailing-whitespace ((t (:background ,danger))))
     `(whitespace-space ((t (:foreground ,border))))
     `(whitespace-tab ((t (:foreground ,border))))
     `(whitespace-newline ((t (:foreground ,border))))
     `(whitespace-trailing ((t (:background ,danger :foreground ,selection-fg))))
     `(ansi-color-black ((t (:foreground ,black :background ,black))))
     `(ansi-color-red ((t (:foreground ,red :background ,red))))
     `(ansi-color-green ((t (:foreground ,green :background ,green))))
     `(ansi-color-yellow ((t (:foreground ,yellow :background ,yellow))))
     `(ansi-color-blue ((t (:foreground ,blue :background ,blue))))
     `(ansi-color-magenta ((t (:foreground ,magenta :background ,magenta))))
     `(ansi-color-cyan ((t (:foreground ,cyan :background ,cyan))))
     `(ansi-color-white ((t (:foreground ,white :background ,white))))
     `(ansi-color-bright-black ((t (:foreground ,muted :background ,muted))))
     `(ansi-color-bright-red ((t (:foreground ,red :background ,red :weight bold))))
     `(ansi-color-bright-green ((t (:foreground ,green :background ,green :weight bold))))
     `(ansi-color-bright-yellow ((t (:foreground ,yellow :background ,yellow :weight bold))))
     `(ansi-color-bright-blue ((t (:foreground ,blue :background ,blue :weight bold))))
     `(ansi-color-bright-magenta ((t (:foreground ,magenta :background ,magenta :weight bold))))
     `(ansi-color-bright-cyan ((t (:foreground ,cyan :background ,cyan :weight bold))))
     `(ansi-color-bright-white ((t (:foreground ,fg :background ,fg :weight bold))))
     `(term-color-black ((t (:foreground ,black :background ,black))))
     `(term-color-red ((t (:foreground ,red :background ,red))))
     `(term-color-green ((t (:foreground ,green :background ,green))))
     `(term-color-yellow ((t (:foreground ,yellow :background ,yellow))))
     `(term-color-blue ((t (:foreground ,blue :background ,blue))))
     `(term-color-magenta ((t (:foreground ,magenta :background ,magenta))))
     `(term-color-cyan ((t (:foreground ,cyan :background ,cyan))))
     `(term-color-white ((t (:foreground ,white :background ,white))))
     `(vterm-color-default ((t (:foreground ,fg :background ,bg))))
     `(vterm-color-black ((t (:foreground ,black :background ,black))))
     `(vterm-color-red ((t (:foreground ,red :background ,red))))
     `(vterm-color-green ((t (:foreground ,green :background ,green))))
     `(vterm-color-yellow ((t (:foreground ,yellow :background ,yellow))))
     `(vterm-color-blue ((t (:foreground ,blue :background ,blue))))
     `(vterm-color-magenta ((t (:foreground ,magenta :background ,magenta))))
     `(vterm-color-cyan ((t (:foreground ,cyan :background ,cyan))))
     `(vterm-color-white ((t (:foreground ,white :background ,white))))
     `(vterm-color-inverse-video ((t (:inverse-video t))))
     `(solaire-default-face ((t (:background ,bg-alt :foreground ,fg))))
     `(solaire-fringe-face ((t (:background ,bg-alt :foreground ,muted))))
     `(solaire-line-number-face ((t (:background ,bg-alt :foreground ,muted))))
     `(solaire-hl-line-face ((t (:background ,surface))))
     `(doom-modeline-bar ((t (:background ,accent))))
     `(doom-modeline-bar-inactive ((t (:background ,border))))
     `(doom-modeline-buffer-file ((t (:foreground ,fg :weight medium))))
     `(doom-modeline-buffer-major-mode ((t (:foreground ,accent))))
     `(doom-modeline-buffer-minor-mode ((t (:foreground ,muted))))
     `(doom-modeline-buffer-modified ((t (:foreground ,warning :weight bold))))
     `(doom-modeline-info ((t (:foreground ,success))))
     `(doom-modeline-warning ((t (:foreground ,warning))))
     `(doom-modeline-urgent ((t (:foreground ,danger))))
     `(doom-modeline-debug ((t (:foreground ,warning))))
     `(doom-dashboard-banner ((t (:foreground ,accent))))
     `(doom-dashboard-footer ((t (:foreground ,muted))))
     `(doom-dashboard-footer-icon ((t (:foreground ,accent))))
     `(doom-dashboard-menu-desc ((t (:foreground ,fg))))
     `(doom-dashboard-menu-title ((t (:foreground ,accent :weight bold))))
     `(which-key-key-face ((t (:foreground ,accent :weight bold))))
     `(which-key-group-description-face ((t (:foreground ,keyword))))
     `(which-key-command-description-face ((t (:foreground ,fg))))
     `(which-key-local-map-description-face ((t (:foreground ,success))))
     `(which-key-separator-face ((t (:foreground ,muted))))
     `(completions-common-part ((t (:foreground ,accent :weight bold))))
     `(completions-first-difference ((t (:foreground ,warning :weight bold))))
     `(vertico-current ((t (:background ,surface-strong :foreground ,fg))))
     `(marginalia-documentation ((t (:foreground ,muted))))
     `(marginalia-key ((t (:foreground ,accent))))
     `(marginalia-symbol ((t (:foreground ,accent-alt))))
     `(orderless-match-face-0 ((t (:foreground ,accent :weight bold))))
     `(orderless-match-face-1 ((t (:foreground ,warning :weight bold))))
     `(orderless-match-face-2 ((t (:foreground ,success :weight bold))))
     `(orderless-match-face-3 ((t (:foreground ,danger :weight bold))))
     `(corfu-default ((t (:background ,surface :foreground ,fg))))
     `(corfu-current ((t (:background ,surface-strong :foreground ,fg))))
     `(corfu-bar ((t (:background ,border-active))))
     `(corfu-border ((t (:background ,border))))
     `(corfu-annotations ((t (:foreground ,muted))))
     `(corfu-deprecated ((t (:foreground ,muted :strike-through t))))
     `(company-tooltip ((t (:background ,surface :foreground ,fg))))
     `(company-tooltip-selection ((t (:background ,surface-strong :foreground ,fg))))
     `(company-tooltip-common ((t (:foreground ,accent :weight bold))))
     `(company-tooltip-annotation ((t (:foreground ,muted))))
     `(company-scrollbar-bg ((t (:background ,surface))))
     `(company-scrollbar-fg ((t (:background ,border-active))))
     `(flycheck-error ((t (:underline (:style wave :color ,danger)))))
     `(flycheck-warning ((t (:underline (:style wave :color ,warning)))))
     `(flycheck-info ((t (:underline (:style wave :color ,success)))))
     `(flycheck-inline-error ((t (:foreground ,danger :weight bold))))
     `(flycheck-inline-warning ((t (:foreground ,warning :weight bold))))
     `(flycheck-inline-info ((t (:foreground ,success :weight bold))))
     `(flyspell-incorrect ((t (:underline (:style wave :color ,danger)))))
     `(flyspell-duplicate ((t (:underline (:style wave :color ,warning)))))
     `(lsp-face-highlight-read ((t (:background ,surface-strong :foreground ,fg))))
     `(lsp-face-highlight-textual ((t (:background ,surface-strong :foreground ,fg))))
     `(lsp-face-highlight-write ((t (:background ,surface-strong :foreground ,fg :weight bold))))
     `(lsp-ui-doc-background ((t (:background ,surface))))
     `(lsp-ui-doc-header ((t (:background ,surface-strong :foreground ,fg :weight bold))))
     `(org-block ((t (:background ,surface :foreground ,fg))))
     `(org-block-begin-line ((t (:background ,surface :foreground ,muted))))
     `(org-block-end-line ((t (:background ,surface :foreground ,muted))))
     `(org-code ((t (:foreground ,accent-alt))))
     `(org-date ((t (:foreground ,accent :underline t))))
     `(org-document-info ((t (:foreground ,fg-alt))))
     `(org-document-title ((t (:foreground ,accent :weight bold :height 1.3))))
     `(org-done ((t (:foreground ,success :weight bold))))
     `(org-headline-done ((t (:foreground ,muted))))
     `(org-hide ((t (:foreground ,bg))))
     `(org-level-1 ((t (:foreground ,accent :weight bold :height 1.7))))
     `(org-level-2 ((t (:foreground ,accent-alt :weight bold :height 1.6))))
     `(org-level-3 ((t (:foreground ,success :weight bold :height 1.5))))
     `(org-level-4 ((t (:foreground ,warning :weight bold :height 1.4))))
     `(org-level-5 ((t (:foreground ,type :weight bold :height 1.3))))
     `(org-level-6 ((t (:foreground ,builtin :weight bold :height 1.2))))
     `(org-level-7 ((t (:foreground ,comment :weight bold :height 1.1))))
     `(org-link ((t (:foreground ,accent :underline t))))
     `(org-meta-line ((t (:foreground ,comment :slant italic))))
     `(org-special-keyword ((t (:foreground ,muted))))
     `(org-table ((t (:foreground ,accent-alt))))
     `(org-todo ((t (:foreground ,danger :weight bold))))
     `(org-verbatim ((t (:foreground ,warning))))
     `(markdown-code-face ((t (:background ,surface :foreground ,fg))))
     `(markdown-header-face ((t (:foreground ,accent :weight bold))))
     `(markdown-header-face-1 ((t (:foreground ,accent :weight bold :height 1.2))))
     `(markdown-header-face-2 ((t (:foreground ,accent-alt :weight bold :height 1.1))))
     `(magit-section-heading ((t (:foreground ,accent :weight bold))))
     `(magit-branch-current ((t (:foreground ,accent :weight bold))))
     `(magit-branch-local ((t (:foreground ,accent-alt))))
     `(magit-branch-remote ((t (:foreground ,success))))
     `(magit-diff-added ((t (:background ,surface :foreground ,success))))
     `(magit-diff-added-highlight ((t (:background ,surface-strong :foreground ,success))))
     `(magit-diff-removed ((t (:background ,surface :foreground ,danger))))
     `(magit-diff-removed-highlight ((t (:background ,surface-strong :foreground ,danger))))
     `(magit-diff-context ((t (:background ,bg :foreground ,fg-alt))))
     `(magit-diff-context-highlight ((t (:background ,surface :foreground ,fg))))
     `(magit-diff-file-heading ((t (:foreground ,fg :weight bold))))
     `(magit-diff-hunk-heading ((t (:background ,surface :foreground ,muted))))
     `(magit-diff-hunk-heading-highlight ((t (:background ,surface-strong :foreground ,fg))))
     `(diff-added ((t (:background ,surface :foreground ,success))))
     `(diff-removed ((t (:background ,surface :foreground ,danger))))
     `(diff-changed ((t (:background ,surface :foreground ,warning))))
     `(diff-header ((t (:background ,surface :foreground ,fg))))
     `(diff-file-header ((t (:background ,surface-strong :foreground ,fg :weight bold))))
     `(dired-directory ((t (:foreground ,accent :weight bold))))
     `(dired-flagged ((t (:foreground ,danger))))
     `(dired-header ((t (:foreground ,accent :weight bold))))
     `(dired-ignored ((t (:foreground ,muted))))
     `(dired-marked ((t (:foreground ,warning :weight bold))))
     `(dired-perm-write ((t (:foreground ,warning))))
     `(dired-symlink ((t (:foreground ,accent-alt :weight bold))))
     `(dired-warning ((t (:foreground ,danger :weight bold))))
     `(evil-goggles-default-face ((t (:background ,surface-strong :foreground ,fg :weight bold))))
     `(evil-goggles-yank-face ((t (:background ,accent :foreground ,selection-fg :weight bold))))
     `(evil-goggles-paste-face ((t (:background ,success :foreground ,selection-fg :weight bold))))
     `(evil-goggles-delete-face ((t (:background ,danger :foreground ,selection-fg :weight bold))))
     `(evil-goggles-change-face ((t (:background ,warning :foreground ,selection-fg :weight bold))))
     `(evil-goggles-indent-face ((t (:background ,accent-alt :foreground ,selection-fg :weight bold))))
     `(evil-goggles-join-face ((t (:background ,builtin :foreground ,selection-fg :weight bold))))
     `(avy-background-face ((t (:foreground ,muted))))
     `(avy-lead-face ((t (:background ,accent :foreground ,selection-fg :weight bold))))
     `(avy-lead-face-0 ((t (:background ,warning :foreground ,selection-fg :weight bold))))
     `(avy-lead-face-1 ((t (:background ,success :foreground ,selection-fg :weight bold))))
     `(avy-lead-face-2 ((t (:background ,danger :foreground ,selection-fg :weight bold)))))
    (custom-theme-set-variables
     theme
     `(ansi-color-names-vector [,black ,red ,green ,yellow ,blue ,magenta ,cyan ,white])
     `(ansi-term-color-vector [,black ,red ,green ,yellow ,blue ,magenta ,cyan ,white])
     `(fci-rule-color ,border)
     `(vc-annotate-color-map
       '((20 . ,danger)
         (40 . ,warning)
         (60 . ,success)
         (80 . ,accent)
         (100 . ,accent-alt)
         (120 . ,muted)
         (140 . ,fg)))
     `(vc-annotate-very-old-color nil))))

(provide 'sky-theme-common)
