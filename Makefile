VERSION      := 0.1
ROOT_DIR     := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# Default build directory is a sibling of src/ at the top of the tree.
# Override on the command line or in the environment if desired:
#   make BUILD=/tmp/whyse-build
#   make BUILDDIR=/tmp/whyse-build   (alias)
BUILD        ?= $(ROOT_DIR)build
BUILDDIR     ?= $(BUILD)          # convenience alias
SRC          ?= $(ROOT_DIR)src
TEST         ?= $(ROOT_DIR)test
PREFIX       ?= /usr
DESTDIR      ?=

# noweb locations---also overridable
# On Fedora the binaries are typically in /usr/bin and the filters in /usr/lib64/noweb
NOWEB_LIB    ?= $(PREFIX)/lib64/noweb
NOWEB_BIN    ?= $(PREFIX)/bin

# derived tool paths (filters live in NOWEB_LIB)
markup           ?= $(NOWEB_LIB)/markup
finduses         ?= $(NOWEB_LIB)/finduses
noidx            ?= $(NOWEB_LIB)/noidx
autodefs_elisp   ?= $(NOWEB_LIB)/autodefs.elisp
clean_docs       ?= $(SRC)/clean-docs.awk

# optional style-file destination (used by the Dockerfile / packaging)
KNOWEB_STYLE_DEST ?= $(PREFIX)/share/texmf/tex/latex

log = $(BUILD)/whyse.log




.PHONY: tar doc
tar: $(BUILD)/whyse-$(VERSION).tar doc
doc: $(BUILD)/whyse.pdf


$(BUILD)/whyse-$(VERSION).tar : $(BUILD)/whyse-$(VERSION)/whyse.el | builddir
	tar cf $@ -C $(BUILD) whyse-$(VERSION)
$(BUILD)/whyse-$(VERSION)/whyse.el: $(SRC)/whyse.nw | builddir
	$(NOWEB_BIN)/notangle -R\\$(notdir $@) $^ > $@

# Rebuild the dependency.
PEG_NOWEB ?= ../peg-noweb
peg-noweb-*.tar: $(PEG_NOWEB)/Makefile
	make -C $(dir $^) -f $^





$(BUILD)/whyse.tex: $(SRC)/autodefs.elisp $(SRC)/whyse.nw | builddir
	$(NOWEB_BIN)/noweave -v -delay -filter $< -index $(SRC)/whyse.nw > $@
$(BUILD)/whyse.pdf: $(BUILD)/whyse.tex | $(SRC)/knoweb.sty $(SRC)/ieee.csl $(SRC)/gpl-3.0.tex
	cp $| --target-directory $(BUILD)
	cd $(BUILD) && latexmk --xelatex --interaction=nonstopmode $< > $@





.PHONY: builddir clean tool-syntax install

builddir:
	mkdir -p $(BUILD)/whyse-$(VERSION)

clean:
	$(RM) -rf $(BUILD)
# optional Emacs cache (ignore if absent)
	-$(RM) ~/.config/emacs/.cache/whyse.db 2>/dev/null || true

# Development pipeline for peg-noweb (can be removed later)
tool-syntax: $(SRC)/autodefs.elisp
	$(markup) $(SRC)/whyse.nw \
		| $(SRC)/autodefs.elisp \
		| $(finduses) \
		| $(clean_docs) \
		| $(noidx) -delay





# Minimal install target---places the generated Elisp and style file
install: whyse.el knoweb.sty autodefs.elisp
	mkdir -p $(DESTDIR)$(PREFIX)/share/emacs/site-lisp
	cp -t $(DESTDIR)$(PREFIX)/share/emacs/site-lisp $(BUILD)/whyse.el
# knoweb.sty and autodefs.elisp are already installed by their rules
	$(install) $(SRC)/knoweb.sty $(dir $@)
# Refresh the TeX ls -R database
	-mktexlsr $(dir $(KNOWEB_STYLE_DEST)) 2>/dev/null || true
	mkdir -p $(DESTDIR)$(NOWEB_LIB)
	cp -t $(DESTDIR)$(NOWEB_LIB) $(BUILD)/autodefs.elisp
	chmod +x $(DESTDIR)$(NOWEB_LIB)/autodefs.elisp

### PEG NOWEB
SHELL=/bin/bash

VERSION := 0.2
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD ?= ${ROOT_DIR}build
SRC ?= ${ROOT_DIR}src
TEST ?= ${ROOT_DIR}test

# Allow NOWEB_LIB to be overridden (e.g., via command line or Docker)
NOWEB_LIB ?= /usr/local/noweb/lib
markup ?= ${NOWEB_LIB}/markup
finduses ?= ${NOWEB_LIB}/finduses
noidx ?= ${NOWEB_LIB}/noidx
autodefs_elisp ?= ${NOWEB_LIB}/autodefs.elisp

tangle: clean
	mkdir -p $(BUILD)
	notangle -Rpeg-noweb.el $(SRC)/peg-noweb.nw > $(BUILD)/peg-noweb.el
	mkdir -p $(BUILD)/peg-noweb-$(VERSION)
	mv -t $(BUILD)/peg-noweb-$(VERSION) $(BUILD)/peg-noweb.el
	cp -t $(BUILD)/peg-noweb-$(VERSION) LICENSE
	tar --create --file $(BUILD)/peg-noweb-$(VERSION).tar -C $(BUILD) peg-noweb-$(VERSION)
	tar --list --file $(BUILD)/peg-noweb-$(VERSION).tar

## TODO: makem.sh is suposed to be easier than what I'm doing... read the documentation carefully!
test-interactive: tangle
	emacs --quick --eval="(setq build-directory \"$(BUILD)/peg-noweb-$(VERSION)\" test-directory \"$(TEST)\")" --load=$(TEST)/test-loader.el

weave:
	mkdir -p $(BUILD)
	# noweave -delay -autodefs elisp -index $(SRC)/peg-noweb.nw > $(BUILD)/peg-noweb.tex
	noweave -delay $(SRC)/peg-noweb.nw > $(BUILD)/peg-noweb.tex
	cd $(BUILD) && latexmk --xelatex --interaction=nonstopmode -f peg-noweb.tex

clean:
	$(RM) --recursive --force $(BUILD)
