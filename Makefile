VERSION = 0.2

weave: clean
	noweave -troff -autodefs elisp -index whyse.nr > whyse.troff

compile-pdf: tangle weave
	noroff -mms -Tpdf whyse.troff > whyse.pdf

tangle: clean
	notangle -Rwhyse.el whyse.nr > whyse.el
	notangle -Rwhyse-pkg.el whyse.nr > whyse-pkg.el
	notangle -Rtest-parser-with-temporary-buffer.el whyse.nr > test-parser-with-temporary-buffer.el
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
	/usr/local/lib/markup ~/src/whyse/whyse.nr | \
  /usr/local/lib/autodefs.elisp | \
  /usr/local/lib/finduses | \
  ~/src/whyse/clean-docs.awk | \
  /usr/local/lib/noidx -delay
