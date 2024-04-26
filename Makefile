VERSION = 0.2

weave: clean
	noweave -troff -autodefs elisp -index whyse.nw > whyse.troff

compile-pdf: tangle weave
	noroff -mms -Tpdf whyse.troff > whyse.pdf

tangle: clean
	notangle -Rwhyse.el whyse.nw > whyse.el
	notangle -Rwhyse-pkg.el whyse.nw > whyse-pkg.el
	notangle -Rtest-parser-with-temporary-buffer.el whyse.nw > test-parser-with-temporary-buffer.el
	mkdir whyse-${VERSION}
	mv -t whyse-${VERSION} whyse.el whyse-pkg.el
	cp -t whyse-${VERSION} LICENSE
	tar --create --file whyse-${VERSION}.tar whyse-${VERSION}
	tar --list --file whyse-${VERSION}.tar

# Remove backup files and LaTeX garbage and cache files.
clean:
	$(RM) *~ *.troff *.pdf
	rm -rf whyse-*/

tool-syntax:
	/usr/lib/noweb/markup ~/src/whyse/whyse.nw | \
  /usr/lib/noweb/autodefs.elisp | \
  /usr/lib/noweb/finduses | \
  ~/src/whyse/clean-docs.awk | \
  /usr/lib/noweb/noidx -delay
