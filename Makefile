VERSION := 0.1
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD := ${ROOT_DIR}build
SRC := ${ROOT_DIR}src
TEST := ${ROOT_DIR}test

NOWEB_LIB = /usr/lib64/noweb
markup = ${NOWEB_LIB}/markup
finduses = ${NOWEB_LIB}/finduses
noidx = ${NOWEB_LIB}/noidx
clean_docs = ${SRC}/clean-docs.awk

# User serviceable parts
autodefs_elisp = ${NOWEB_LIB}/autodefs.elisp

readme:
	notangle -RREADME.md src/README.nw > ${ROOT_DIR}README.md

weave: clean
	noweave -delay -autodefs elisp -index ${SRC}/whyse.nw > ${BUILD}/whyse.tex

compile-pdf: tangle weave
	cd ${BUILD}; latexmk -c --xelatex --interaction=nonstopmode -f ${BUILD}/whyse.tex; xelatex -f ${BUILD}/whyse.tex;
pdf: compile-pdf

tangle: clean
	notangle -Rwhyse.el ${SRC}/whyse.nw > ${BUILD}/whyse.el
	notangle -Rwhyse-pkg.el ${SRC}/whyse.nw > ${BUILD}/whyse-pkg.el
	mkdir ${BUILD}/whyse-${VERSION}
	mv -t ${BUILD}/whyse-${VERSION} ${BUILD}/whyse.el ${BUILD}/whyse-pkg.el
	cp -t ${BUILD}/whyse-${VERSION} LICENSE
	tar --create --file ${BUILD}/whyse-${VERSION}.tar ${BUILD}/whyse-${VERSION}
	tar --list --file ${BUILD}/whyse-${VERSION}.tar

test: clean tangle
	notangle -Rtest-parser-with-temporary-buffer.el ${SRC}/whyse.nw > ${TEST}/test-parser-with-temporary-buffer.el

clean:
	$(RM) ~/.config/emacs/.cache/whyse.db
	cd ${BUILD}; \
	$(RM) *~ *.aux *.bbl *.bcf *.blg *.brf *.dvi *.fdb_latexmk *.fls *.idx *.lof \
	$(RM) *.log *.out *.pdf *.run.xml whyse.tex *.toc *.xdy *.xdv \
	$(RM) -rf whyse-*/
	$(RM) whyse-*.tar

tool-syntax:
	${markup} ${SRC}/whyse.nw | \
	${autodefs_elisp} | \
	${finduses} | \ # TODO: use the new finduses
	${clean_docs} | \
	${noidx} -delay
