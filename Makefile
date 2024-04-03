VERSION = 0.1

weave: clean
	noweave -delay -autodefs elisp -index whyse.nw > whyse.tex

compile-pdf: tangle weave
	latexmk --lualatex --interaction=nonstopmode -f whyse.tex
	lualatex whyse.tex

tangle: clean
	notangle -Rwhyse.el whyse.nw > whyse.el
	notangle -Rwhyse-pkg.el whyse.nw > whyse-pkg.el
	notangle -Rtest-parser-with-temporary-buffer.el whyse.nw > test-parser-with-temporary-buffer.el
	mkdir whyse-${VERSION}
	mv -t whyse-${VERSION} whyse.el whyse-pkg.el
	tar --create --file whyse-${VERSION}.tar whyse-${VERSION}
	tar --list --file whyse-${VERSION}.tar

# Remove backup files and LaTeX garbage and cache files.
clean:
	$(RM) *~ *.aux *.bbl *.bcf *.blg *.brf *.dvi *.fdb_latexmk *.fls *.idx *.lof *.log *.out *.pdf *.run.xml *.tex *.toc *.xdy
	rm -rf whyse-*/

tool-syntax:
	/usr/lib/noweb/markup ~/src/whs/whyse.nw | \
  /usr/lib/noweb/autodefs.elisp | \
  /usr/lib/noweb/finduses | \
  ~/src/whs/clean-docs.awk | \
  /usr/lib/noweb/noidx -delay
