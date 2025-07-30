VERSION := 0.1
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD ?= ${ROOT_DIR}build
SRC ?= ${ROOT_DIR}src
TEST ?= ${ROOT_DIR}test

# Allow NOWEB_LIB to be overridden (e.g., via command line or Docker)
NOWEB_LIB ?= /usr/lib64/noweb

markup ?= ${NOWEB_LIB}/markup
finduses ?= ${NOWEB_LIB}/finduses
noidx ?= ${NOWEB_LIB}/noidx
autodefs_elisp ?= ${NOWEB_LIB}/autodefs.elisp
clean_docs ?= ${SRC}/clean-docs.awk

readme:
	emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "TODO.org")'

weave: clean
	mkdir -p $(BUILD)
	noweave -delay -autodefs elisp -index $(SRC)/whyse.nw > $(BUILD)/whyse.tex

compile-pdf: tangle weave
	latexmk -cd --xelatex --interaction=nonstopmode -diagnostics $(BUILD)/whyse.tex \
	&& xelatex --output-directory $(BUILD) $(BUILD)/whyse.tex \
	|| cat whyse.log
pdf: compile-pdf

tangle: clean
	mkdir -p $(BUILD)
	notangle -Rwhyse.el $(SRC)/whyse.nw > $(BUILD)/whyse.el
	notangle -Rwhyse-pkg.el $(SRC)/whyse.nw > $(BUILD)/whyse-pkg.el
	mkdir -p $(BUILD)/whyse-$(VERSION)
	mv -t $(BUILD)/whyse-$(VERSION) $(BUILD)/whyse.el $(BUILD)/whyse-pkg.el
	cp -t $(BUILD)/whyse-$(VERSION) LICENSE
	tar --create --file $(BUILD)/whyse-$(VERSION).tar -C $(BUILD) whyse-$(VERSION)
	tar --list --file $(BUILD)/whyse-$(VERSION).tar

test: clean tangle
	mkdir -p $(TEST)
	notangle -Rtest-parser-with-temporary-buffer.el $(SRC)/whyse.nw > $(TEST)/test-parser-with-temporary-buffer.el

clean:
	$(RM) ~/.config/emacs/.cache/whyse.db
	$(RM) -f $(BUILD)/*~ $(BUILD)/*.aux $(BUILD)/*.bbl $(BUILD)/*.bcf $(BUILD)/*.blg $(BUILD)/*.brf \
		$(BUILD)/*.dvi $(BUILD)/*.fdb_latexmk $(BUILD)/*.fls $(BUILD)/*.idx $(BUILD)/*.lof \
		$(BUILD)/*.out $(BUILD)/*.pdf $(BUILD)/*.run.xml \
		$(BUILD)/*.toc $(BUILD)/*.xdy $(BUILD)/*.xdv
	$(RM) -rf $(BUILD)/whyse-*/
	$(RM) -f $(BUILD)/whyse-*.tar

tool-syntax:
	$(markup) $(SRC)/whyse.nw | \
	$(autodefs_elisp) | \
	$(finduses) | \
	$(clean_docs) | \
	$(noidx) -delay
