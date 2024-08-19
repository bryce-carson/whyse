# WHYSE ⸺ The WEB HYpertext System in Emacs
WHYSE is an integrated development environment for Noweb and $\LaTeX{}$,
integrating these tools with new system features for editing and reviewing
literate programs. The IDE is based off of the work by Brown and Czejdo from
199x, and is in early development.

# Development overview
To orient new contributors and help adventurous hackers use the software, this
overview is provided to help with navigation.

Firstly run `make compile-pdf`; Noweb 2.13 and $\LaTeX{}$ are required.

The files I have in my directory are as follows.

```
autodefs.elisp  offsets.awk  test.el    whyse-0.1.tar      whyse.log  whyse.tex
knoweb.sty      pextest.el   test.nw    whyse.aux          whyse.nw
LICENSE         pextest.nw   whyse.bib  whyse.fdb_latexmk  whyse.out
Makefile        README.md    whyse-0.1  whyse.fls          whyse.pdf
```

autodefs.elisp and knoweb.sty are taken from the knoweb project, which provides
LaTeX support for Noweb and Emacs Lisp identifier definitions in AWK for Noweb
to use for indexing.

The *project* license is contained in LICENSE. Particular files, if released
under a different license, contian separate licensing notices where appropriate
within the file; binary files do not contain license notices, and images, fonts,
sounds, movies, etc. are under their own license, if any works of these mediums
exist within the project at any time.

The Makefile has commands to `weave` Noweb to LaTeX source, `tangle` files from
Noweb sources, and `compile-pdf`s from generated $\LaTeX{}$ sources. It also
contains a command to generate Noweb intermediate tool syntax for developer
inspection.

whyse.bib contains a BibTeX reference for academic works. Of note, it contains a
reference to Brown & Czejdo's 1991 paper that inspired this package.

The only other source file is `whyse.nw`, the Noweb source for WHYSE itself.

# LaTeX compilation difficulties
Carson has not had success compiling a knoweb styled LaTeX document outside of a
Debian 11 environment with TeXLive 2020. Only this combination works; other
versions of TexLive or newer versions of Debian, or other Linux distributions
have not worked with the peculiarities of the style file and the latex
environment. Therefore an operating system image (in ISO format) may be made
available for development purposes.

Due the difficulties time was taken to revert the project to using the standard
noweb macro package. It compiles best with $\XeTeX{}$. With $\LuaTeX{}$ there
are compilation issues for some reason (I am not a $\LaTeX{}$
macro-understander, so I can't debug the issues).
