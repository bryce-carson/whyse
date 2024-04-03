@file whs.nw
@begin docs 0
@text The Bluetooth Device has been connected successfully.
@nl
@end docs 0

(defun test-pex ()
  (with-peg-rules
      ((noweb (list (+ file)))
       (file (bol) "@file" [space] (substring (and (not (or "." (eol))) (+ [word])) "." (and (not (eol)) (+ [word]))) (eol) (list chunk (* chunk)))
       (chunk begin (substring (* (any))) end)
       (begin (bol) "@begin" [space] kind [space] ordinal (eol))
       (end (bol) "@end" [space] kind [space] ordinal (eol)
            `(k1 z1 keywords k2 z2 --
                 (if (and (= z1 z2) (string= k1 k2))
              ;;; Push the contents of the chunk to the stack in a cons
              ;;; cell with the car being a list of the kind and number.
              ;;;; E.g.:
                     ;; (("code" 3) . (@text @nl @text @nl))
                     (cons (list k1 z1) keywords)
                   (error "There was an issue with unbalanced or improperly nested chunks."))))
       (ordinal (substring [0-9] (* [0-9]))
                `(number -- (string-to-number number)))
       (kind (substring (or "code" "docs"))))
    (goto-char 0)
    (peg-run (peg noweb))))


(test-pex)

;; Local Variables:
;; major-mode: lisp-interaction
;; End:
