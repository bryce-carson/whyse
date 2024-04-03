(defun test-pex ()
  (with-peg-rules
      ;; Overall Noweb structure
      ((noweb (bob) (+ file) (if (eob)) (action (message "End of buffer encountered while parsing.")))

       ;; Helpers
       (empty-line (bol) (eol) "\n")
       (new-line (eol) "\n"
                 (action (message "A new line was matched.")))
       (not-eol (+ (not "\n") (any)))
       (many-before-eol not-eol new-line)

       (file (bol) "@file" [space] (substring path) new-line
             (list (+ chunk))
             `(path chunk-list -- (list path chunk-list)))

       (path (opt (or ".." ".")) (* path-component) file-name)
       (path-component (and path-separator (+ [word])))
       (path-separator ["\\/"])
       (file-name (+ (or [word] ".")))

       (chunk begin (list (* keyword)) end)
       (begin (bol) "@begin" [space] kind [space] ordinal (eol) "\n"
              (action (message "Chunk @begin matched.")))
       (end (bol) "@end" [space] kind [space] ordinal (eol) "\n"
            (action (message "Chunk @end matched."))
            (opt (if begin)
                 (action (message "[DEBUG] A begin [unconsumed] follows this end.")))
            `(kind-one ordinal-one keywords kind-two ordinal-two --
                 (if (and (= ordinal-one ordinal-two) (string= kind-one kind-two))
                             ;;; Push the contents of the chunk to the stack in a cons
                             ;;; cell with the car being a list of the kind and number.
                             ;;;; E.g.:
                     ;; (("code" 3) . (@text @nl @text @nl))
                   (cons (list kind-one ordinal-one) keywords)
                   (error "There was an issue with unbalanced or improperly nested chunks."))))
       (ordinal (substring [0-9] (* [0-9]))
                `(number -- (string-to-number number)))
       (kind (substring (or "code" "docs")))

       (keyword
        (or
         ;; structural
         text
         nl
         defn
         use ;; NOTE: related to the `identifier-used-in-module' table.
         quotation

         ;; tagging
         line
         language
         index
         xref

         ;; user error
         header
         trailer

         ;; error
         fatal))

       (text (bol) "@text" [space] (substring (* (and (not "\n") (any)))) (eol) "\n")
       (nl (bol) "@nl" (eol) "\n")

       (defn "@defn" [space] (substring not-eol) new-line
         `(cdefn -- (cons "Chunk definition" cdefn)))

       (use (bol) "@use" [space] (action (message "\"@use \" matched"))
            (substring not-eol) new-line
            `(chunk-name -- (if chunk-name
                                (cons "Chunk usage (child)" chunk-name)
                              (error "UH-OH! There's a syntax error in the tool output!"))))

       (quotation beginquote (list (* keyword)) endquote)
       (beginquote (bol) (substring "@quote") new-line)
       (endquote (bol) (substring "@endquote") new-line
                 `(bq kw eq -- (if (and (string= bq "@quote")
                                        (string= eq "@endquote"))
                                   (cons "Quotation" kw)
                                 (error "UH-OH! There's a parsing bug related to quotations."))))

       (line (bol) "@line" [space] (substring ordinal) new-line
             `(o -- (cons "@line" o)))

       (language (bol) "@language" [space] (substring many-before-eol))

       ;; NOTE: alike xref-keyword, index-keyword tokens handle the end of the
       ;; line regardless. The index token handles only the beginning of the
       ;; line.
       (index (bol) "@index" [space] (opt index-keyword))

       ;;; FIXME: why did I define it with optionally? Is there a possibility
       ;;; that @xref can be followed by a newline directly?
       (xref (bol) "@xref" [space]
             (action (message "\"@xref \" matched"))
             ;; NOTE: each xref-keyword individually handles the end of the
             ;; line, since it composes the remainder of the line regardless.
             (opt xref-keyword))

       ;; indexing keywords
       (index-keyword
        (or
         i-defn
         i-localdefn
         i-use
         i-nl

         i-begindefs
         i-isused
         i-defitem
         i-enddefs

         i-beginuses
         i-isdefined
         i-useitem
         i-enduses

         i-beginindex
         i-entrybegin
         i-entryuse
         i-entrydefn
         i-entryend
         i-endindex)

        ;; IMPORTANT
        new-line)

       (i-defn "defn" [space] (substring not-eol))
       (i-localdefn "localdefn" [space] (substring not-eol))
       (i-use "use" [space] (substring not-eol))
       (i-nl "nl" [space] (substring not-eol))

       (i-begindefs "begindefs")
       (i-isused "isused" [space] (substring not-eol))
       (i-defitem "defitem" [space] (substring not-eol))
       (i-enddefs "enddefs")

       (i-beginuses "beginuses")
       (i-isdefined "isdefined" [space] (substring not-eol))
       (i-useitem "useitem" [space] (substring not-eol))
       (i-enduses "enduses")

       (i-beginindex "beginindex")
       (i-entrybegin "entrybegin" [space] (+ [word]) [space] (substring not-eol))
       (i-entryuse "entryuse" [space] (substring not-eol))
       (i-entrydefn "entrydefn" [space] (substring not-eol))
       (i-endentry "entryend")
       (i-endindex "endindex")

       ;; cross-referencing keywords
       (xref-keyword
        (or
         x-label
         x-ref

         x-begindefs
         x-prevdef
         x-nextdef
         x-defitem
         x-enddefs

         x-beginuses
         x-useitem
         x-enduses
         x-notused

         x-beginchunks
         x-chunkbegin
         x-chunkuse
         x-chunkdefn
         x-chunkend
         x-endchunks

         x-tag)

        ;; IMPORTANT
        new-line
        (action (message "An xref-keyword was matched.")))

       (x-label
        "label" [space] (substring not-eol))
       (x-ref
        "ref" [space] (substring not-eol)
        `(reference -- (cons "XREF" reference)))

       ;; FIXME: TODO:
       (x-begindefs (substring not-eol))

       (x-prevdef
        "prevdef" [space] (substring not-eol))
       (x-nextdef
        "nextdef" [space] (substring not-eol))

       (x-beginuses
        "beginuses")
       (x-useitem
        "useitem" [space] (substring not-eol))
       (x-enduses
        "enduses")
       (x-notused
        "notused" [space] (substring not-eol))

       (x-beginchunks
        "beginindex")
       (x-chunkbegin
        "chunkbegin" [space] (+ [word]) [space] not-eol)
       (x-chunkuse
        "chunkuse" [space] (+ [word]))
       (x-chunkdefn
        "chunkdefn" [space] (+ [word]))
       (x-chunkend
        "chunkend")
       (x-endchunks
        "endchunks")

       ;; Associates label with tag (word with not-eol)
       (x-tag
        "tag" [space] (+ [word]) [space] not-eol)

       ;; User-errors (header and trailer) and tool-error (fatal)
       (header (bol) "@header"
               (action (error "[ERROR] Do not use totex or tohtml in your noweave pipeline.")))
       (trailer (bol) "@trailer"
                (action (error "[ERROR] Do not use totex or tohtml in your noweave pipeline.")))
       (fatal (bol) "@fatal"
              (action (error "[FATAL] There was a fatal error in the pipeline. Stash the work area and submit a bug report against Noweb, WHS, and other relevant tools."))))

    (goto-char 0)
    (peg-run (peg noweb)
             (lambda (lst)
               (message "[ERROR] The following PEXes failed:%S" lst)))))

;; EVAL
(test-pex)

;; Copyright © 2023 Bryce Carson

;; This file is not part of GNU Emacs.

;; This file is part of WHS, an Emacs Lisp package in-development. As the file
;; will possibly contribute towards an academic publication, usages of the code
;; above which do not respect academic integrity and honesty are considered
;; immoral by the author. Please don't violate academic integrity by deriving
;; published work from the above code without contacting the original author and
;; considering cooperation towards a greater academic work together. Thank you.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <https://www.gnu.org/licenses/>.

;; If you cannot contact the author by electronic mail at the address
;; provided in the author field above, you may address mail to be
;; delivered to

;; Bryce A. Carson
;; Research Assistant
;; Deparment of Biology

;; Mount Royal University
;; 4825 Mount Royal Gate SW
;; Calgary, Alberta, Canada
;; T3E 6K6

;; Local Variables:
;; major-mode: lisp-interaction
;; no-byte-compile: t
;; auto-compile-native-compile: nil
;; End:
