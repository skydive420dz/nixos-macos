;;; theme.el -*- lexical-binding: t; -*-

(require 'subr-x)

(defconst sk/doom-dir
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing the Doom user config.")

(defconst sk/theme-default
  '((foreground . "#f0efeb")
    (foreground-alt . "#ccc4b4")
    (background . "#1a1d21")
    (background-alt . "#171a1e")
    (surface . "#22262b")
    (surface-strong . "#282c34")
    (border . "#3d424a")
    (border-active . "#b4c0c8")
    (accent . "#b4c0c8")
    (accent-alt . "#b4bcc4")
    (muted . "#676d77")
    (success . "#b8c4b8")
    (warning . "#d4ccb4")
    (danger . "#cdacac")
    (selection-foreground . "#1a1d21")
    (selection-background . "#b4c0c8")
    (string . "#b8c4b8")
    (function . "#b4c0c8")
    (keyword . "#b4bcc4")
    (number . "#d4ccb4")
    (type . "#d4ccb4")
    (builtin . "#b4c4bc")
    (preprocessor . "#ccc4b4")
    (comment . "#676d77")
    (black . "#22262b")
    (red . "#cdacac")
    (green . "#b8c4b8")
    (yellow . "#d4ccb4")
    (blue . "#b4bcc4")
    (magenta . "#ccc4b4")
    (cyan . "#b4c0c8")
    (white . "#f0efeb"))
  "Static SkyNight theme tokens for macOS.")

(defvar sk/theme (copy-tree sk/theme-default)
  "Active Sky theme tokens.")

(defun sk/theme-config-home ()
  "Return the XDG config directory."
  (or (getenv "XDG_CONFIG_HOME")
      (expand-file-name "~/.config")))

(defun sk/theme-dir ()
  "Return the local Doom theme directory."
  (expand-file-name "themes" sk/doom-dir))

(defun sk/register-theme-paths ()
  "Make local Sky themes visible to Emacs."
  (add-to-list 'load-path (sk/theme-dir))
  (add-to-list 'custom-theme-load-path (sk/theme-dir)))

(defun sk/load-theme-common ()
  "Load the shared Sky theme definitions from disk."
  (load (expand-file-name "sky-theme-common.el" (sk/theme-dir)) nil 'nomessage))

(defun sk/reload-theme-tokens ()
  "Reload static SkyNight theme tokens."
  (setq sk/theme (copy-tree sk/theme-default)))

(defun sk/theme-color (name)
  (alist-get name sk/theme))

(defun sk/current-doom-theme ()
  "Return the static SkyNight Doom theme."
  'sky-night)

(defun sk/reset-sky-theme-faces ()
  "Clear stale user face specs for faces owned by Sky themes."
  (sk/load-theme-common)
  (let ((faces (delq nil
                     (mapcar (lambda (face)
                               (when (facep face)
                                 (list face nil)))
                             sky-theme-managed-faces))))
    (when faces
      (apply #'custom-theme-reset-faces 'user faces))))

(defun sk/load-sky-theme ()
  "Reload the active native Sky theme."
  (interactive)
  (sk/register-theme-paths)
  (sk/reload-theme-tokens)
  (mapc #'disable-theme custom-enabled-themes)
  (sk/reset-sky-theme-faces)
  (load-theme (sk/current-doom-theme) t)
  (when (called-interactively-p 'interactive)
    (message "Loaded SkyNight")))

(sk/register-theme-paths)
(sk/reload-theme-tokens)

(provide 'theme)
