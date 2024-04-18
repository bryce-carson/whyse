(widget-create 'push-button
               :notify (lambda (&rest ignore)
                         (w--reinitialize-whsye-buffer))
               "Reinitialize whyse widget-test buffer")
[Reinitialize whyse widget-test buffer]

(defun erase-widget-enabled-buffer ()
  (kill-all-local-variables)
  (let ((inhibit-read-only t))
    (erase-buffer))
  (remove-overlays))

(defun w--reinitialize-whsye-buffer (&optional number name)
  "Create a widget-enabled buffer for whyse development."
  (interactive)
  (switch-to-buffer "*whyse development*")
  (erase-widget-enabled-buffer)
  (widget-create 'push-button
                 ;; TODO: activating this button should offer to rename the
                 ;; chunk or go to its first definoition. Presently it is a no-op with a message.
                 :notify #'ignore
                 :format "%[<<%t>>%]"
                 :tag (format "%s %s"
                              w--buffer-chunk-name
                              (w--current-chunk-first-definition-chunk-number)))
  (widget-insert " ")
  (widget-create 'push-button
                 :notify (lambda (&rest ignore)
                           (w--switch-to-chunk
                            (w--get-chunk-continuation-number
                             w--buffer-chunk-number)))
                 :format "%[ %t %]"
                 :tag (format "%s"
                              (if-let ((n (w--get-chunk-continuation-number)))
                                  n
                                "NONE")))
  (widget-insert (w--get-chunk-contents
                  w--buffer-chunk-number
                  w--buffer-file-number)))

;; TODO
(defun w--get-chunk-contents (chunk-number file-number)
  "Return the text contents of the chunk CHUNK-NUMBER.

If the chunk is empty `nil' is returned."
  (w--nth-chunk-of-document
   chunk-number
   (w--nth-document file-number parse-tree)))

;; TODO
(defun w--current-chunk-first-definition-chunk-number ()
  "non-nil and a number for code chunks; nil for documentation chunks.

Code chunks may have more than one chunk comprising their
definition, hence all code chunks have a first definition chunk.
This retrieves the number of that chunk."
  nil)

(defun w--get-chunk-continuation-number ()
  "non-nil if chunk NUMBER has a continued chunk defintion.

If this is the only or last definition of this chunk then nil is returned.

If at least one more chunk continues this definition its chunk number is returned."
 nil)

(defun w--switch-to-chunk (number)
  "Switch the current buffer's noweb chunk to the chunk numbered NUMBER.

This function changes the state of the whyse application
significantly."
  (setq w--buffer-chunk-number number
        w--buffer-chunk-name (w--get-chunk-name number))
  (w--reinitialize-whsye-buffer))

(defun w--get-chunk-name (number)
  "Get the name of the chunk with number NUMBER, or return the default name."
  "UNKNOWN")

(make-variable-buffer-local
 (defvar w--buffer-chunk-name "↔DOCUMENTATION↔"
   "The name of the code chunk in the current buffer.

If the current buffer's chunk is a documentation chunk, then the
default value is displayed indicating that it is not a code
chunk. It is possible, but quite unlikely the default value is
the same as a code chunk."))

(make-variable-buffer-local
 (defvar w--buffer-chunk-number 0
   "The index number of the current buffer's displayed chunk."))

(make-variable-buffer-local
 (defvar w--buffer-file-number 0
   "The index number of the file of the current buffer's displayed chunk."))
