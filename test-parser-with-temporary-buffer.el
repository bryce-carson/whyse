;; -*- lexical-binding: nil; -*-
(defvar w--parse-success t
  "A simple boolean regarding the success or fialure of the last
  attempt to parse a buffer of Noweb tool syntax.")

;;;; Parsing expression grammar (PEG) rules
(defun w--parse-current-buffer-with-rules ()
  "Parse the current buffer with the PEG defined for Noweb tool syntax."
  (with-peg-rules
      (;;; Overall Noweb structure
       (noweb (bob) (not header) (+ file) (not trailer) (eob))
       ;; Technically, file is a tagging keyword, but that classification only
       ;; makes sense in the Hacker's guide, not in the syntax.
       (file (bol) "@file" spc (substring path) nl
             (list (and (+ chunk) (* nwnl)
                        (list (or (and x-chunks i-identifiers)
                                  (and i-identifiers x-chunks))))
                   ;; Trailing documentation chunk and new-lines
                   (opt chunk)
                   (opt (+ nl)))
             `(path chunk-list -- (list path chunk-list)))
       (path (opt (or ".." ".")) (* path-component) file-name)
       (path-component (and path-separator (+ [word])))
       (path-separator ["\\/"])
       (file-name (+ (or [word] ".")))
       (chunk begin (list (* chunk-contents)) end)
       (begin (bol) "@begin" spc kind
              ;; (action (message "A chunk was entered; kind: %s" (cl-first peg--stack)))
              spc ordinal (eol) nl
              (action (if (string= (cl-second peg--stack) "code")
                          (setq w--peg-parser-within-codep t))))
       (end (bol) "@end" spc kind
            ;; (action (message "A chunk was exited; kind: %s" (cl-first peg--stack)))
            spc ordinal (eol) nl
            (action (setq w--peg-parser-within-codep nil))
            `(kind-one ordinal-one keywords kind-two ordinal-two --
                       (if (and (= ordinal-one ordinal-two) (string= kind-one kind-two))
                                    ;;; Push the contents of the chunk to the stack in a cons
                                    ;;; cell with the car being a list of the kind and number.
                                    ;;;; E.g.:
                           ;; (("code" 3) . (@text @nl @text @nl))
                           (cons (cons kind-one ordinal-one) keywords)
                         (error "There was an issue with unbalanced or improperly nested chunks."))))
       (ordinal (substring [0-9] (* [0-9]))
                `(number -- (string-to-number number)))
       (kind (substring (or "code" "docs")))
       (chunk-contents
        (or
         ;; structural
         text
         nwnl ;; Noweb's @nl keyword, as differentiated from the rule nl := "\n".
         defn
         use ;; NOTE: related to the `identifier-used-in-module' table.
         quotation
         ;; tagging
         line
         language
         ;; index
         i-define-or-use
         i-definitions
         ;; xref
         x-prev-or-next-def
         x-continued-definitions-of-the-current-chunk
         i-usages
         x-usages
         x-label
         x-ref
         x-notused
         ;; error
         fatal))
       (text (bol) "@text" spc (substring (* (and (not "\n") (any)))) nl
             `(txt -- (list 'text txt)))
       (nwnl (bol) (substring "@nl") nl)
       (defn "@defn" spc (substring !eol) nl
         `(name -- (cons "chunk" name)))

       (use (bol) "@use" spc (substring !eol) nl
            `(chunk-name -- (if chunk-name
                                (cons "Chunk usage (child)" chunk-name)
                              (error "UH-OH! There's a syntax error in the tool output!"))))
       (quotation (bol) "@quote" nl
                  (action (when w--peg-parser-within-codep
                            (error "The parser found a quotation within a code chunk. A @fatal should have been found here, but was not.")))
                  (substring (+ (and (not "@endquote") (any))))
                  ;; (list (* (or text nwnl defn use i-define-or-use x-ref)))
                  (bol) "@endquote" nl
                  `(lst -- (cons "Quotation" lst)))
       (line (bol) "@line" spc (substring ordinal) nl
             `(o -- (cons "@line" o)))

       (language (bol) "@language" spc (substring words-eol))
       ;; Index
       (idx (bol) "@index" spc)
       (xr (bol) "@xref" spc)

       (i-define-or-use
        idx
        (substring (or "defn" "use")) spc (substring !eol) nl
        (action
         (unless w--peg-parser-within-codep
             (error "WHYSE parse error: index definition or index usage occurred outside of a code chunk.")))
        `(s1 s2 -- (cons s1 s2)))

       (i-definitions idx "begindefs" nl
                      (list (+ (and (+ i-isused) i-defitem)))
                      idx "enddefs" nl
                      `(definitions -- (cons "definitions" definitions)))
       (i-isused idx (substring "isused") spc (substring label) nl
                 `(u l -- (cons u l)))
       (i-defitem idx (substring "defitem") spc (substring !eol) nl
                  `(d i -- (cons d i)))

       (i-usages idx "beginuses" nl
                 (list (+ (and (+ i-isdefined) i-useitem)))
                 idx "enduses" nl
                 `(usages -- (cons "usages" usages)))
       (i-isdefined idx (substring "isdefined" spc label) nl)
       (i-useitem idx (substring "useitem" spc !eol) nl) ;; !eol :== ident

       (i-identifiers idx "beginindex" nl
                      (list (+ i-entry))
                      idx "endindex" nl
                      `(l -- (cons 'i-identifiers l)))
       (i-entry idx "entrybegin" spc (substring label spc !eol) nl
                (list (+ (or i-entrydefn i-entryuse)))
                idx "entryend" nl
                `(e l -- (cons e l)))
       (i-entrydefn idx (substring "entrydefn") spc (substring label) nl
                    `(d l -- (cons d l)))
       (i-entryuse idx (substring "entryuse") spc (substring label) nl
                   `(u l -- (cons u l)))
       ;; @index nl was deprecated in Noweb 2.10, and @index localdefn is not
       ;; widely used (assumedly) nor well-documented, so it is unsupported by
       ;; WHYSE (contributions for improved support are welcomed).
       (i-localdefn idx "localdefn" spc !eol nl)
       (i-nl idx "nl" spc !eol nl (action (error (string-join
                                                  '("\"@index nl\" detected."
                                                   "This indicates hand-written @ %def syntax in the Noweb source."
                                                   "This syntax was deprecated in Noweb 2.10, and is entirely unsupported."
                                                   "Write an autodefs AWK script for the language you are using.")
                                                  "\n"))))

       ;; Cross-reference
       (x-label xr (substring "label" spc label) nl)
       (x-ref xr (substring "ref" spc label) nl
              `(substr --  (cons "ref" (cadr (split-string substr)))))

       (x-prev-or-next-def
        xr (substring (or "nextdef" "prevdef")) spc (substring label) nl
        `(chunk-defn label -- (append chunk-defn label)))

       (x-continued-definitions-of-the-current-chunk
        xr "begindefs" nl
        (list (+ (and xr (substring "defitem") spc (substring label) nl)))
        ;; NOTE: development statement only; remove this before release.
        ;; (action (message "peg--stack := \n%S" peg--stack))
        xr "enddefs" nl)

       (x-usages
        xr "beginuses" nl
        (list (+ (and xr "useitem" spc (substring label) nl)))
        xr "enduses" nl)

       (x-notused xr "notused" spc (substring !eol) nl
                  `(chunk-name -- (cons "notused" chunk-name)))

       (x-chunks xr "beginchunks" nl
                 (list (+ x-chunk))
                 xr "endchunks" nl
                 `(l -- (cons 'x-chunks l)))
       (x-chunk xr "chunkbegin" spc (substring label) spc (substring !eol) nl
                (list (+ (list (and xr
                                    (substring (or "chunkuse" "chunkdefn"))
                                    spc
                                    (substring label)
                                    nl))))
                xr "chunkend" nl)

       ;; Associates label with tag (@xref tag $LABEL $TAG)
       (x-tag xr "tag" spc label spc !eol nl)
       (label (+ (or "-" [alnum]))) ;; A label never contains whitespace.


       ;; Error
       ;; User-errors (header and trailer) and tool-error (fatal)
       ;; Header and trailer's further text is irrelevant for parsing, because they cause errors.
       (header (bol) "@header" ;; formatter options
               (action (error "[ERROR] Do not use totex or tohtml in your noweave pipeline.")))
       (trailer (bol) "@trailer" ;; formatter
                (action (error "[ERROR] Do not use totex or tohtml in your noweave pipeline.")))
       (fatal (bol) "@fatal"
              (action (error "[FATAL] There was a fatal error in the pipeline. Stash the work area and submit a bug report against Noweb, WHYSE, and other relevant tools.")))
       ;; Helpers
       (nl (eol) "\n")
       (!eol (+ (not "\n") (any)))
       (spc " "))
    (let (w--peg-parser-within-codep)
      (peg-run
       (peg noweb)
       (lambda (lst)
         (setq w--parse-success nil)
         (pop-to-buffer (with-current-buffer
                            (generate-new-buffer "<WHYSE Parse failure log>")
            (insert (format "PEXes which failed:\n%S" lst))
            (current-buffer))))))))

(with-temp-buffer
  (insert (shell-command-to-string
           "make --silent --file ~/src/whyse/Makefile tool-syntax"))
  (goto-char (point-min))
  (cl-prettyprint (w--parse-current-buffer-with-rules))
  (pop-to-buffer
   (clone-buffer
    (generate-new-buffer-name
     (format "<WHYSE %s> Parsing tool syntax with a temporary buffer"
             (if w--parse-success "SUCCESS" "FAILURE"))))))

;; Local Variables:
;; mode: lisp-interaction
;; no-byte-compile: t
;; no-native-compile: t
;; eval: (read-only-mode)
;; End:
