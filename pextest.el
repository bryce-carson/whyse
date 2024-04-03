@file /home/bryce/src/whs/whs.nw
@begin docs 0
@text The Bluetooth Device has been connected successfully.
@nl
@text The Bluetooth Device has been connected successfully.
@nl
@text The Bluetooth Device has been connected successfully.
@text The Bluetooth Device has been connected successfully.
@text The Bluetooth Device has been connected successfully.
@nl
@nl
@nl
@nl
@end docs 0
@begin docs 1
@text The Bluetooth Device has been connected successfully.
@nl
@end docs 1
@file ../whs.nw
@begin docs 0
@text Hello, world of literate programming.
@nl
@end docs 0

(defun test-pex ()
  (with-peg-rules
      ((noweb (+ file))
       (file (bol) "@file" [space] path (eol) "\n"
             (list (+ chunk))
             `(filename chunks -- (cons filename chunks)))

       ;;; Valid filenames the PEX was tested against.
       ;; /home/bryce/src/whs/whs.nw
       ;;; and,
       ;; ../whs.nw
       (path (substring (opt (or ".." ".")) (* path-component) file-name))
       (path-component (and path-separator (+ [word])))
       (path-separator ["\\/"])
       (file-name (+ (or [word] ".")))

       (begin (bol) "@begin" [space] kind [space] ordinal (eol) "\n")
       (end (bol) "@end" [space] kind [space] ordinal (eol) "\n"
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
       (kind (substring (or "code" "docs")))

       ;; Chunk keyword definitions for what is in pextest.el (this file).
       (chunk begin
              ;; keywords
              (list (* (or text nl)))
              end)
       (text (bol) "@text" [space] (substring (* (and (not "\n") (any)))) (eol) "\n")
       (nl (bol) "@nl" (eol) "\n"))
    (goto-char 0)
    (peg-run (peg noweb))))

(test-pex)

;; Local Variables:
;; major-mode: lisp-interaction
;; End:
