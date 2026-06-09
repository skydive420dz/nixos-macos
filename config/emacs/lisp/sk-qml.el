;;; sk-qml.el --- Parser-backed QML editing -*- lexical-binding: t; -*-

;; `qml-mode' remains the fallback when the qmljs Tree-sitter parser is not
;; available. This mode avoids ad hoc regex highlighting by using qmljs grammar
;; nodes directly.

(require 'treesit)
(require 'js)
(require 'qml-mode)

(defconst sk-qml-ts-font-lock-settings
  (treesit-font-lock-rules
   :language 'qmljs
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'qmljs
   :feature 'string
   '((string) @font-lock-string-face)

   :language 'qmljs
   :feature 'number
   '((number) @font-lock-number-face)

   :language 'qmljs
   :feature 'keyword
   '((ui_import "import" @font-lock-keyword-face)
     (ui_property "property" @font-lock-keyword-face)
     (ui_property_modifier) @font-lock-keyword-face
     (variable_declaration "var" @font-lock-keyword-face)
     (lexical_declaration "let" @font-lock-keyword-face)
     (lexical_declaration "const" @font-lock-keyword-face)
     (function_declaration "function" @font-lock-keyword-face)
     (return_statement "return" @font-lock-keyword-face)
     (if_statement "if" @font-lock-keyword-face)
     (else_clause "else" @font-lock-keyword-face)
     (for_statement "for" @font-lock-keyword-face)
     (while_statement "while" @font-lock-keyword-face))

   :language 'qmljs
   :feature 'type
   '((ui_object_definition
      type_name: (identifier) @font-lock-type-face)
     (ui_property
      type: (type_identifier) @font-lock-type-face)
     (ui_import
      (identifier) @font-lock-type-face)
     (ui_import
      (nested_identifier
       (identifier) @font-lock-type-face)))

   :language 'qmljs
   :feature 'property
   '((ui_property
      name: (identifier) @font-lock-variable-name-face)
     (ui_binding
      name: (identifier) @font-lock-property-name-face)
     (ui_binding
      name: (nested_identifier
             (identifier) @font-lock-property-name-face))
     (member_expression
      object: (identifier) @font-lock-variable-use-face)
     (member_expression
      property: (property_identifier) @font-lock-property-name-face))

   :language 'qmljs
   :feature 'function
   '((call_expression
      function: (identifier) @font-lock-function-call-face)
     (call_expression
      function: (member_expression
                 property: (property_identifier) @font-lock-function-call-face)))

   :language 'qmljs
   :feature 'variable
   '((variable_declarator
      name: (identifier) @font-lock-variable-name-face)
     (variable_declarator
      value: (identifier) @font-lock-variable-use-face)
     (ui_binding
      (expression_statement
       (identifier) @font-lock-variable-use-face))
     (binary_expression
      (identifier) @font-lock-variable-use-face)
     (arguments
      (identifier) @font-lock-variable-use-face))

   :language 'qmljs
   :feature 'constant
   '((true) @font-lock-constant-face
     (false) @font-lock-constant-face
     (null) @font-lock-constant-face)))

(defun sk/qml-ts-available-p ()
  "Return non-nil when Emacs can use the qmljs Tree-sitter parser."
  (and (fboundp 'treesit-ready-p)
       (treesit-ready-p 'qmljs t)))

(define-derived-mode sk-qml-ts-mode qml-mode "QML[TS]"
  "QML mode backed by the qmljs Tree-sitter parser."
  (unless (sk/qml-ts-available-p)
    (user-error "qmljs Tree-sitter parser is not available"))
  (treesit-parser-create 'qmljs)
  (sk/set-indent-width 2)
  (setq-local treesit-font-lock-settings sk-qml-ts-font-lock-settings)
  (setq-local treesit-font-lock-feature-list
              '((comment string)
                (keyword type number)
                (property function variable constant)))
  (treesit-major-mode-setup))

(when (sk/qml-ts-available-p)
  (add-to-list 'auto-mode-alist '("\\.qml\\'" . sk-qml-ts-mode)))

(provide 'sk-qml)

;;; sk-qml.el ends here
