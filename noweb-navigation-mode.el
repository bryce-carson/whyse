(define-minor-mode nwn-mode
  "Noweb Narrowing minor mode provides alternative motion commands
          between pages, defined by a buffer-local value of
          `page-delimiter' appropriate for Noweb chunks."
  :lighter " nWn "
  :list '(fundamental-mode text-mode latex-mode noweb-mode poly-noweb-mode)
  :keymap '(([next] . nwn--forward-page)
            ([prior] . nwn--backward-page))
  (if 
      (if nwn-mode
          (progn (make-local-variable 'page-delimiter)
                 
                 (nwn-narrow-to-page))
        (kill-local-variable 'page-delimiter)
        (when (buffer-narrowed-p)
          (widen)))
      (message "Current buffer is not a noweb file; refusing to enable nwn-mode!")))

(define-child-mode noweb-navigation-mode text-mode)
(defun noweb-navigation-mode (&rest mode-arguments)
  "\[COMMAND] is exclusively for use as a :head-mode and :tail-mode with poly-noweb. It has no other purpose.

\{KEYMAP}

\<KEYMAP>"

  (kill-all-local-variables)
  (set-variable 'major-mode noweb-navigation-mode)
  (use-local-map
   (let ((map (make-sparse-keymap)))
     ;; TODO: these dwim functions should be cyclic. Once at the last definition
     ;; of a chunk continuing to the next should return the user to the first
     ;; definition of the chunk.
     (define-key map "n" #'next-noweb-chunk-definition-dwim)
     (define-key map "p" #'previous-noweb-chunk-definition-dwim)

     ;; TODO: these dwim functions should cycle through the next visible
     ;; defintions of a chunk which is the sibling of the currently visited
     ;; chunk.
     (define-key map "S-n" #'next-noweb-chunk-sibling-definition-dwim)
     (define-key map "S-p" #'previous-noweb-chunk-sibling-definition-dwim)

     ;; TODO: these dwim functions should cycle through parents of the currently
     ;; visited chunk.
     (define-key map "M-n" #'next-noweb-chunk-parent-definition-dwim)
     (define-key map "M-p" #'previous-noweb-chunk-parent-definition-dwim)
     map)))
