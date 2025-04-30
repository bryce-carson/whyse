# WHYSE ⸺ The WEB HYpertext System in Emacs
WHYSE is an integrated development environment for Noweb and $\LaTeX{}$,
integrating these tools with new system features for editing and reviewing
literate programs. The IDE is based off of an academic paper from nineteen
ninety-one by Brown and Czejdo (subject /Hypertext/).

References are listed here:

- Brown, M. and Bogdan D. Czejdo. "A Hypertext for Literate Programming." International Conference on Computing and Information [1991].

# Development overview
To orient new contributors and help adventurous hackers use the software, this
overview is provided to help with navigation.

Firstly, Noweb 2.13 and $\LaTeX{}$ are required for development. Run `make
compile-pdf` to compile and render the PDF on your system.

The files I have in my directory are as follows.

```
autodefs.elisp  offsets.awk  test.el    whyse-0.1.tar      whyse.log  whyse.tex
knoweb.sty      pextest.el   test.nw    whyse.aux          whyse.nw
LICENSE         pextest.nw   whyse.bib  whyse.fdb_latexmk  whyse.out
Makefile        README.md    whyse-0.1  whyse.fls          whyse.pdf
```

`autodefs.elisp` and `knoweb.sty` are taken from the knoweb project, which provides
LaTeX support for Noweb and Emacs Lisp identifier definitions in AWK for Noweb
to use for indexing. Upstream knoweb is not required.

The *project* license is contained in `LICENSE`. Particular files, if released
under a different license, contian separate licensing notices where appropriate
within the file; binary files do not contain license notices, and images, fonts,
sounds, movies, etc. are under their own license, if any works of these mediums
exist within the project at any time.

The Makefile has commands to `weave` Noweb to LaTeX source, `tangle` files from
Noweb sources, and `compile-pdf`s from generated $\LaTeX{}$ sources. It also
contains a command to generate Noweb intermediate tool syntax for developer
inspection.

`whyse.bib` contains a BibTeX reference for academic works. Of note, it contains
a reference to Brown & Czejdo's 1991 paper that inspired this package.

The only other source file is `whyse.nw`, the Noweb source for WHYSE itself.

## LaTeX compilation difficulties
I have not had success compiling a knoweb styled LaTeX document outside of a
Debian 11 environment with TeXLive 2020. Only this combination works; other
versions of TexLive or newer versions of Debian, or other Linux distributions
have not worked with the peculiarities of the style file and the latex
environment. Therefore an operating system image (in ISO format) or a Docker
container may be made available for development purposes; don't count on it.
Consider using `docker pull texlive/texlive:TL2020-historic`.

Due to the these difficulties some time was taken to revert the project to using
the standard noweb macro package. It compiles best with $\XeTeX{}$. With
$\LuaTeX{}$ there are compilation issues for some reason (I am not a $\LaTeX{}$
macro-understander, so I can't debug the issues).

# Returning to development after a long hiatus
One of the hallmarks of literate programming is the supposed speed with which a
developer can acquaint (or re-acquaint) themselves with a codebase. The
suppository is that you're directly inputting the source code whilst reading
copius documentation explaining the reasoning for that code and the way it fits
together with other parts while you're construting your own mental model (while
you are reading critically, because all software and documentation has errors
and omissions).

I'm returning to the project on April 19th, 2025 (Sat 19 Apr 2025 12:34:49 AM
MDT). I am not sure how long I have been away; after checking the git log it
appears I've been largely inactive since May 13th, 2024. That's nearly one year!
