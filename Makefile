VERSION = 0.2

# Thanks, Stephen Kitt: https://unix.stackexchange.com/a/680758.
TEMP_FILE := $(shell mktemp)
.PHONY: hack
hack:
	tail -n +2 whyse.nr | \
	gawk '/^\(define-package "whyse"/ { gsub(/VERSION/, ${VERSION}, $$0) } { print $$0 }' | \
	gawk '/^<</ { gsub(/>>= \(emacs-lisp\)$$/, ">>=", $$0) } { print $$0 }' | \
	cat > ${TEMP_FILE}

.PHONY: weave
weave: clean hack
	noweave -troff -autodefs elisp -index $(TEMP_FILE) > whyse.troff

.PHONY: compile-pdf
compile-pdf: tangle weave
	noroff -mm -Tpdf whyse.troff > whyse.pdf

.PHONY: tangle
tangle: clean hack
	notangle -Rwhyse.el ${TEMP_FILE} > whyse.el
	notangle -Rwhyse-pkg.el ${TEMP_FILE} > whyse-pkg.el
	notangle -Rtest-parser-with-temporary-buffer.el ${TEMP_FILE} > test-parser-with-temporary-buffer.el
	mkdir whyse-${VERSION}
	mv -t whyse-${VERSION} whyse.el whyse-pkg.el
	cp -t whyse-${VERSION} LICENSE
	tar --create --file whyse-${VERSION}.tar whyse-${VERSION}
	tar --list --file whyse-${VERSION}.tar

# Remove backup files and LaTeX garbage and cache files.
.PHONY: clean
clean:
	$(RM) ${TEMP_FILE} *~ *.troff *.pdf
	$(RM) -rf whyse-*/

.PHONY: tool-syntax
tool-syntax: clean hack
	/usr/local/lib/markup ~/src/whyse/whyse.nr | \
	/usr/local/lib/autodefs.elisp | \
	/usr/local/lib/finduses | \
	~/src/whyse/clean-docs.awk | \
	/usr/local/lib/noidx -delay
