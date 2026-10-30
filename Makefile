SHELL=/bin/bash
VERSION      := 0.1
ROOT_DIR     := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD        ?= $(ROOT_DIR)build
SRC          ?= $(ROOT_DIR)src
TEST         ?= $(ROOT_DIR)test
PREFIX       ?= /usr
DESTDIR      ?=
# knoweb.sty is required during literate document compilation.
LATEX_STYLE_DEST ?= $(PREFIX)/share/texmf/tex/latex
# Debian; on Fedora the binaries are typically in /usr/bin and the filters in
# /usr/lib64/noweb.
NOWEB_BIN    ?= $(PREFIX)/bin
NOWEB_LIB ?= $(PREFIX)/local/noweb/lib
# markup     ?= $(NOWEB_LIB)/markup
# finduses   ?= $(NOWEB_LIB)/finduses
# noidx      ?= $(NOWEB_LIB)/noidx
AUTODEFS   ?= $(NOWEB_LIB)/autodefs.elisp
# clean_docs ?= $(SRC)/clean-docs.awk




$(BUILD)/%.el: | build
	notangle -R$(@F) $(SRC)/whyse.nw > $@

# Building the literate document for distribution requires installing the
# document compilation dependencies.
$(BUILD)/whyse.tex: install | build
	noweave -delay -autodefs elisp -index $(SRC)/whyse.nw > $@

# FIXME: on my Fedora Workstation, noweave complains about not finding
# autodefs.elisp, after `sudo make install`; autodefs.elisp is currently found
# in both /usr/local/noweb/lib and /usr/local/noweb/bin, but is not found in
# /usr/lib64/noweb, which doesn't exist.
.PHONY: document
document: $(BUILD)/peg-noweb.pdf
$(BUILD)/peg-noweb.pdf: $(BUILD)/whyse.tex | build
	cd $(BUILD) && latexmk -c --xelatex --interaction=nonstopmode -f $<

.PHONY: package
package: $(BUILD)/whyse-$(VERSION).tar
$(BUILD)/whyse-$(VERSION).tar: $(BUILD)/whyse.el $(BUILD)/peg-noweb.el
	mkdir -p $(basename $@)
	cp $^ $(basename $@)
	tar --create --file $@ -C $(BUILD) $(basename $(@F))

# Test the peg parser.
.PHONY: test
test: $(BUILD)/whyse.el $(BUILD)/peg-noweb.el
	emacs --quick --load=$(TEST)/test-loader.el

build:
	mkdir -p $(BUILD)/whyse-$(VERSION)

clobber:
	$(RM) --recursive --force $(BUILD)





# Install the LaTeX style file, the Emacs Lisp autodefs filter for noweave, and the Emacs package whyse.
install: $(BUILD)/whyse.el $(BUILD)/peg-noweb.el
	install -D -t $(DESTDIR)$(PREFIX)/share/emacs/site-lisp/whyse $^

# knoweb.sty and autodefs.elisp are already installed by their rules
	test -d $(LATEX_STYLE_DEST)
	install $(SRC)/knoweb.sty $(LATEX_STYLE_DEST)
# Refresh the TeX ls -R database
	-mktexlsr $(dir $(LATEX_STYLE_DEST)) 2>/dev/null || true

	chmod +x $(SRC)/autodefs.elisp
	test -d $(DESTDIR)$(NOWEB_LIB)
	install -D -t $(DESTDIR)$(NOWEB_LIB) $(SRC)/autodefs.elisp
