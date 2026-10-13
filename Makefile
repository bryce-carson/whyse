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

# ------------------------------------------------------------------
# Packaging
# ------------------------------------------------------------------
# TODO: should LICENSE be included? Doubtful... README.md shouldn't be included,
# in my taste.
pkg ?= $(BUILD)/whyse-$(VERSION)
$(pkg).tar: $(pkg)/whyse.el $(pkg)/whyse-pkg.el | builddir
	tar cf $@ -C $(BUILD) $(notdir $(basename $@))

# ------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------
whyse.tex: autodefs.elisp | builddir
	cd $(BUILD) && $(NOWEB_BIN)/noweave -delay -autodefs elisp -index $(SRC)/whyse.nw > $@

whyse.pdf: whyse.tex knoweb.sty
	cd $(BUILD) && latexmk --xelatex --interaction=nonstopmode $<

# ------------------------------------------------------------------
# Source extraction
# ------------------------------------------------------------------
$(pkg)/%.el: | builddir
	-mkdir -p $(pkg)
	$(NOWEB_BIN)/notangle -R$(notdir $@) $(SRC)/whyse.nw > $@

# ------------------------------------------------------------------
# knoweb support (style file + autodefs filter)
# Everything related to knoweb lives under $(BUILD)
# ------------------------------------------------------------------

$(KNOWEB_STYLE_DEST)/knoweb.sty: $(BUILD)/knoweb/knoweb.stamp
	$(install) $(SRC)/knoweb.sty $(dir $@)
# Refresh the TeX ls -R database
	-mktexlsr $(dir $(KNOWEB_STYLE_DEST)) 2>/dev/null || true

autodefs.elisp:
	mkdir -p $(DESTDIR)$(NOWEB_LIB)
	cp -t $(DESTDIR)$(NOWEB_LIB) $(BUILD)/autodefs.elisp
	chmod +x $(DESTDIR)$(NOWEB_LIB)/autodefs.elisp

# ------------------------------------------------------------------
# Docker-related targets (kept for completeness)
# ------------------------------------------------------------------
Dockerfile: dockerfile.org
	emacs -Q --batch --eval "(progn (require 'ob-tangle) (with-current-buffer (find-file-noselect $<) (org-babel-tangle)))"

# ------------------------------------------------------------------
# Utility / development targets
# ------------------------------------------------------------------
.PHONY: builddir clean tool-syntax install

builddir:
	mkdir -p $(BUILD)

clean:
	$(RM) -f $(BUILD)/*~ \
		$(BUILD)/*.aux $(BUILD)/*.bbl $(BUILD)/*.bcf $(BUILD)/*.blg \
		$(BUILD)/*.brf $(BUILD)/*.dvi $(BUILD)/*.fdb_latexmk \
		$(BUILD)/*.fls $(BUILD)/*.idx $(BUILD)/*.lof $(BUILD)/*.out \
		$(BUILD)/*.pdf $(BUILD)/*.run.xml $(BUILD)/*.toc \
		$(BUILD)/*.xdy $(BUILD)/*.xdv
	$(RM) -rf $(BUILD)/whyse-*/ $(BUILD)/knoweb $(BUILD)/knoweb.stamp
	$(RM) -f $(BUILD)/whyse-*.tar $(BUILD)/autodefs.elisp
# optional Emacs cache (ignore if absent)
	-$(RM) ~/.config/emacs/.cache/whyse.db 2>/dev/null || true

# Development pipeline for peg-noweb (can be removed later)
tool-syntax: autodefs.elisp
	$(markup) $(SRC)/whyse.nw \
		| $(autodefs_elisp) \
		| $(finduses) \
		| $(clean_docs) \
		| $(noidx) -delay

# Minimal install target---places the generated Elisp and style file
install: whyse.el knoweb.sty autodefs.elisp
	mkdir -p $(DESTDIR)$(PREFIX)/share/emacs/site-lisp
	cp -t $(DESTDIR)$(PREFIX)/share/emacs/site-lisp $(BUILD)/whyse.el
# knoweb.sty and autodefs.elisp are already installed by their rules
