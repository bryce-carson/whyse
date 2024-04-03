# WHYSE ⸺ The WEB HYpertext System in Emacs
WHYSE is an integrated development environment for Noweb and $\LaTeX{}$,
integrating these tools with new system features for editing and reviewing
literate programs. The IDE is based off of the work by Brown and Czejdo from
199x, and is in early development.

# Development overview
To orient new contributors and help adventurous hackers use the software, this
overview is provided to help with navigation.

```
autodefs.elisp  offsets.awk  test.el    whyse-0.1.tar      whyse.log  whyse.tex
knoweb.sty      pextest.el   test.nw    whyse.aux          whyse.nw
LICENSE         pextest.nw   whs.bib    whyse.fdb_latexmk  whyse.out
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
Noweb sources, and `compile-pdf`s from generated LaTeX sources. It also contains
a command to generate Noweb intermediate tool syntax for developer inspection.

pextest.nw and pextest.el are used to test the PEG used for Noweb tool syntax by
wrapping the entire grammar into a single PEX and executing the form in a buffer
with Emacs Lisp Interaction Mode enabled, resulting in a very fast-paced testing
method for tricky parts of the grammar.

whs.bib contains a BibTeX reference for academic works. It contains a reference
to Brown & Czejdo's work, notably.

The only other source file is `whyse.nw`, the Noweb source for WHYSE itself.

Other files are ephemeral development files and shouldn't concern developers, as
these are generated while compiling documents or are unimportant and won't be
committed to the repository. Unimportant files merely existed whilst the
directory listing was printed when writing this section of the readme document.

# LaTeX compilation difficulties
Carson has not had success compiling a knoweb styled LaTeX document outside of a
Debian 11 environment with TeXLive 2020. Only this combination works; other
versions of TexLive or newer versions of Debian, or other Linux distributions
have not worked with the peculiarities of the style file and the latex
environment. Therefore an operating system image (in ISO format) may be made
available for development purposes.
