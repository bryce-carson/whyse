@file /home/bryce/src/whs/whs.nw
@begin docs 0
@text %% -*- mode: Poly-Noweb; noweb-code-mode: emacs-lisp-mode; fill-column: 72; -*-
@nl
@text %% FIXME: finduses.nw and the recognizer.nw need some tweaking to better support LISP identifiers. It may be as simple as moving `-' from SYMBOLS to ALPHANUMERIC.
@nl
@text % Copyright © 2023 Bryce Carson
@nl
@text \documentclass{article}
@nl
@text 
@nl
@text %% FONT
@nl
@text \usepackage[T1]{fontenc}
@nl
@text \usepackage{tgbonum}
@nl
@text 
@nl
@text %% MARGIN
@nl
@text \usepackage[margin=1in]{geometry}
@nl
@text \usepackage{mparhack}
@nl
@text \usepackage{mathptmx}
@nl
@text 
@nl
@text %% FIXME: biblatex causes knoweb to be unable to compile.
@nl
@text %% \usepackage{biblatex}
@nl
@text %% \addbibresource{\whs.bib}
@nl
@text 
@nl
@text \usepackage[smallcode,nohyperidents]{knoweb}
@nl
@text \usepackage[colorlinks,backref]{hyperref}
@nl
@text 
@nl
@text \usepackage{syntax}
@nl
@text \usepackage{xspace}
@nl
@text \usepackage{paralist}
@nl
@text \usepackage{color}
@nl
@text 
@nl
@text %% NOTE: used in the figure of the WHS frame layout.
@nl
@text \usepackage{fancyvrb}
@nl
@text 
@nl
@text \newcommand{\historicalRef}[1]{For some commentary on the development history of WHS related to this text, see §\ref{#1}.}
@nl
@text 
@nl
@text %% BEGIN
@nl
@text \pagestyle{noweb}
@nl
@text \begin{document}
@nl
@text 
@nl
@text %% \section{Preface}
@nl
@text %% A paper describing this implementation---written in Noweb and browsable,
@nl
@text %% editable, and auditable with WHS, or readable in the printed form---is
@nl
@text %% hoped to be submitted to The Journal of Open Source Software (JOSS)
@nl
@text %% before the year 2024. N.B.: the paper will include historical
@nl
@text %% information about literate programming, and citations (especially of
@nl
@text %% those given credit in the 
@quote
@xref ref NW4UAmWz-3RJbFb-1
@use Commentary
@endquote
@text  for ideating WHS itself).
@nl
@text 
@nl
@text %% \subsection{On literate programming}
@nl
@text %% Literate programs can be organized in multiple ways; particularly, I
@nl
@text %% note these forms of organization here. How WHS implementations may
@nl
@text %% influence literate programming style, taste, or form will be interesting
@nl
@text %% to observe (as it is a multi-langual art and will benefit from both the
@nl
@text %% traditional language arts greatly as well as ``code smell'' [a strange
@nl
@text %%   term programmers have invented to somewhat describe computer--language
@nl
@text %%   arts]).
@nl
@text 
@nl
@text %% \begin{enumerate}
@nl
@text %% \item Algorithmic
@nl
@text %% \item Architectural
@nl
@text %% \item Linear
@nl
@text %% \item Notebook--like (Jupyter and iPython--like, which were influenced by Sweave)
@nl
@text %% \item Sweave--like (R Noweb ::= R Markdown)
@nl
@text %% \end{enumerate}
@nl
@text 
@nl
@text %% The organization of this literate program is \textit{linear}, with
@nl
@text %% aspects of the program explained as the user would encounter them, more
@nl
@text %% or less.
@nl
@text 
@nl
@text \section{Projects}\label{Projects}
@nl
@text WEB Hypertext System's Emacs implementation (WHS) is a project-based
@nl
@text application. Projects are lists registered with WHS using the ``Easy
@nl
@text Customization Interface'', which provides a simple way to make the
@nl
@text necessary information known to WHS. Users register a literate
@nl
@text programming project (only Noweb–based programming is supported) as an
@nl
@text item in the customization variable 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@endquote
@text ; further
@nl
@text project data is contained in a Common Lisp struct during runtime.
@nl
@text 
@nl
@text In short, a project is composed of several things:
@nl
@text 
@nl
@text \begin{itemize}
@nl
@text \item a name,
@nl
@text \item a Noweb source file,
@nl
@text \item a shell command to run a user-defined script
@nl
@text   %% FIXME: textsc is not working in an unordered list
@nl
@text \item an \textsc{SQLite3} database, and a connection thereto,
@nl
@text \item a frame,
@nl
@text \item and date-time information (creation, edition, and export).
@nl
@text \end{itemize}
@nl
@text 
@nl
@text The struct keeps some information during runtime, like the connection,
@nl
@text but other information is generated at runtime (such as the filename of
@nl
@text the database). These items are each explained in this section. If some
@nl
@text item is not well-enough explained in this section, please try editing
@nl
@text the Noweb source and improving the explanataion and creating a
@nl
@text pull-request against the WHS Emacs Lisp repository on its Git forge; you
@nl
@text may also submit your edition by email to the package maintainer.
@nl
@text 
@nl
@text Users of WHS in Emacs are expected to be familiar with Noweb; this does
@nl
@text not include how Noweb is built from source (that is arcane, supposedly)
@nl
@text or how filters are implemented with Sed, AWK, or other languages. Users
@nl
@text must know, however, how to write a custom command-line for Noweave (read
@nl
@text the manual section regarding the \texttt{-v} option).
@nl
@text 
@nl
@text Developers of WHS extensions (in either SQL or Emacs Lisp) should read
@nl
@text the Noweb Hacker's Guide until they understand it, afterwards reading
@nl
@text this documentation several times until the full implementation is
@nl
@text understood. I recommend modifying the system using itself to keep
@nl
@text organized, and writing literately; you'll thank yourself later for doing
@nl
@text so.
@nl
@text 
@nl
@text A customization group for WHS is defined to organize its customization
@nl
@text variables, and these details are explained before moving on to explain the
@nl
@text struct used during runtime.
@nl
@text 
@nl
@end docs 0
@begin code 1
@xref label NW4UAmWz-4YCtgL-1
@xref ref NW4UAmWz-4YCtgL-1
@defn Customization and global variables
@xref nextdef NW4UAmWz-4YCtgL-2
@xref begindefs
@xref defitem NW4UAmWz-4YCtgL-2
@xref enddefs
@xref beginuses
@xref useitem NW4UAmWz-4e7Hxw-1
@xref enduses
@nl
@xref ref NW4UAmWz-4YCtgL-1
@index defn whs
@text (defgroup 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text  nil
@nl
@text   "The WEB Hypertext System."
@nl
@text   :tag "WHS"
@nl
@text   :group 'applications)
@nl
@nl
@xref ref NW4UAmWz-4YCtgL-1
@index defn whs-registered-projects
@text (defcustom 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@text  nil
@nl
@text   "This variable stores all of the projects that are known to WHS."
@nl
@text   :group 'whs
@nl
@text   :type '(repeat 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --project-widget)
@nl
@text   :require 'widget
@nl
@text   :tag "WHS Registered Projects")
@nl
@nl
@index begindefs
@index isused NW4UAmWz-4YCtgL-1
@index isused NW4UAmWz-Q9qs2-1
@index isused NW4UAmWz-2Oqtqm-1
@index isused NW4UAmWz-4YCtgL-2
@index isused NW4UAmWz-3ow68X-1
@index isused NW4UAmWz-WGu1Q-1
@index isused NW4UAmWz-qqZnA-1
@index isused NW4UAmWz-3Kb5Dm-1
@index isused NW4UAmWz-ppSxp-1
@index isused NW4UAmWz-28WWma-1
@index isused NW4UAmWz-10UuOZ-1
@index isused NW4UAmWz-3uphDg-1
@index isused NW4UAmWz-3X3ATI-1
@index isused NW4UAmWz-4AI2uT-1
@index defitem whs
@index isused NW4UAmWz-4YCtgL-1
@index isused NW4UAmWz-Q9qs2-1
@index isused NW4UAmWz-2Oqtqm-1
@index defitem whs-registered-projects
@index enddefs
@end code 1
@begin docs 2
@text 
@nl
@text 
@nl
@text The Widget feature is required by the registered projects variable, but
@nl
@text may be redundant because the Easy Customization Interface is itself
@nl
@text implemented with The Emacs Widget Library. Requiring the library may be
@nl
@text undesireable, as 
@quote
@text (require 'widget)
@endquote
@text  will be eagerly evaluated upon
@nl
@text Emacs' initialization when 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@endquote
@text  is set to its
@nl
@text saved custom value. However, there may be a good reason to eagerly
@nl
@text evaluate that form: the Widget feature will be available immediately,
@nl
@text and widgets will be used in buffers to provide TUI buttons for
@nl
@text navigation between modules of a literate program (at least, that is the
@nl
@text design of the program at this point in development), so having this
@nl
@text feature available sooner than later is okay. The feature is required by
@nl
@text the package regardless.
@nl
@text 
@nl
@text The 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --project-widget
@endquote
@text  type used for the registered projects
@nl
@text variable is a simple list widget containing the name of the project and
@nl
@text its Noweb source file, along with a filename for a shell script which
@nl
@text generates the Noweb tool syntax for this project. Each Noweb project has
@nl
@text a different command-line, and some are complex enough to have a
@nl
@text Makefile, or multiple Makefiles! Noweb itself is an example of that
@nl
@text level of complexity. The shell script is later executed by WHS upon
@nl
@text loading the project, and the standard output captured for parsing by a
@nl
@text PEG parser.
@nl
@text 
@nl
@end docs 2
@begin code 3
@xref label NW4UAmWz-2JNgIC-1
@xref ref NW4UAmWz-2JNgIC-1
@defn Widgets
@xref beginuses
@xref useitem NW4UAmWz-4e7Hxw-1
@xref enduses
@nl
@text (define-widget 'whs--project-widget 'list
@nl
@text   "The WHS project widget type."
@nl
@text   :format "\n%v\n"
@nl
@text   :offset 0
@nl
@text   :indent 0
@nl
@nl
@text   ;; NOTE: the convert-widget keyword with the argument
@nl
@text   ;; 'widget-types-convert-widget is absolutely necessary for ARGS to be
@nl
@text   ;; converted to widgets.
@nl
@text   :convert-widget 'widget-types-convert-widget
@nl
@text   :args '((editable-field
@nl
@text            :format "%t: %v"
@nl
@text            :tag "Name"
@nl
@text            :value "")
@nl
@nl
@text           (file
@nl
@text            :tag "Noweb source file (*.nw)"
@nl
@text            :format "%t: %v"
@nl
@text            :valid-regexp ".*\\.nw$"
@nl
@text            :value "")
@nl
@nl
@text           (string
@nl
@text            :tag "A shell command to run a shell script to generates Noweb tool syntax"
@nl
@text            :format "%t: %v"
@nl
@text            :documentation "A shell script which will produce the
@nl
@text            Noweb tool syntax. Any shell commands involved with
@nl
@text            noweave should be included, but totex should of course
@nl
@text            be excluded from this script. The script should output
@nl
@text            the full syntax to standard output. See the Noweb
@nl
@text            implementation of WHS for explanation."
@nl
@text            :value "")))
@nl
@nl
@end code 3
@begin docs 4
@text 
@nl
@text 
@nl
@text NB: Comments may be superfluous in a literate document like this, but
@nl
@text some effort was made to produce a readable source file regardless of the
@nl
@text general principles of literate programming; other authors write warnings
@nl
@text into their tangled source files: ``Don't read this file! Read the Noweb
@nl
@text source only!''. I don't say that, especially for an Emacs application.
@nl
@text 
@nl
@text The sole interactive command---
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@endquote
@text ---loads the first element of
@nl
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@endquote
@text , considering it the default project.
@nl
@text 
@nl
@end docs 4
@begin code 5
@xref label NW4UAmWz-Q9qs2-1
@xref ref NW4UAmWz-Q9qs2-1
@defn Quotation custom-set-variables
@xref notused Quotation custom-set-variables
@nl
@text '(
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@nl
@text   '(("Noweb Hypertext System"
@nl
@text      "~/Desktop/
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text .nw"
@nl
@text      "make -C ~/Desktop --silent --file ~/src/
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text /Makefile tool-syntax"))
@nl
@text   nil
@nl
@text   (widget))
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index isdefined NW4UAmWz-4YCtgL-1
@index useitem whs-registered-projects
@index enduses
@end code 5
@begin docs 6
@text 
@nl
@text 
@nl
@end docs 6
@begin code 7
@xref label NW4UAmWz-2Oqtqm-1
@xref ref NW4UAmWz-2Oqtqm-1
@defn WHS
@xref beginuses
@xref useitem NW4UAmWz-4e7Hxw-1
@xref enduses
@nl
@xref ref NW4UAmWz-2Oqtqm-1
@index defn whs
@text (defun 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text  ()
@nl
@text   (interactive)
@nl
@text   (if-let ((
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-2
@index use whs-load-default-project?
@text -load-default-project?
@text )
@nl
@text            (default-project (cl-first 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@text ))
@nl
@text            (project (make-
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project :name (nth 0 default-project)
@nl
@text                                       :noweb (nth 1 default-project)
@nl
@text                                       :script (nth 2 default-project))))
@nl
@text       
@xref label NW4UAmWz-2Oqtqm-1-u1
@xref ref NW4UAmWz-4ajYIg-1
@use System Initialization
@nl
@text       
@xref label NW4UAmWz-2Oqtqm-1-u2
@xref ref NW4UAmWz-3ow68X-1
@use open Customize to register projects
@text ))
@nl
@nl
@index begindefs
@index isused NW4UAmWz-4YCtgL-1
@index isused NW4UAmWz-Q9qs2-1
@index isused NW4UAmWz-2Oqtqm-1
@index isused NW4UAmWz-4YCtgL-2
@index isused NW4UAmWz-3ow68X-1
@index isused NW4UAmWz-WGu1Q-1
@index isused NW4UAmWz-qqZnA-1
@index isused NW4UAmWz-3Kb5Dm-1
@index isused NW4UAmWz-ppSxp-1
@index isused NW4UAmWz-28WWma-1
@index isused NW4UAmWz-10UuOZ-1
@index isused NW4UAmWz-3uphDg-1
@index isused NW4UAmWz-3X3ATI-1
@index isused NW4UAmWz-4AI2uT-1
@index defitem whs
@index enddefs
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-2
@index useitem whs-load-default-project?
@index isdefined NW4UAmWz-4YCtgL-1
@index useitem whs-registered-projects
@index enduses
@end code 7
@begin docs 8
@text 
@nl
@text 
@nl
@text WHS is likely to be useful for very large literate programs, so the
@nl
@text command is designed to initialize from an existing project without
@nl
@text prompt. In more verbose terms: unless 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-2
@index use whs-load-default-project?
@text -load-default-project?
@endquote
@text  is
@nl
@text non-nil and 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@endquote
@text  includes at least one element,
@nl
@text Customize will be opened to customize the WHS group when 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@endquote
@text  is
@nl
@text invoked.
@nl
@text 
@nl
@end docs 8
@begin code 9
@xref label NW4UAmWz-4YCtgL-2
@xref ref NW4UAmWz-4YCtgL-1
@defn Customization and global variables
@xref prevdef NW4UAmWz-4YCtgL-1
@nl
@xref ref NW4UAmWz-4YCtgL-2
@index defn whs-load-default-project?
@text (defcustom 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-2
@index use whs-load-default-project?
@text -load-default-project?
@text  t
@nl
@text   "Non-nil values mean the system will load the default project.
@nl
@nl
@text nil will cause the interactive command `whs' to open Customize on
@nl
@text its group of variables."
@nl
@text   :type 'boolean
@nl
@text   :group 'whs
@nl
@text   :tag "Load default project when `whs' is invoked?")
@nl
@nl
@index begindefs
@index isused NW4UAmWz-2Oqtqm-1
@index isused NW4UAmWz-4YCtgL-2
@index isused NW4UAmWz-3ow68X-1
@index defitem whs-load-default-project?
@index enddefs
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 9
@begin code 10
@xref label NW4UAmWz-3ow68X-1
@xref ref NW4UAmWz-3ow68X-1
@defn open Customize to register projects
@xref beginuses
@xref useitem NW4UAmWz-2Oqtqm-1
@xref enduses
@nl
@text (message "No WHS projects registered, or `
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-2
@index use whs-load-default-project?
@text -load-default-project?
@text ' is nil. %s"
@nl
@text          (customize-group 'whs))
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index isdefined NW4UAmWz-4YCtgL-2
@index useitem whs-load-default-project?
@index enduses
@end code 10
@begin docs 11
@text 
@nl
@text 
@nl
@text When 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@endquote
@text  is invoked, an instance of the project struct is created,
@nl
@text and as
@nl
@text %% TODO:
@nl
@text a design goal is persisted using serialization after WHS exits.
@nl
@text 
@nl
@end docs 11
@begin code 12
@xref label NW4UAmWz-WGu1Q-1
@xref ref NW4UAmWz-WGu1Q-1
@defn WHS project structure
@xref beginuses
@xref useitem NW4UAmWz-4e7Hxw-1
@xref enduses
@nl
@text (cl-defstruct 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project
@nl
@text   "A WHS project"
@nl
@text   ;; Fundamental
@nl
@text   name
@nl
@text   noweb
@nl
@text   script
@nl
@text   database-file
@nl
@text   database-connection
@nl
@nl
@text   ;; Usage
@nl
@text   frame
@nl
@nl
@text   ;; Metadata
@nl
@text   (date-created (ts-now))
@nl
@text   date-last-edited
@nl
@text   date-last-exported
@nl
@nl
@text   ;; TODO: limit with a cutomization variable so that it does not grow too large.
@nl
@text   history-sql-commands)
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 12
@begin docs 13
@text 
@nl
@text 
@nl
@text Instances of this struct are only initialized with a few values:
@nl
@quote
@text name
@endquote
@text , 
@quote
@text noweb
@endquote
@text , and 
@quote
@text script
@endquote
@text . The rest of the fields
@nl
@text either have default values dependent upon the input data (like
@nl
@text the database-file, database-connection, and date-created), or are
@nl
@text given values when appropriate later in operation (such as
@nl
@quote
@text date-last-exported
@endquote
@text ) or upon initalization (
@quote
@text frame
@endquote
@text ).
@nl
@text 
@nl
@text Initialization when the interactive command is called is covered next;
@nl
@text to sumamrize: 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-load-hook
@endquote
@text  is run.
@nl
@text 
@nl
@text \section{System initialization from new projects}\label{Initialization}
@nl
@text To summarize this section, since it is longer than the previous
@nl
@text section, the object is the definition of 
@quote
@xref ref NW4UAmWz-4ajYIg-1
@use System Initialization
@endquote
@text ,
@nl
@text which is a chunk used in 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@endquote
@text .
@nl
@text 
@nl
@text In more explicit words, this section describes the actions that occur
@nl
@text when a user invokes 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@endquote
@text  interactively (with \textit{M-x}) and the
@nl
@text preconditions have been met; the 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@endquote
@text  function has already been
@nl
@text introduced, and only the ``meaty'' business end of its operation has
@nl
@text been left undefined until now. Ergo, 
@quote
@xref ref NW4UAmWz-4ajYIg-1
@use System Initialization
@endquote
@text 
@nl
@text gathers together the functionality that converts a Noweb to its tool
@nl
@text syntax with a project's specified shell script, sends the parsed text to
@nl
@text the database, and finally creates the IDE frame.
@nl
@text 
@nl
@end docs 13
@begin code 14
@xref label NW4UAmWz-4ajYIg-1
@xref ref NW4UAmWz-4ajYIg-1
@defn System Initialization
@xref beginuses
@xref useitem NW4UAmWz-2Oqtqm-1
@xref enduses
@nl
@text (let ((buffer (generate-new-buffer "WHS tool syntax generation shell output")))
@nl
@text   (with-current-buffer buffer
@nl
@text     
@xref label NW4UAmWz-4ajYIg-1-u1
@xref ref NW4UAmWz-qqZnA-1
@use run the project shell script to obtain the tool syntax
@nl
@nl
@text     ;; Go to the beginning of the buffer, then parse according to the PEG.
@nl
@text     (goto-char 0)
@nl
@text     
@xref label NW4UAmWz-4ajYIg-1-u2
@xref ref NW4UAmWz-3jfCTN-1
@use parse the buffer with PEG rules
@text ))
@nl
@end code 14
@begin docs 15
@text 
@nl
@text 
@nl
@text \subsection{Conversion to tool syntax}\label{toolconversion}
@nl
@text WHS could have been written to call the \texttt{noweave} programs
@nl
@text itself, but that is less configurable than providing the opportunity to
@nl
@text let the user configure this on their own. It respects Noweb's pipelines
@nl
@text architecture, and keeps things as transparent as possible. What is
@nl
@text needed to be Emacs Lisp is, and what is not isn't. The tool syntax is
@nl
@text thus obtained by running the shell script configured for the project by
@nl
@text calling it with the command-line provided in the third element of an
@nl
@text entry in 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@xref ref NW4UAmWz-4YCtgL-1
@index use whs-registered-projects
@text -registered-projects
@endquote
@text .
@nl
@text 
@nl
@end docs 15
@begin code 16
@xref label NW4UAmWz-qqZnA-1
@xref ref NW4UAmWz-qqZnA-1
@defn run the project shell script to obtain the tool syntax
@xref beginuses
@xref useitem NW4UAmWz-4ajYIg-1
@xref enduses
@nl
@text (make-process
@nl
@text  :name "
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -tool-generation"
@nl
@text  :buffer (get-buffer buffer)
@nl
@text  :command `("bash" ;; likely BASH on a GNU system, hoping for the `command-string' option.
@nl
@text            "-c"
@nl
@text            (,@(
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-script project)))
@nl
@text  :stderr (generate-new-buffer "WHS tool generation standard error stream")
@nl
@text  :sentinel (lambda (process event-string)
@nl
@text              (message "%S: %s" process event-string)))
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 16
@begin docs 17
@text 
@nl
@text 
@nl
@text The PEG for Noweb's tool syntax is run on the result of the shell
@nl
@text script, and this value consumed by the parent of this chunk.
@nl
@text 
@nl
@text \subsection{Database initialization}
@nl
@text Every project should have a database file located somewhere within the
@nl
@text user's Emacs directory; if the user is a Spacemacs user, then Spacemacs'
@nl
@text cache directory is used, otherwise the database is made in the user's
@nl
@text Emacs directory and not a subdirectory thereof.
@nl
@text 
@nl
@text The form used to create the absolute path for the location of the
@nl
@text database joins three things: the user's emacs directory, \texttt{nil} or
@nl
@text Spacemacs' cache directory, and the name of the project with ``.db''
@nl
@text appended. Note that concatenating \texttt{nil} with a string is the same
@nl
@text as returning the string unchanged.
@nl
@text 
@nl
@end docs 17
@begin code 18
@xref label NW4UAmWz-3Kb5Dm-1
@xref ref NW4UAmWz-3Kb5Dm-1
@defn return a filename for the project database
@xref beginuses
@xref useitem NW4UAmWz-ppSxp-1
@xref enduses
@nl
@text (file-name-concat
@nl
@text  ;; Usually ~/.emacs.d/
@nl
@text  user-emacs-directory
@nl
@text  ;; `nil' or the Spacemacs cache directory.
@nl
@text  (when (f-directory? (expand-file-name ".cache" user-emacs-directory))
@nl
@text    ".cache")
@nl
@text  ;; PROJECT-NAME.db
@nl
@text  (concat (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-name project)
@nl
@text          ".db"))
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 18
@begin docs 19
@text 
@nl
@text 
@nl
@text For \textsc{SQLite}, the pathname of the database to connect to or
@nl
@text create is sufficient to establish a connection, so the next step is to
@nl
@text connect to the database and store the connection object in the
@nl
@text appropriate slot of the project struct.
@nl
@text 
@nl
@end docs 19
@begin code 20
@xref label NW4UAmWz-ppSxp-1
@xref ref NW4UAmWz-ppSxp-1
@defn create the database
@xref notused create the database
@nl
@text (setf (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-database-connection project)
@nl
@text       (emacsql-sqlite
@nl
@text        (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-database-file 
@xref label NW4UAmWz-ppSxp-1-u1
@xref ref NW4UAmWz-3Kb5Dm-1
@use return a filename for the project database
@text )))
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 20
@begin docs 21
@text 
@nl
@text 
@nl
@text The only thing left to do is establish the schema of the tables, which
@nl
@text is done by mapping over several \textsc{EmacSQL} s-expressions.
@nl
@text 
@nl
@text %% To create an (SQLite) database from scratch for use with WHS, the schema
@nl
@text %% must be applied to the database using data definition language (DDL).
@nl
@text %% With the four tables created, data is provided to the database after the
@nl
@text %% parsing expression grammar (PEG) has finished its work on the tool
@nl
@text %% syntax produced by Noweave's \texttt{markup} program. The PEG and the
@nl
@text %% tool syntax are dealt with in \ref{PEG}.
@nl
@text 
@nl
@text %% TODO: ensure that this database is in 3NF and make a nice database
@nl
@text %% planning documents for it.
@nl
@end docs 21
@begin code 22
@xref label NW4UAmWz-28WWma-1
@xref ref NW4UAmWz-28WWma-1
@defn map over SQL s-expressions, creating the tables
@xref notused map over SQL s-expressions, creating the tables
@nl
@text (--map (emacsql (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-database-connection project) it)
@nl
@nl
@text       ;; A list of SQL s-expressions to create the tables.
@nl
@text       '([:create-table module
@nl
@text          ([module-name
@nl
@text            content
@nl
@text            file-name
@nl
@text            section-name
@nl
@text            (displacement integer)
@nl
@text            (module-number integer :primary-key)])]
@nl
@nl
@text         [:create-table parent-child
@nl
@text          ([(parent integer)
@nl
@text            (child  integer)
@nl
@text            (line-number integer)]
@nl
@text           (:primary-key [parent
@nl
@text                          child]))]
@nl
@nl
@text         [:create-table identifier-used-in-module
@nl
@text          ([identifier-name
@nl
@text            (module-number integer)
@nl
@text            (line-number integer)
@nl
@text            type-of-usage]
@nl
@text           (:primary-key [identifier-name
@nl
@text                          module-number
@nl
@text                          line-number
@nl
@text                          type-of-usage]))]
@nl
@nl
@text         [:create-table topic-referenced-in-module
@nl
@text          ([(topic-name nil)
@nl
@text            (module-number integer)]
@nl
@text           (:primary-key [topic-name
@nl
@text                          module-number]))]))
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 22
@begin docs 23
@text 
@nl
@text 
@nl
@text \subsection{Frame creation and atomic window specification}
@nl
@text A frame like in Figure \ref{fig1} should be created.
@nl
@text 
@nl
@text \begin{figure}
@nl
@text \begin{center}
@nl
@text \label{fig1}
@nl
@text \begin{BVerbatim}
@nl
@text +--------------+-----------------+-------+
@nl
@text | Module       | Module         ↑| Index |
@nl
@text | Code         |  documentation  |       |
@nl
@text |              |                 |       |
@nl
@text |              |  (prior or      |       |
@nl
@text |              |    posterior)   |       |
@nl
@text ????????????????                 |       |
@nl
@text ? AWK  Scripts ?                ↓|       |
@nl
@text ????????????????-----------------+       |
@nl
@text | Console                        |       |
@nl
@text +--------------------------------+-------+
@nl
@text \end{BVerbatim}
@nl
@text \end{center}
@nl
@text \caption{Simple drawing of WHS frame layout}
@nl
@text \end{figure}
@nl
@text 
@nl
@text 
@nl
@end docs 23
@begin code 24
@xref label NW4UAmWz-10UuOZ-1
@xref ref NW4UAmWz-10UuOZ-1
@defn Get project frame
@xref notused Get project frame
@nl
@text (progn
@nl
@text   (select-frame (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-frame project))
@nl
@text   (switch-to-buffer (generate-new-buffer (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-name project)) nil 'force-same-window)
@nl
@text   (let* ((window-right (split-window-right))
@nl
@text          (parent-window (window-parent window-right)))
@nl
@text     (window-make-atom parent-window)
@nl
@text     (display-buffer-in-atom-window
@nl
@text      (get-buffer-create (format "Module Index<%s>" (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-name project)))
@nl
@text      `((window . ,parent-window) (window-height . 8)))))
@nl
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 24
@begin docs 25
@text 
@nl
@text 
@nl
@text \section{System initialization from existing projects}
@nl
@text WHS loads a project by running the shell script stored in the third
@nl
@text element of the project list (which is pointed to by the script slot in
@nl
@text the struct).
@nl
@text 
@nl
@text \subsection{Initializing from an existing project}
@nl
@text With a default project available, WHS runs 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-load-hook
@endquote
@text 
@nl
@text with the struct of the default project let-bound as 
@quote
@text project
@endquote
@text . Much of
@nl
@text the functionality of WHS is implemented with the default hook, and
@nl
@text extensions to WHS should be implemented by editing the WHS Noweb source
@nl
@text and recompiling it, or extending the existing system with more hook
@nl
@text functions added to the aforementioned hook list variable.
@nl
@text 
@nl
@text If the project's database file is empty (zero-bytes) or does not exist
@nl
@text then the database is created from scratch. If the database already
@nl
@text exists, the first module is loaded and the database is not changed.
@nl
@text 
@nl
@end docs 25
@begin code 26
@xref label NW4UAmWz-3uphDg-1
@xref ref NW4UAmWz-3uphDg-1
@defn delete the database if it already exists, but only if it's an empty file
@xref notused delete the database if it already exists, but only if it's an empty file
@nl
@text ;; Unless the SQLite database's size is zero or it doesn't exist, move it to the user's trash directory.
@nl
@text (let ((
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --dbfile (
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -project-database-file project)))
@nl
@text   (unless (or (not (file-exists-p 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --dbfile))
@nl
@text               (= 0 (file-attribute-size (file-attributes 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --dbfile))))
@nl
@nl
@text     ;; TODO: Is there a better way to do this? `backup-buffer'?
@nl
@text     (copy-file 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --dbfile (concat 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --dbfile "~") t)
@nl
@nl
@text     ;; TODO: ensure that this AREA of code is reasonable before release.
@nl
@text     ;; It may have been written to ease development only.
@nl
@text     (let ((delete-by-moving-to-trash t))
@nl
@text       (delete-file 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text --dbfile t)))
@nl
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 26
@begin docs 27
@text 
@nl
@text 
@nl
@text \section{Loading Noweb source files}\label{Loading}
@nl
@text To parse a noweb source file, the file needs to be loaded into a temporary
@nl
@text buffer, then it can be parsed.
@nl
@text 
@nl
@text A simple usage of \textsc{Noweb} is given next, which shows that
@nl
@text \texttt{noweave} does not include the header keyword, nor
@nl
@text autodefinitions, usages, or indexing by default. Those are further
@nl
@text stages in the UNIX pipeline defined by the user with \texttt{noweave}
@nl
@text command-line program options and flags.
@nl
@text 
@nl
@text The WHS system parses the tool syntax emitted by \texttt{markup}, and
@nl
@text early development versions
@nl
@text %% TODO: set a version.
@nl
@text (prior to version \texttt{0.n-devel})
@nl
@text completely ignore Noweb keywords out of that scope.
@nl
@text 
@nl
@text An example of a \textsc{Noweb} command-line a user may call is given next.
@nl
@text 
@nl
@text \begin{quote}
@nl
@text \begin{verbatim}
@nl
@text [bryce@fedora whs]$ noweave -v -autodefs elisp -index whs.nw 1>/dev/null
@nl
@text RCS version name $Name:  $
@nl
@text RCS id $Id: noweave.nw,v 1.7 2008/10/06 01:03:24 nr Exp $
@nl
@text (echo @header latex
@nl
@text /usr/local/lib/markup whs.nw
@nl
@text echo @trailer latex
@nl
@text ) |
@nl
@text /usr/local/lib/autodefs.elisp |
@nl
@text /usr/local/lib/finduses |
@nl
@text /usr/local/lib/noidx |
@nl
@text /usr/local/lib/totex
@nl
@text \end{verbatim}
@nl
@text \end{quote}
@nl
@text 
@nl
@text Ergo, the simplified pipeline---using Emacs Lisp autodefinitions provided in
@nl
@text \textsc{Knoweb} (written by \textsc{Joseph S. Riel})---is as follows:
@nl
@text 
@nl
@text \begin{verbatim}
@nl
@text   markup whs.nw | autodefs.elisp | finduses | noidx
@nl
@text \end{verbatim}
@nl
@text 
@nl
@text %% TODO: rename and revise this section.
@nl
@text \subsubsection{In-development}
@nl
@text For an existing project (during development, that is WHS) to be loaded, it must
@nl
@text minimally be:
@nl
@text \begin{enumerate}
@nl
@text   \item Parsed, then stored in a database
@nl
@text   \item Navigable with WHS
@nl
@text     \begin{enumerate}
@nl
@text     \item Frame and Windows
@nl
@text     \item Navigation buttons... at least for modules
@nl
@text     \end{enumerate}
@nl
@text \end{enumerate}
@nl
@text 
@nl
@text This means diagramming the database schema, creating it in EmacSQL,
@nl
@text creating validating functions for existing databases, exceptions for
@nl
@text malformed databases, and documenting that in \LaTeX.
@nl
@text 
@nl
@text Navigation with WHS is multi-part:
@nl
@text \begin{enumerate}
@nl
@text \item Query the database for a list of modules, and
@nl
@text \item Create a buffer for the text content retrieved
@nl
@text \end{enumerate}
@nl
@text 
@nl
@text Exporting a project from the database and editing the project in an in-memory
@nl
@text state are further objectives, but they will be achived after the above two have
@nl
@text been implemented in a basic form.
@nl
@text 
@nl
@text \subsubsection{TODO}
@nl
@text The following features need to be implemented:
@nl
@text \begin{enumerate}
@nl
@text   \item Project export from database to Noweb format
@nl
@text   \item Editing of modules, documentation, and Awk code
@nl
@text   \item Navigation with indices
@nl
@text   \item Implement indices widgets
@nl
@text \end{enumerate}
@nl
@text 
@nl
@text \section{Parsing}
@nl
@text This section covers the parsing of the Noweb tool syntax produced by a
@nl
@text project shell script (described in §\ref{Projects}). The following
@nl
@text blocks of LISP code use the \textsc{peg} Emacs Lisp package to provide
@nl
@text for automatic parser generation from a formal PEG grammar based off of
@nl
@text the exhaustive description given in the Noweb Hacker's Guide.
@nl
@text 
@nl
@text %% \begin{center}
@nl
@text %%   Learning the PEG library was a challenge, and deriving a working set
@nl
@text %%   of PEXes---rules---for parsing the Noweb tool syntax was difficult.
@nl
@text %% \end{center}
@nl
@text 
@nl
@text %%% FIXME: the technobabble here is unhelpful.
@nl
@text Parsing the tool syntax allows for the generation of an
@nl
@text partially--directed graph, a digraph, of the network of chunks which
@nl
@text have hierarchical, self and non-self references, with their sequential
@nl
@text ordering and non-sequential orderings available for navigation (see
@nl
@text \href{https://www.isko.org/cyclo/hypertext#2.5}{\textsc{Intl. Soc.
@nl
@text     Knowledge Organization}} for futher information).
@nl
@text 
@nl
@text %% NOTE: to match the new line character in a text stream, the string
@nl
@text %% literal "\n" must be included. The (eol) PEG rule /tests/ for the end
@nl
@text %% of line by guarding the boolean return value of the standard Emacs
@nl
@text %% Lisp (eolp). To test if point is at the end of a line, use (eol), to
@nl
@text %% match the end of line, and permit parsing the next line of input,
@nl
@text %% include the string literal "\n".
@nl
@text \subsection{PEG rules}\label{rules}
@nl
@text Every character of an input text to be parsed by parsing expressions in
@nl
@text a PEG must be defined in terminal rules of the formal grammar. The root
@nl
@text rule in the grammar for Noweb tool syntax is the appropriately named
@nl
@quote
@text noweb
@endquote
@text  rule. Beginning 
@quote
@text with-peg-rules
@endquote
@text  brought into scope, the
@nl
@text root rule 
@quote
@text noweb
@endquote
@text  is ran on the buffer containing the tool syntax
@nl
@text produced by the project shell script.
@nl
@text 
@nl
@end docs 27
@begin code 28
@xref label NW4UAmWz-3jfCTN-1
@xref ref NW4UAmWz-3jfCTN-1
@defn parse the buffer with PEG rules
@xref beginuses
@xref useitem NW4UAmWz-4ajYIg-1
@xref enduses
@nl
@text ;;;; Parsing expression grammar (PEG) rules
@nl
@text (with-peg-rules
@nl
@text     (
@xref label NW4UAmWz-3jfCTN-1-u1
@xref ref NW4UAmWz-CjdUq-1
@use PEG rules
@text )
@nl
@text   (peg-run (peg noweb)
@nl
@text            (lambda (lst)
@nl
@text              (message "Parsing failed in buffer:=%S.\nPEXes which failed:=%S" buffer lst))))
@nl
@end code 28
@begin docs 29
@text 
@nl
@text 
@nl
@text The grammar can be broken into five sections, each covering some part of
@nl
@text parsing.
@nl
@text 
@nl
@end docs 29
@begin code 30
@xref label NW4UAmWz-CjdUq-1
@xref ref NW4UAmWz-CjdUq-1
@defn PEG rules
@xref beginuses
@xref useitem NW4UAmWz-3jfCTN-1
@xref enduses
@nl
@xref label NW4UAmWz-CjdUq-1-u1
@xref ref NW4UAmWz-21Y7vN-1
@use high-level Noweb tool syntax structure
@nl
@xref label NW4UAmWz-CjdUq-1-u2
@xref ref NW4UAmWz-3GxyZS-1
@use files and their paths
@nl
@xref label NW4UAmWz-CjdUq-1-u3
@xref ref NW4UAmWz-3LzQog-1
@use chunks and their boundaries
@nl
@xref label NW4UAmWz-CjdUq-1-u4
@xref ref NW4UAmWz-2tlT0H-1
@use keywords
@nl
@xref label NW4UAmWz-CjdUq-1-u5
@xref ref NW4UAmWz-PM7wo-1
@use meta rules
@nl
@end code 30
@begin docs 31
@text 
@nl
@text 
@nl
@text As stated, the 
@quote
@text noweb
@endquote
@text  rule defines the root expression, or starting
@nl
@text expression, for the grammar. The tool syntax of Noweb is simply a list
@nl
@text of one or more files, which are each composed of at least one chunk.
@nl
@text Ergo, the following 
@quote
@xref ref NW4UAmWz-21Y7vN-1
@use high-level Noweb tool syntax structure
@endquote
@text  is
@nl
@text defined.
@nl
@text 
@nl
@end docs 31
@begin code 32
@xref label NW4UAmWz-21Y7vN-1
@xref ref NW4UAmWz-21Y7vN-1
@defn high-level Noweb tool syntax structure
@xref beginuses
@xref useitem NW4UAmWz-CjdUq-1
@xref enduses
@nl
@text ;; Overall Noweb structure
@nl
@text (noweb (bob) (+ file) (if (eob))
@nl
@text        (action (message "End of buffer encountered while parsing.")))
@nl
@end code 32
@begin docs 33
@text 
@nl
@text 
@nl
@text The grammar needs to address the fact that the syntax of the Noweb tool
@nl
@text format is highly line-oriented, given the influence of AWK on the design
@nl
@text (and usage) of Noweb. The following 
@quote
@xref ref NW4UAmWz-PM7wo-1
@use meta rules
@endquote
@text  define rules
@nl
@text which organize the constructs of a line-oriented, or data-oriented,
@nl
@text syntax.
@nl
@text 
@nl
@end docs 33
@begin code 34
@xref label NW4UAmWz-PM7wo-1
@xref ref NW4UAmWz-PM7wo-1
@defn meta rules
@xref beginuses
@xref useitem NW4UAmWz-CjdUq-1
@xref enduses
@nl
@text ;; Helpers
@nl
@text (empty-line (bol) (eol) "\n")
@nl
@text (new-line (eol) "\n"
@nl
@text           (action (message "A new line was matched.")))
@nl
@text (not-eol (+ (not "\n") (any)))
@nl
@text (many-before-eol not-eol new-line)
@nl
@end code 34
@begin docs 35
@text 
@nl
@text 
@nl
@text With the 
@quote
@xref ref NW4UAmWz-PM7wo-1
@use meta rules
@endquote
@text  enabling easier definitions of what a given
@nl
@text ``keyword'' looks like, the concept of a file needs to be defined. A
@nl
@text file is anything that \textit{looks like a file} to Noweb, however, by
@nl
@text default only the 
@quote
@text <<*>>
@endquote
@text  chunk is tangled when no specific root chunk
@nl
@text is given on the command line.
@nl
@text 
@nl
@end docs 35
@begin code 36
@xref label NW4UAmWz-3GxyZS-1
@xref ref NW4UAmWz-3GxyZS-1
@defn files and their paths
@xref beginuses
@xref useitem NW4UAmWz-CjdUq-1
@xref enduses
@nl
@text (file (bol) "@file" [space] (substring path) new-line
@nl
@text       (list (+ chunk))
@nl
@text       `(path chunk-list -- (list path chunk-list)))
@nl
@nl
@text (path (opt (or ".." ".")) (* path-component) file-name)
@nl
@text (path-component (and path-separator (+ [word])))
@nl
@text (path-separator ["\\/"])
@nl
@text (file-name (+ (or [word] ".")))
@nl
@end code 36
@begin docs 37
@text 
@nl
@text 
@nl
@text \begin{center}
@nl
@text   Writing PEXes for matching file names was the most difficult part I have
@nl
@text   encountered so far, as it has forced me to understand that a first
@nl
@text   reading of documentation is usually not sufficient to understand a
@nl
@text   complex library in an area of programming I have not practiced in before
@nl
@text   (language parsing).
@nl
@text \end{center}
@nl
@text 
@nl
@text Because chunks must not overlap, but can nest, the beginnings of chunks
@nl
@text need to be pushed to the parsing stack and the end of a chunk needs to
@nl
@text be popped off of it. The stack pushing operations in 
@quote
@text kind
@endquote
@text  and
@nl
@quote
@text ordinal
@endquote
@text  delimit chunks by their kinds and number, and the stack
@nl
@text actions in the 
@quote
@text end
@endquote
@text  rule check that the chunk-releated tokens on the
@nl
@text stack are balanced.
@nl
@text 
@nl
@end docs 37
@begin code 38
@xref label NW4UAmWz-3LzQog-1
@xref ref NW4UAmWz-3LzQog-1
@defn chunks and their boundaries
@xref beginuses
@xref useitem NW4UAmWz-CjdUq-1
@xref enduses
@nl
@text (chunk begin (list (* keyword)) end)
@nl
@text (begin (bol) "@begin" [space] kind [space] ordinal (eol) "\n"
@nl
@text        (action (message "Chunk @begin matched.")))
@nl
@text (end (bol) "@end" [space] kind [space] ordinal (eol) "\n"
@nl
@text      (action (message "Chunk @end matched."))
@nl
@text      (opt (if begin)
@nl
@text           (action (message "[DEBUG] A begin [unconsumed] follows this end.")))
@nl
@text      `(kind-one ordinal-one keywords kind-two ordinal-two --
@nl
@text                 (if (and (= ordinal-one ordinal-two) (string= kind-one kind-two))
@nl
@text                              ;;; Push the contents of the chunk to the stack in a cons
@nl
@text                              ;;; cell with the car being a list of the kind and number.
@nl
@text                              ;;;; E.g.:
@nl
@text                     ;; (("code" 3) . (@text @nl @text @nl))
@nl
@text                     (cons (list kind-one ordinal-one) keywords)
@nl
@text                   (error "There was an issue with unbalanced or improperly nested chunks."))))
@nl
@text (ordinal (substring [0-9] (* [0-9]))
@nl
@text          `(number -- (string-to-number number)))
@nl
@text (kind (substring (or "code" "docs")))
@nl
@end code 38
@begin docs 39
@text 
@nl
@text 
@nl
@end docs 39
@begin code 40
@xref label NW4UAmWz-2tlT0H-1
@xref ref NW4UAmWz-2tlT0H-1
@defn keywords
@xref beginuses
@xref useitem NW4UAmWz-CjdUq-1
@xref enduses
@nl
@text (keyword
@nl
@text  (or
@nl
@text   ;; Keywords in the strict sense
@nl
@text   
@xref label NW4UAmWz-2tlT0H-1-u1
@xref ref NW4UAmWz-2ZphFz-1
@use structural keywords
@nl
@text   
@xref label NW4UAmWz-2tlT0H-1-u2
@xref ref NW4UAmWz-44iV1g-1
@use tagging keywords
@nl
@nl
@text   ;; Keywords in the same strict sense, but which cause failures.
@nl
@text   
@xref label NW4UAmWz-2tlT0H-1-u3
@xref ref NW4UAmWz-A87UR-1
@use usage errors
@nl
@text   
@xref label NW4UAmWz-2tlT0H-1-u4
@xref ref NW4UAmWz-1ZiKLq-1
@use tool errors
@text ))
@nl
@nl
@xref label NW4UAmWz-2tlT0H-1-u5
@xref ref NW4UAmWz-2PHWQZ-1
@use keyword definitions
@nl
@end code 40
@begin docs 41
@text 
@nl
@text 
@nl
@end docs 41
@begin code 42
@xref label NW4UAmWz-2ZphFz-1
@xref ref NW4UAmWz-2ZphFz-1
@defn structural keywords
@xref beginuses
@xref useitem NW4UAmWz-2tlT0H-1
@xref enduses
@nl
@text ;; structural
@nl
@text text
@nl
@text nl
@nl
@text defn
@nl
@text use ;; NOTE: related to the `identifier-used-in-module' table.
@nl
@text quotation
@nl
@end code 42
@begin docs 43
@text 
@nl
@text 
@nl
@end docs 43
@begin code 44
@xref label NW4UAmWz-44iV1g-1
@xref ref NW4UAmWz-44iV1g-1
@defn tagging keywords
@xref beginuses
@xref useitem NW4UAmWz-2tlT0H-1
@xref enduses
@nl
@text ;; tagging
@nl
@text line
@nl
@text language
@nl
@text index
@nl
@text xref
@nl
@end code 44
@begin docs 45
@text 
@nl
@text 
@nl
@end docs 45
@begin code 46
@xref label NW4UAmWz-A87UR-1
@xref ref NW4UAmWz-A87UR-1
@defn usage errors
@xref beginuses
@xref useitem NW4UAmWz-2tlT0H-1
@xref enduses
@nl
@text ;; user error
@nl
@text header
@nl
@text trailer
@nl
@end code 46
@begin docs 47
@text 
@nl
@text 
@nl
@end docs 47
@begin code 48
@xref label NW4UAmWz-1ZiKLq-1
@xref ref NW4UAmWz-1ZiKLq-1
@defn tool errors
@xref beginuses
@xref useitem NW4UAmWz-2tlT0H-1
@xref enduses
@nl
@text ;; error
@nl
@text fatal
@nl
@end code 48
@begin docs 49
@text 
@nl
@text 
@nl
@text The fundamental keywords are text and nl (new line). Text keywords
@nl
@text contain source text, and any new lines in the source text are removed
@nl
@text and replaced with the appropriate number of nl keywords.
@nl
@text 
@nl
@end docs 49
@begin code 50
@xref label NW4UAmWz-2PHWQZ-1
@xref ref NW4UAmWz-2PHWQZ-1
@defn keyword definitions
@xref nextdef NW4UAmWz-2PHWQZ-2
@xref begindefs
@xref defitem NW4UAmWz-2PHWQZ-2
@xref defitem NW4UAmWz-2PHWQZ-3
@xref defitem NW4UAmWz-2PHWQZ-4
@xref defitem NW4UAmWz-2PHWQZ-5
@xref enddefs
@xref beginuses
@xref useitem NW4UAmWz-2tlT0H-1
@xref enduses
@nl
@text (text (bol) "@text" [space] (substring (* (and (not "\n") (any)))) (eol) "\n")
@nl
@text (nl (bol) "@nl" (eol) "\n")
@nl
@end code 50
@begin docs 51
@text 
@nl
@text 
@nl
@text Nowebs are built from chunks, so the definition and usage of (references
@nl
@text to) a chunk are important keywords.
@nl
@text 
@nl
@end docs 51
@begin code 52
@xref label NW4UAmWz-2PHWQZ-2
@xref ref NW4UAmWz-2PHWQZ-1
@defn keyword definitions
@xref prevdef NW4UAmWz-2PHWQZ-1
@xref nextdef NW4UAmWz-2PHWQZ-3
@nl
@text (defn "@defn" [space] (substring not-eol) new-line
@nl
@text   `(cdefn -- (cons "Chunk definition" cdefn)))
@nl
@nl
@text (use (bol) "@use" [space] (action (message "\"@use \" matched"))
@nl
@text      (substring not-eol) new-line
@nl
@text      `(chunk-name -- (if chunk-name
@nl
@text                          (cons "Chunk usage (child)" chunk-name)
@nl
@text                        (error "UH-OH! There's a syntax error in the tool output!"))))
@nl
@end code 52
@begin docs 53
@text 
@nl
@text 
@nl
@end docs 53
@begin code 54
@xref label NW4UAmWz-2PHWQZ-3
@xref ref NW4UAmWz-2PHWQZ-1
@defn keyword definitions
@xref prevdef NW4UAmWz-2PHWQZ-2
@xref nextdef NW4UAmWz-2PHWQZ-4
@nl
@text (quotation beginquote (list (* keyword)) endquote)
@nl
@text (beginquote (bol) (substring "@quote") new-line)
@nl
@text (endquote (bol) (substring "@endquote") new-line
@nl
@text           `(bq kw eq -- (if (and (string= bq "@quote")
@nl
@text                                  (string= eq "@endquote"))
@nl
@text                             (cons "Quotation" kw)
@nl
@text                           (error "UH-OH! There's a parsing bug related to quotations."))))
@nl
@end code 54
@begin docs 55
@text 
@nl
@text 
@nl
@end docs 55
@begin code 56
@xref label NW4UAmWz-2PHWQZ-4
@xref ref NW4UAmWz-2PHWQZ-1
@defn keyword definitions
@xref prevdef NW4UAmWz-2PHWQZ-3
@xref nextdef NW4UAmWz-2PHWQZ-5
@nl
@text (line (bol) "@line" [space] (substring ordinal) new-line
@nl
@text       `(o -- (cons "@line" o)))
@nl
@nl
@text (language (bol) "@language" [space] (substring many-before-eol))
@nl
@end code 56
@begin docs 57
@text 
@nl
@text 
@nl
@text The indexing and cross-referencing abilities of Noweb are excellent
@nl
@text features which enable a reader to navigate through a printed (off-line)
@nl
@text or on-line version of the literate document quite nicely. These
@nl
@text functionalities each begin with a rule which matches only part of a line
@nl
@text of the tool syntax since there are many indexing and cross-referencing
@nl
@text keywords. The common part of each line is a rule which merely matches
@nl
@text the 
@quote
@text @index
@endquote
@text  or 
@quote
@text @xref
@endquote
@text  keyword. The rest of the lines are handled
@nl
@text by a list of rules in 
@quote
@text index-keyword
@endquote
@text  or 
@quote
@text xref-keyword
@endquote
@text .
@nl
@text 
@nl
@end docs 57
@begin code 58
@xref label NW4UAmWz-2PHWQZ-5
@xref ref NW4UAmWz-2PHWQZ-1
@defn keyword definitions
@xref prevdef NW4UAmWz-2PHWQZ-4
@nl
@text (index (bol) "@index" [space] (opt index-keyword)
@nl
@text        new-line)
@nl
@nl
@text ;; FIXME: why did I define it with optionally? Is there a possibility
@nl
@text ;; that @xref can be followed by a newline directly?
@nl
@text (xref (bol) "@xref" [space] (opt xref-keyword)
@nl
@text       new-line)
@nl
@nl
@text ;; indexing keywords
@nl
@text (index-keyword
@nl
@text  (or
@nl
@text   i-defn
@nl
@text   i-localdefn
@nl
@text   i-use
@nl
@text   i-nl
@nl
@nl
@text   i-definitions
@nl
@text   ;; i-begindefs
@nl
@text   ;; i-isused
@nl
@text   ;; i-defitem
@nl
@text   ;; i-enddefs
@nl
@nl
@text   ;; TODO: i-uses
@nl
@text   i-beginuses
@nl
@text   i-isdefined
@nl
@text   i-useitem
@nl
@text   i-enduses
@nl
@nl
@text   ;; TODO: i-index
@nl
@text   i-beginindex
@nl
@text   i-entrybegin
@nl
@text   i-entryuse
@nl
@text   i-entrydefn
@nl
@text   i-entryend
@nl
@text   i-endindex))
@nl
@nl
@text (i-defn (substring "defn" [space] not-eol))
@nl
@text (i-localdefn (substring "localdefn" [space] not-eol))
@nl
@text (i-use (substring "use" [space] not-eol))
@nl
@text (i-nl (substring "nl" [space] not-eol))
@nl
@nl
@text (i-definitions (substring i-begindefs)
@nl
@text                (list (* keyword))
@nl
@text                (substring i-enddefs))
@nl
@text (i-begindefs "begindefs")
@nl
@text (i-isused "isused" [space] (substring not-eol))
@nl
@text (i-defitem "defitem" [space] (substring not-eol))
@nl
@text (i-enddefs
@nl
@text  "enddefs"
@nl
@text  `(begin keywords end --
@nl
@text          (if (string= end "enddefs")
@nl
@text              (cons "definitions" keywords)
@nl
@text            (error
@nl
@text             "Overlapping (non-nested) i-definitions detected!\n%S\n%S\n%S"
@nl
@text             begin keywords end))))
@nl
@nl
@text (i-beginuses "beginuses")
@nl
@text (i-isdefined "isdefined" [space] (substring not-eol))
@nl
@text (i-useitem "useitem" [space] (substring not-eol))
@nl
@text (i-enduses "enduses")
@nl
@nl
@text (i-beginindex "beginindex")
@nl
@text (i-entrybegin "entrybegin"
@nl
@text               [space] (substring not-eol)
@nl
@text               [space] (substring not-eol)
@nl
@text               `(s1 s2 -- (list s1 s2)))
@nl
@text (i-entryuse "entryuse" [space] (substring not-eol))
@nl
@text (i-entrydefn "entrydefn" [space] (substring not-eol))
@nl
@text (i-endentry "entryend")
@nl
@text (i-endindex "endindex")
@nl
@nl
@text ;; cross-referencing keywords
@nl
@text (xref-keyword
@nl
@text  (or
@nl
@text   x-label
@nl
@text   x-ref
@nl
@nl
@text   x-begindefs
@nl
@text   x-prevdef
@nl
@text   x-nextdef
@nl
@text   x-defitem
@nl
@text   x-enddefs
@nl
@nl
@text   x-beginuses
@nl
@text   x-useitem
@nl
@text   x-enduses
@nl
@text   x-notused
@nl
@nl
@text   x-beginchunks
@nl
@text   x-chunkbegin
@nl
@text   x-chunkuse
@nl
@text   x-chunkdefn
@nl
@text   x-chunkend
@nl
@text   x-endchunks
@nl
@nl
@text   x-tag))
@nl
@nl
@text (x-label "label" [space] (substring not-eol))
@nl
@text (x-ref "ref" [space] (substring not-eol)
@nl
@text  `(reference -- (cons "XREF" reference)))
@nl
@nl
@text ;; TODO
@nl
@text (x-begindefs "begindefs") ;; FIXME: possibly borken
@nl
@text (x-prevdef "prevdef" [space] (substring not-eol))
@nl
@text (x-nextdef "nextdef" [space] (substring not-eol))
@nl
@text (x-defitem "defitem" [space] (substring not-eol))
@nl
@text (x-enddefs "enddefs") ;; FIXME: possibly borken
@nl
@nl
@text (x-beginuses "beginuses")
@nl
@text (x-useitem "useitem" [space] (substring not-eol))
@nl
@text (x-enduses "enduses")
@nl
@text (x-notused "notused" [space] (substring not-eol))
@nl
@nl
@text (x-beginchunks "beginindex")
@nl
@text (x-chunkbegin "chunkbegin" [space] (+ [word]) [space] not-eol)
@nl
@text (x-chunkuse "chunkuse" [space] (+ [word]))
@nl
@text (x-chunkdefn "chunkdefn" [space] (+ [word]))
@nl
@text (x-chunkend "chunkend")
@nl
@text (x-endchunks "endchunks")
@nl
@nl
@text ;; Associates label with tag (word with not-eol)
@nl
@text (x-tag "tag" [space] (+ [word]) [space] not-eol)
@nl
@nl
@text ;; User-errors (header and trailer) and tool-error (fatal)
@nl
@text (header (bol) "@header"
@nl
@text         (action (error "[ERROR] Do not use totex or tohtml in your noweave pipeline.")))
@nl
@text (trailer (bol) "@trailer"
@nl
@text          (action (error "[ERROR] Do not use totex or tohtml in your noweave pipeline.")))
@nl
@text (fatal (bol) "@fatal"
@nl
@text        (action (error "[FATAL] There was a fatal error in the pipeline. Stash the work area and submit a bug report against Noweb, WHS, and other relevant tools.")))
@nl
@end code 58
@begin docs 59
@text 
@nl
@text 
@nl
@text %%  NOTE: it would be helpful to construct this sort of parse tree at
@nl
@text %%  the CHUNK level, and this information can be directly sent to the
@nl
@text %%  database.
@nl
@text %% `((n . ,n)
@nl
@text %%   (name . ,substr)
@nl
@text %%   ;; Displacement: count of @nl encountered in this file so far.
@nl
@text %%   (offset . ,offset)
@nl
@text %%   (file . ,file)
@nl
@text %%   (section . ,section)) ;; Discover a single LaTeX sectioning command
@nl
@text %%                         ;; in the @text commands which are prior to
@nl
@text %%                         ;; this module's definition, as that is the
@nl
@text %%                         ;; direct parent section of this module.
@nl
@text %%  SQL attributes in the `module' table
@nl
@text %% module_number; module_name; displacement; file_name; section_name
@nl
@text 
@nl
@text %% The definition of a Noweb file, given by Ramsey, is simply a file
@nl
@text %% containing one or more chunks; minimally, a Noweb file will contain the
@nl
@text %% default documentation chunk.
@nl
@text 
@nl
@text \section{Packaging}
@nl
@text Installing an Emacs Lisp package is quite easy if the system is
@nl
@text distributed through the GNU Emacs Lisp Package Archive (GNU ELPA), and
@nl
@text only slightly less easy if it is distributed through MELPA
@nl
@text (Milkypostman's Emacs Lisp Package Archvie). Other package archives have
@nl
@text existed, but they are all ephemeral. The most popular alternative to GNU
@nl
@text ELPA, Non-GNU ELPA, and MELPA is direct distribution of files through
@nl
@text Git servers and the use of a package by the end user to install directly
@nl
@text from such.
@nl
@text 
@nl
@text This software is in-development, so it will only be distributed directly
@nl
@text through Git.
@nl
@text 
@nl
@text WHS follows the form of ``simple'', single-file packages documented in
@nl
@text the Emacs Lisp Reference Manual. The package file, \texttt{whs.el}, is
@nl
@text emitted by \texttt{notangle} which is called by the Makefile in every
@nl
@text target but 
@quote
@text clean
@endquote
@text . All source development occurs in \texttt{whs.nw}
@nl
@text using \textsc{Polymode}.
@nl
@text 
@nl
@text The makefile distributed alongside whs.nw in the tarball contains the
@nl
@text command-line used to tangle and weave WHS.
@nl
@text 
@nl
@end docs 59
@begin code 60
@xref label NW4UAmWz-1vZ6S2-1
@xref ref NW4UAmWz-1vZ6S2-1
@defn whs.el
@xref notused whs.el
@nl
@xref label NW4UAmWz-1vZ6S2-1-u1
@xref ref NW4UAmWz-3X3ATI-1
@use Emacs Lisp package headers
@nl
@xref label NW4UAmWz-1vZ6S2-1-u2
@xref ref NW4UAmWz-kWQI9-1
@use Licensing and copyright
@nl
@xref label NW4UAmWz-1vZ6S2-1-u3
@xref ref NW4UAmWz-3RJbFb-1
@use Commentary
@nl
@xref label NW4UAmWz-1vZ6S2-1-u4
@xref ref NW4UAmWz-4e7Hxw-1
@use Code
@nl
@xref label NW4UAmWz-1vZ6S2-1-u5
@xref ref NW4UAmWz-1G2S1M-1
@use EOF
@nl
@end code 60
@begin code 61
@xref label NW4UAmWz-3X3ATI-1
@xref ref NW4UAmWz-3X3ATI-1
@defn Emacs Lisp package headers
@xref beginuses
@xref useitem NW4UAmWz-1vZ6S2-1
@xref enduses
@nl
@text ;;; 
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text .el --- WEB Hypertext System -*- lexical-binding: t -*-
@nl
@nl
@text ;; Copyright © 2023 Bryce Carson
@nl
@nl
@text ;; Author: Bryce Carson <bcars268@mtroyal.ca>
@nl
@text ;; Created 2023-06-18
@nl
@text ;; Keywords: tools tex hypermedia
@nl
@text ;; URL: https://cyberscientist.ca/
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@nl
@nl
@text ;; This file is not part of GNU Emacs.
@nl
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 61
@begin docs 62
@text 
@nl
@text 
@nl
@end docs 62
@begin code 63
@xref label NW4UAmWz-4AI2uT-1
@xref ref NW4UAmWz-4AI2uT-1
@defn whs-pkg.el
@xref notused whs-pkg.el
@nl
@text (define-package "
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text " "0.1" "WEB Hypertext System"
@nl
@text   '(
@xref label NW4UAmWz-4AI2uT-1-u1
@xref ref NW4UAmWz-3jS1Ms-1
@use required packages
@text ))
@nl
@index beginuses
@index isdefined NW4UAmWz-4YCtgL-1
@index isdefined NW4UAmWz-2Oqtqm-1
@index useitem whs
@index enduses
@end code 63
@begin docs 64
@text 
@nl
@text 
@nl
@text The Emacs Lisp Manual states, regarding the \texttt{Package-Requires}
@nl
@text element of an Emacs Lisp package header:
@nl
@text 
@nl
@text \begin{quote}
@nl
@text   Its format is a list of lists on a single line.
@nl
@text \end{quote}
@nl
@text 
@nl
@text Thus, to prevent spill--over in the printed document, the
@nl
@quote
@xref ref NW4UAmWz-3jS1Ms-1
@use required packages
@endquote
@text  are given on separate lines in the literate
@nl
@text document. When the file is tangled, however, a Noweb filter will be used
@nl
@text to ensure that all required packages are on a single line by simply
@nl
@text removing the new lines from the following code chunk. The same principle
@nl
@text is followed for the 
@quote
@xref ref nw@notdef
@use file-local variables
@endquote
@text .
@nl
@text 
@nl
@end docs 64
@begin code 65
@xref label NW4UAmWz-3jS1Ms-1
@xref ref NW4UAmWz-3jS1Ms-1
@defn required packages
@xref beginuses
@xref useitem NW4UAmWz-4AI2uT-1
@xref enduses
@nl
@text (emacs "25.1")
@nl
@text (emacsql "20230220")
@nl
@text (dash "20230617")
@nl
@text (peg "1.0.1")
@nl
@text (cl-lib "1.0")
@nl
@text (ts "20220822")
@nl
@end code 65
@begin docs 66
@text 
@nl
@text 
@nl
@end docs 66
@begin code 67
@xref label NW4UAmWz-kWQI9-1
@xref ref NW4UAmWz-kWQI9-1
@defn Licensing and copyright
@xref beginuses
@xref useitem NW4UAmWz-1vZ6S2-1
@xref enduses
@nl
@text ;; This program is free software: you can redistribute it and/or
@nl
@text ;; modify it under the terms of the GNU General Public License as
@nl
@text ;; published by the Free Software Foundation, either version 3 of the
@nl
@text ;; License, or (at your option) any later version.
@nl
@nl
@text ;; This program is distributed in the hope that it will be useful, but
@nl
@text ;; WITHOUT ANY WARRANTY; without even the implied warranty of
@nl
@text ;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
@nl
@text ;; General Public License for more details.
@nl
@nl
@text ;; You should have received a copy of the GNU General Public License
@nl
@text ;; along with this program. If not, see
@nl
@text ;; <https://www.gnu.org/licenses/>.
@nl
@nl
@text ;; If you cannot contact the author by electronic mail at the address
@nl
@text ;; provided in the author field above, you may address mail to be
@nl
@text ;; delivered to
@nl
@nl
@text ;; Bryce Carson
@nl
@text ;; Research Assistant
@nl
@text ;; Dept. of Biology
@nl
@nl
@text ;; Mount Royal University
@nl
@text ;; 4825 Mount Royal Gate SW
@nl
@text ;; Calgary, Alberta, Canada
@nl
@text ;; T3E 6K6
@nl
@nl
@end code 67
@begin code 68
@xref label NW4UAmWz-3RJbFb-1
@xref ref NW4UAmWz-3RJbFb-1
@defn Commentary
@xref beginuses
@xref useitem NW4UAmWz-1vZ6S2-1
@xref enduses
@nl
@text ;;; Commentary:
@nl
@text ;; WHS was described by Brown and Czedjo in _A Hypertext for Literate
@nl
@text ;; Programming_ (1991).
@nl
@text ;;
@nl
@text ;; Brown, M., Czejdo, B. (1991). A hypertext for literate programming.
@nl
@text ;;    In: Akl, S.G., Fiala, F., Koczkodaj, W.W. (eds) Advances in
@nl
@text ;;    Computing and Information — ICCI '90. ICCI 1990. Lecture Notes in
@nl
@text ;;    Computer Science, vol 468. Springer, Berlin, Heidelberg.
@nl
@text ;;    https://doi-org.libproxy.mtroyal.ca/10.1007/3-540-53504-7_82.
@nl
@text ;;
@nl
@text ;; A paper describing this implementation---written in Noweb and browsable,
@nl
@text ;; editable, and auditable with WHS, or readable in the printed form---is
@nl
@text ;; hoped to be submitted to The Journal of Open Source Software (JOSS)
@nl
@text ;; before the year 2024. N.B.: the paper will include historical
@nl
@text ;; information about literate programming, and citations (especially
@nl
@text ;; of those given credit here for ideating WHS itself).
@nl
@nl
@end code 68
@begin code 69
@xref label NW4UAmWz-4e7Hxw-1
@xref ref NW4UAmWz-4e7Hxw-1
@defn Code
@xref beginuses
@xref useitem NW4UAmWz-1vZ6S2-1
@xref enduses
@nl
@text ;;; Code:
@nl
@text ;;;; Compiler directives
@nl
@text (eval-when-compile (require 'wid-edit))
@nl
@nl
@text ;;;; Internals
@nl
@xref label NW4UAmWz-4e7Hxw-1-u1
@xref ref NW4UAmWz-4YCtgL-1
@use Customization and global variables
@nl
@xref label NW4UAmWz-4e7Hxw-1-u2
@xref ref NW4UAmWz-2JNgIC-1
@use Widgets
@nl
@xref label NW4UAmWz-4e7Hxw-1-u3
@xref ref NW4UAmWz-WGu1Q-1
@use WHS project structure
@nl
@nl
@text ;;;; Commands
@nl
@text ;;;###autoload
@nl
@xref label NW4UAmWz-4e7Hxw-1-u4
@xref ref NW4UAmWz-2Oqtqm-1
@use WHS
@nl
@nl
@end code 69
@begin code 70
@xref label NW4UAmWz-1G2S1M-1
@xref ref NW4UAmWz-1G2S1M-1
@defn EOF
@xref beginuses
@xref useitem NW4UAmWz-1vZ6S2-1
@xref enduses
@nl
@text (provide 'whs)
@nl
@nl
@xref label NW4UAmWz-1G2S1M-1-u1
@xref ref NW4UAmWz-xvrml-1
@use file local variables
@nl
@end code 70
@begin docs 71
@text 
@nl
@text 
@nl
@end docs 71
@begin code 72
@xref label NW4UAmWz-xvrml-1
@xref ref NW4UAmWz-xvrml-1
@defn file local variables
@xref beginuses
@xref useitem NW4UAmWz-1G2S1M-1
@xref enduses
@nl
@text ;; Local Variables:
@nl
@text ;; mode: emacs-lisp
@nl
@text ;; no-byte-compile: t
@nl
@text ;; no-native-compile: t
@nl
@text ;; End:
@nl
@end code 72
@begin docs 73
@text 
@nl
@text 
@nl
@text \section{Indices}
@nl
@text \subsection{Chunks}
@nl
@text \nowebchunks
@nl
@text \subsection{Identifiers}
@nl
@text \nowebindex
@nl
@text 
@nl
@text \section{Appendices}
@nl
@text \subsection{A user-suggested functionality: \texttt{whs-with-project}}
@nl
@text \label{HistoryWithProject}
@nl
@text It was suggested during early development that
@nl
@quote
@xref ref NW4UAmWz-4bEmIT-1
@use API-like functions
@endquote
@text  such as 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -with-project
@endquote
@text  be written. An
@nl
@text early version of such functionality is provided in 
@quote
@xref ref NW4UAmWz-4YCtgL-1
@index use whs
@text whs
@text -with-project
@endquote
@text .
@nl
@text 
@nl
@end docs 73
@begin code 74
@xref label NW4UAmWz-4bEmIT-1
@xref ref NW4UAmWz-4bEmIT-1
@defn API-like functions
@xref notused API-like functions
@nl
@text ;; This chunk intentionally left blank at this time.
@nl
@end code 74
@nl
@nl
@xref beginchunks
@xref chunkbegin NW4UAmWz-4bEmIT-1 API-like functions
@xref chunkdefn NW4UAmWz-4bEmIT-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3LzQog-1 chunks and their boundaries
@xref chunkuse NW4UAmWz-CjdUq-1
@xref chunkdefn NW4UAmWz-3LzQog-1
@xref chunkend
@xref chunkbegin NW4UAmWz-4e7Hxw-1 Code
@xref chunkuse NW4UAmWz-1vZ6S2-1
@xref chunkdefn NW4UAmWz-4e7Hxw-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3RJbFb-1 Commentary
@xref chunkuse NW4UAmWz-1vZ6S2-1
@xref chunkdefn NW4UAmWz-3RJbFb-1
@xref chunkend
@xref chunkbegin NW4UAmWz-ppSxp-1 create the database
@xref chunkdefn NW4UAmWz-ppSxp-1
@xref chunkend
@xref chunkbegin NW4UAmWz-4YCtgL-1 Customization and global variables
@xref chunkdefn NW4UAmWz-4YCtgL-1
@xref chunkdefn NW4UAmWz-4YCtgL-2
@xref chunkuse NW4UAmWz-4e7Hxw-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3uphDg-1 delete the database if it already exists, but only if it's an empty file
@xref chunkdefn NW4UAmWz-3uphDg-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3X3ATI-1 Emacs Lisp package headers
@xref chunkuse NW4UAmWz-1vZ6S2-1
@xref chunkdefn NW4UAmWz-3X3ATI-1
@xref chunkend
@xref chunkbegin NW4UAmWz-1G2S1M-1 EOF
@xref chunkuse NW4UAmWz-1vZ6S2-1
@xref chunkdefn NW4UAmWz-1G2S1M-1
@xref chunkend
@xref chunkbegin NW4UAmWz-xvrml-1 file local variables
@xref chunkuse NW4UAmWz-1G2S1M-1
@xref chunkdefn NW4UAmWz-xvrml-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3GxyZS-1 files and their paths
@xref chunkuse NW4UAmWz-CjdUq-1
@xref chunkdefn NW4UAmWz-3GxyZS-1
@xref chunkend
@xref chunkbegin NW4UAmWz-10UuOZ-1 Get project frame
@xref chunkdefn NW4UAmWz-10UuOZ-1
@xref chunkend
@xref chunkbegin NW4UAmWz-21Y7vN-1 high-level Noweb tool syntax structure
@xref chunkuse NW4UAmWz-CjdUq-1
@xref chunkdefn NW4UAmWz-21Y7vN-1
@xref chunkend
@xref chunkbegin NW4UAmWz-2PHWQZ-1 keyword definitions
@xref chunkuse NW4UAmWz-2tlT0H-1
@xref chunkdefn NW4UAmWz-2PHWQZ-1
@xref chunkdefn NW4UAmWz-2PHWQZ-2
@xref chunkdefn NW4UAmWz-2PHWQZ-3
@xref chunkdefn NW4UAmWz-2PHWQZ-4
@xref chunkdefn NW4UAmWz-2PHWQZ-5
@xref chunkend
@xref chunkbegin NW4UAmWz-2tlT0H-1 keywords
@xref chunkuse NW4UAmWz-CjdUq-1
@xref chunkdefn NW4UAmWz-2tlT0H-1
@xref chunkend
@xref chunkbegin NW4UAmWz-kWQI9-1 Licensing and copyright
@xref chunkuse NW4UAmWz-1vZ6S2-1
@xref chunkdefn NW4UAmWz-kWQI9-1
@xref chunkend
@xref chunkbegin NW4UAmWz-28WWma-1 map over SQL s-expressions, creating the tables
@xref chunkdefn NW4UAmWz-28WWma-1
@xref chunkend
@xref chunkbegin NW4UAmWz-PM7wo-1 meta rules
@xref chunkuse NW4UAmWz-CjdUq-1
@xref chunkdefn NW4UAmWz-PM7wo-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3ow68X-1 open Customize to register projects
@xref chunkuse NW4UAmWz-2Oqtqm-1
@xref chunkdefn NW4UAmWz-3ow68X-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3jfCTN-1 parse the buffer with PEG rules
@xref chunkuse NW4UAmWz-4ajYIg-1
@xref chunkdefn NW4UAmWz-3jfCTN-1
@xref chunkend
@xref chunkbegin NW4UAmWz-CjdUq-1 PEG rules
@xref chunkuse NW4UAmWz-3jfCTN-1
@xref chunkdefn NW4UAmWz-CjdUq-1
@xref chunkend
@xref chunkbegin NW4UAmWz-Q9qs2-1 Quotation custom-set-variables
@xref chunkdefn NW4UAmWz-Q9qs2-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3jS1Ms-1 required packages
@xref chunkuse NW4UAmWz-4AI2uT-1
@xref chunkdefn NW4UAmWz-3jS1Ms-1
@xref chunkend
@xref chunkbegin NW4UAmWz-3Kb5Dm-1 return a filename for the project database
@xref chunkdefn NW4UAmWz-3Kb5Dm-1
@xref chunkuse NW4UAmWz-ppSxp-1
@xref chunkend
@xref chunkbegin NW4UAmWz-qqZnA-1 run the project shell script to obtain the tool syntax
@xref chunkuse NW4UAmWz-4ajYIg-1
@xref chunkdefn NW4UAmWz-qqZnA-1
@xref chunkend
@xref chunkbegin NW4UAmWz-2ZphFz-1 structural keywords
@xref chunkuse NW4UAmWz-2tlT0H-1
@xref chunkdefn NW4UAmWz-2ZphFz-1
@xref chunkend
@xref chunkbegin NW4UAmWz-4ajYIg-1 System Initialization
@xref chunkuse NW4UAmWz-2Oqtqm-1
@xref chunkdefn NW4UAmWz-4ajYIg-1
@xref chunkend
@xref chunkbegin NW4UAmWz-44iV1g-1 tagging keywords
@xref chunkuse NW4UAmWz-2tlT0H-1
@xref chunkdefn NW4UAmWz-44iV1g-1
@xref chunkend
@xref chunkbegin NW4UAmWz-1ZiKLq-1 tool errors
@xref chunkuse NW4UAmWz-2tlT0H-1
@xref chunkdefn NW4UAmWz-1ZiKLq-1
@xref chunkend
@xref chunkbegin NW4UAmWz-A87UR-1 usage errors
@xref chunkuse NW4UAmWz-2tlT0H-1
@xref chunkdefn NW4UAmWz-A87UR-1
@xref chunkend
@xref chunkbegin NW4UAmWz-2Oqtqm-1 WHS
@xref chunkdefn NW4UAmWz-2Oqtqm-1
@xref chunkuse NW4UAmWz-4e7Hxw-1
@xref chunkend
@xref chunkbegin NW4UAmWz-WGu1Q-1 WHS project structure
@xref chunkdefn NW4UAmWz-WGu1Q-1
@xref chunkuse NW4UAmWz-4e7Hxw-1
@xref chunkend
@xref chunkbegin NW4UAmWz-4AI2uT-1 whs-pkg.el
@xref chunkdefn NW4UAmWz-4AI2uT-1
@xref chunkend
@xref chunkbegin NW4UAmWz-1vZ6S2-1 whs.el
@xref chunkdefn NW4UAmWz-1vZ6S2-1
@xref chunkend
@xref chunkbegin NW4UAmWz-2JNgIC-1 Widgets
@xref chunkdefn NW4UAmWz-2JNgIC-1
@xref chunkuse NW4UAmWz-4e7Hxw-1
@xref chunkend
@xref endchunks
@index beginindex
@index entrybegin NW4UAmWz-4YCtgL-1 whs
@index entrydefn NW4UAmWz-4YCtgL-1
@index entryuse NW4UAmWz-Q9qs2-1
@index entrydefn NW4UAmWz-2Oqtqm-1
@index entryuse NW4UAmWz-4YCtgL-2
@index entryuse NW4UAmWz-3ow68X-1
@index entryuse NW4UAmWz-WGu1Q-1
@index entryuse NW4UAmWz-qqZnA-1
@index entryuse NW4UAmWz-3Kb5Dm-1
@index entryuse NW4UAmWz-ppSxp-1
@index entryuse NW4UAmWz-28WWma-1
@index entryuse NW4UAmWz-10UuOZ-1
@index entryuse NW4UAmWz-3uphDg-1
@index entryuse NW4UAmWz-3X3ATI-1
@index entryuse NW4UAmWz-4AI2uT-1
@index entryend
@index entrybegin NW4UAmWz-4YCtgL-2 whs-load-default-project?
@index entryuse NW4UAmWz-2Oqtqm-1
@index entrydefn NW4UAmWz-4YCtgL-2
@index entryuse NW4UAmWz-3ow68X-1
@index entryend
@index entrybegin NW4UAmWz-4YCtgL-1 whs-registered-projects
@index entrydefn NW4UAmWz-4YCtgL-1
@index entryuse NW4UAmWz-Q9qs2-1
@index entryuse NW4UAmWz-2Oqtqm-1
@index entryend
@index endindex
@begin docs 75
@text 
@nl
@text 
@nl
@text \end{document}
@nl
@end docs 75

(defun test-pex ()
  (with-peg-rules
      ;; Overall Noweb structure
      ((noweb (+ file))

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
