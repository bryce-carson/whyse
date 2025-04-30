;; -*- lexical-binding: nil; -*-
(defvar w--parse-success t
  "A simple boolean regarding the success or fialure of the last
  attempt to parse a buffer of Noweb tool syntax.")

;; FIXME: the current parse tree contains a `nil' after the chunk type
;; and number assoc, and that needs to be analyzed. Why is this `nil' in
;; the stack? I assume and believe it is because of the collapsing of
;; stringy tokens; when a token should be put back onto the stack it may
;; also be putting a `nil' onto the stack in the first call to the
;; function.
;;;; Parsing expression grammar (PEG) rules
(defun w--parse-current-buffer-with-rules ()
  "Parse the current buffer with the PEG defined for Noweb tool syntax."
  (with-peg-rules
      (;;; Overall Noweb structure
       (noweb (bob) (not header) (+ file) (not trailer) (eob))
       ;; Technically, file is a tagging keyword, but that classification only
       ;; makes sense in the Hacker's guide, not in the syntax.
       (file (bol) "@file" spc (substring path) nl
             (list (and (+ chunk)
                        (list (or (and x-chunks i-identifiers)
                                  (and i-identifiers x-chunks))))
                   ;; Trailing documentation chunk and new-lines after the xref
                   ;; and index.
                   (opt chunk)
                   (opt (+ nl)))
             `(path chunk-list -- (cons path chunk-list)))
       (path (opt (or ".." ".")) (* path-component) file-name)
       (path-component (and path-separator (+ [word])))
       (path-separator ["\\/"])
       (file-name (+ (or [word] ".")))
       (chunk begin (list (* chunk-contents)) end)
       (begin (bol) "@begin" spc kind spc ordinal (eol) nl
              (action (if (string= (cl-second peg--stack) "code")
                          (setq w--peg-parser-within-codep t))))
       (end (bol) "@end" spc kind spc ordinal (eol) nl
            (action
             (setq w--peg-parser-within-codep nil))
            ;; The stack grows down and the heap grows up,
            ;; that's the yin and yang of the computer thang
            `(kind-one
              ordinal-one
              keywords
              kind-two
              ordinal-two
              --
              (if (and (= ordinal-one ordinal-two) (string= kind-one kind-two))
                  (cons (cons (if (string= kind-one "code")
                                  'code
                                'docs)
                              ordinal-one)
                        keywords)
                (error "Chunk nesting error encountered."))))
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
         fatal
         x-undefined))
       (text (bol) "@text" spc (substring (* (and (not "\n") (any)))) nl
             `(txt -- (w--concatenate-text-tokens (cons 'text txt))))
       (nwnl (bol) (substring "@nl") nl
             ;; Be sure that when thinking about the symbol `nl' here that
             ;; you're not confusing it with the peg rule nl.
             `(nl -- (w--concatenate-text-tokens (cons 'nl "\n"))))
       (defn "@defn" spc (substring !eol) nl
         `(name -- (cons 'chunk name)))

       (use (bol) "@use" spc (substring !eol) nl
            `(name -- (if name
                                (cons 'chunk-child-usage name)
                              (error "UH-OH! There's a syntax error in the tool output!"))))
       (quotation (bol) "@quote" nl
                  (action (when w--peg-parser-within-codep
                            (error "The parser found a quotation within a code chunk. A @fatal should have been found here, but was not.")))
                  (substring (+ (and (not "@endquote") (any))))
                  (bol) "@endquote" nl
                  `(lst -- (cons 'quotation lst)))
       (line (bol) "@line" spc (substring ordinal) nl
             `(o -- (cons 'line o)))

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
        `(s1 s2 -- (cons (make-symbol s1) s2)))

       (i-definitions idx "begindefs" nl
                      (list (+ (and (+ i-isused) i-defitem)))
                      idx "enddefs" nl
                      `(definitions -- (cons 'definitions definitions)))
       (i-isused idx (substring "isused") spc (substring label) nl
                 `(u l -- (cons 'used! l)))
       (i-defitem idx (substring "defitem") spc (substring !eol) nl
                  `(d i -- (cons 'def-item i)))

       (i-usages idx "beginuses" nl
                 (list (+ (and (+ i-isdefined) i-useitem)))
                 idx "enduses" nl
                 `(usages -- (cons 'usages usages)))
       (i-isdefined idx (substring "isdefined" spc label) nl)
       (i-useitem idx (substring "useitem" spc !eol) nl) ;; !eol :== ident

       (i-identifiers idx "beginindex" nl
                      (list (+ i-entry))
                      idx "endindex" nl
                      `(l -- (cons 'i-identifiers l)))
       (i-entry idx "entrybegin" spc (substring label spc !eol) nl
                (list (+ (or i-entrydefn i-entryuse)))
                idx "entryend" nl
                `(entry-label lst -- (cons 'entry-label lst)))
       (i-entrydefn idx (substring "entrydefn") spc (substring label) nl
                    `(defn label -- (cons 'defn label)))
       (i-entryuse idx (substring "entryuse") spc (substring label) nl
                   `(use lst -- (cons 'use lst)))
       ;; @index nl was deprecated in Noweb 2.10, and @index localdefn is not
       ;; widely used (assumedly) nor well-documented, so it is unsupported by
       ;; WHYSE (contributions for improved support are welcomed).
       (i-localdefn idx "localdefn" spc !eol nl)
       (i-nl idx "nl" spc !eol nl
             (action (error (string-join
                             '("\"@index nl\" detected."
                              "This indicates hand-written @ %def syntax in the Noweb source."
                              "This syntax was deprecated in Noweb 2.10, and is entirely unsupported."
                              "Write an autodefs AWK script for the language you are using.")
                             "\n"))))

       ;; Cross-reference
       (x-label xr (substring "label" spc label) nl
                `(substr -- (cons 'x-label (cadr (split-string substr)))))
       (x-ref xr (substring "ref" spc label) nl
              `(substr --  (cons 'ref (cadr (split-string substr)))))

       ;; FIXME: improve the error handling at this point. It is not fragile
       ;; any longer, becasue most things are ignored and this is hackish;
       ;; however, the message reporting is not too helpful. It would be nice
       ;; to have _only_ the chunk name reported, and formatted with << and >>.
       ;;; Reproduction steps: make a reference to an undefined code chunk
       ;;; within another code chunk. For fixing this issue, undefined code
       ;;; chunks should also be referenced within quotations in documentation.
       (x-undefined
        xr (or "ref" "chunkbegin") spc
        (guard
         (if (string= "nw@notdef"
                      (buffer-substring-no-properties (point) (+ 9 (point))))
             (error (format "%s: %s: %s:\n@<@<%s>>"
                            "WHYSE"
                            "nw@notdef detected"
                            "an undefined chunk was referenced"
                            (buffer-substring-no-properties (progn (forward-line) (point))
                                                            (end-of-line)))))))

       (x-prev-or-next-def
        xr (substring (or "nextdef" "prevdef")) spc (substring label) nl
        `(previous-or-next-chunk-defn label -- (cons (make-symbol previous-or-next-chunk-defn) label)))

       (x-continued-definitions-of-the-current-chunk
        xr "begindefs" nl
        (list (+ (and xr (substring "defitem") spc (substring label) nl)))
        xr "enddefs" nl)

       (x-usages
        xr "beginuses" nl
        (list (+ (and xr "useitem" spc (substring label) nl)))
        xr "enduses" nl)

       (x-notused xr "notused" spc (substring !eol) nl
                  `(name -- (cons 'unused! name)))
       (x-chunks nwnl
                 nwnl
                 xr "beginchunks" nl
                 (list (+ x-chunk))
                 xr "endchunks" nl
                 `(l -- (cons 'x-chunks l)))
       (x-chunk xr "chunkbegin" spc (substring label) spc (substring !eol) nl
                (list (+ (list (and xr
                                    (substring (or "chunkuse" "chunkdefn"))
                                    `(chunk-usage-or-definition -- (make-symbol chunk-usage-or-definition))
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
    (let (w--peg-parser-within-codep
          (w--first-stringy-token? t))
      (peg-run (peg noweb) #'w--parse-failure-function))))

(defun w--parse-failure-function (lst)
  (setq w--parse-success nil)
  (pop-to-buffer (clone-buffer))
  (save-excursion
    (put-text-property (point) (point-min)
                       'face 'success)

    (put-text-property (point) (point-max)
                       'face 'error)

    (goto-char (point-max))
    (message "PEXes which failed:\n%S" lst)))
(with-temp-buffer
  (insert (shell-command-to-string
           "make --silent --file ~/src/whyse/Makefile tool-syntax"))
  (goto-char (point-min))
  (w--parse-current-buffer-with-rules))

;; Local Variables:
;; mode: lisp-interaction
;; no-byte-compile: t
;; no-native-compile: t
;; eval: (read-only-mode)
;; End:
