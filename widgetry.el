(require 'widget)

(eval-when-compile
  (require 'wid-edit))

(defun w--create-module-headerbar (&optional w--chunk)
  "Create a headerbar for a module."
  (interactive) ; Only during development

  ;; Buffer setup
  (switch-to-buffer (get-buffer-create "w-headerbar-devel"))
  ;; The following prevents local variables controlling buffer editing and
  ;; things related to widget from interfering with the process of resetting the
  ;; buffer.
  (kill-all-local-variables)
  ;; TODO: it would be nice to have `yank-all-local-variables'.
  (let ((inhibit-read-only t))
    (erase-buffer))
  (remove-overlays)

  ;; Widgetry
  (widget-create 'w--module-header))

(defun w--create-module-text-field (&optional w--chunk)
  "Create a multi-line, editable text field (for W--CHUNK)."
  (switch-to-buffer (get-buffer-create "w-headerbar-devel"))
  ;; FIXME: `eval-last-sexp' on the following form causes `: \n' to be inserted.
  (widget-create '(text :keymap global-map)))


(progn (w--create-module-headerbar)
       (w--create-module-text-field))
