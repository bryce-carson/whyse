VERSION = 0.1

weave: clean
	noweave -delay -autodefs elisp -index whyse.nw > whyse.tex

compile-pdf: tangle weave
	latexmk --xelatex --interaction=nonstopmode -f whyse.tex
	xelatex -f whyse.tex

tangle: clean
	notangle -Rwhyse.el whyse.nw > whyse.el
	notangle -Rwhyse-pkg.el whyse.nw > whyse-pkg.el
	mkdir whyse-${VERSION}
	mv -t whyse-${VERSION} whyse.el whyse-pkg.el
	cp -t whyse-${VERSION} LICENSE
	tar --create --file whyse-${VERSION}.tar whyse-${VERSION}
	tar --list --file whyse-${VERSION}.tar

test: clean tangle
	notangle -Rtest-parser-with-temporary-buffer.el whyse.nw > test-parser-with-temporary-buffer.el

# Remove backup files and LaTeX garbage and cache files.
clean:
	$(RM) ~/.config/emacs/.cache/whyse.db
	$(RM) *~ *.aux *.bbl *.bcf *.blg *.brf *.dvi *.fdb_latexmk *.fls *.idx *.lof *.log *.out *.pdf *.run.xml whyse.tex *.toc *.xdy
	$(RM) -rf whyse-*/

tool-syntax:
	/usr/local/lib/markup ~/src/whyse/whyse.nw | \
  /usr/local/lib/autodefs.elisp | \
  /usr/local/lib/finduses | \
  ~/src/whyse/clean-docs.awk | \
  /usr/local/lib/noidx -delay

# * makem.sh/Makefile --- Script to aid building and testing Emacs Lisp packages

# URL: https://github.com/alphapapa/makem.sh
# Version: 0.5

# * Arguments

# For consistency, we use only var=val options, not hyphen-prefixed options.

# NOTE: I don't like duplicating the arguments here and in makem.sh,
# but I haven't been able to find a way to pass arguments which
# conflict with Make's own arguments through Make to the script.
# Using -- doesn't seem to do it.

ifdef install-deps
	INSTALL_DEPS = "--install-deps"
endif
ifdef install-linters
	INSTALL_LINTERS = "--install-linters"
endif

ifdef sandbox
	ifeq ($(sandbox), t)
		SANDBOX = --sandbox
	else
		SANDBOX = --sandbox=$(sandbox)
	endif
endif

ifdef debug
	DEBUG = "--debug"
endif

# ** Verbosity

# Since the "-v" in "make -v" gets intercepted by Make itself, we have
# to use a variable.

verbose = $(v)

ifneq (,$(findstring vvv,$(verbose)))
	VERBOSE = "-vvv"
else ifneq (,$(findstring vv,$(verbose)))
	VERBOSE = "-vv"
else ifneq (,$(findstring v,$(verbose)))
	VERBOSE = "-v"
endif

# * Rules

# TODO: Handle cases in which "test" or "tests" are called and a
# directory by that name exists, which can confuse Make.

%:
	@./makem.sh $(DEBUG) $(VERBOSE) $(SANDBOX) $(INSTALL_DEPS) $(INSTALL_LINTERS) $(@)

.DEFAULT: init
init:
	@./makem.sh $(DEBUG) $(VERBOSE) $(SANDBOX) $(INSTALL_DEPS) $(INSTALL_LINTERS)
