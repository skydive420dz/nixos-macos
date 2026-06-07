;;; sk-dashboard.el --- Sky home buffer -*- lexical-binding: t; -*-

(require 'subr-x)

(defconst sk/dashboard-buffer-name "*Sky Home*"
  "Name of the Sky home buffer.")

(defconst sk/dashboard-logo-file
  (expand-file-name "assets/skydive420dz.svg" sk/user-directory)
  "Logo shown in the Sky home buffer.")

(defun sk/dashboard--insert-left-text (text &optional face)
  "Insert TEXT near the left edge, optionally using FACE."
  (insert "  ")
  (insert (if face (propertize text 'face face) text))
  (insert "\n"))

(defun sk/dashboard--insert-logo (image)
  "Insert dashboard IMAGE near the top-left edge."
  (insert "  ")
  (insert-image image)
  (insert "\n"))

(defun sk/dashboard-render ()
  "Render the Sky home buffer."
  (let ((inhibit-read-only t))
    (erase-buffer)
    (setq-local cursor-type nil
                mode-line-format nil
                truncate-lines t)
    (display-line-numbers-mode -1)
    (let ((image (when (and (display-graphic-p)
                            (file-readable-p sk/dashboard-logo-file)
                            (image-type-available-p 'svg))
                   (ignore-errors
                     (create-image sk/dashboard-logo-file 'svg nil :width 520 :ascent 'center)))))
      (insert "\n")
      (if image
          (sk/dashboard--insert-logo image)
        (sk/dashboard--insert-left-text "Skydive420dz" 'bold)))
    (goto-char (point-min))))

(define-derived-mode sk/dashboard-mode special-mode "Sky"
  "Major mode for the Sky home buffer."
  (setq-local buffer-read-only t))

(defun sk/dashboard-buffer ()
  "Return the Sky home buffer, creating it when needed."
  (let ((buffer (get-buffer-create sk/dashboard-buffer-name)))
    (with-current-buffer buffer
      (sk/dashboard-mode)
      (sk/dashboard-render))
    buffer))

(defun sk/dashboard ()
  "Switch to the Sky home buffer."
  (interactive)
  (switch-to-buffer (sk/dashboard-buffer)))

(defun sk/dashboard-buffer-p (&optional buffer)
  "Return non-nil when BUFFER is the Sky home buffer."
  (string= (buffer-name (or buffer (current-buffer))) sk/dashboard-buffer-name))

(setq initial-buffer-choice #'sk/dashboard-buffer)

(provide 'sk-dashboard)

;;; sk-dashboard.el ends here
