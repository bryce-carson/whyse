VERSION = 0.1

weave: clean
	noweave -delay -autodefs elisp -index whs.nw > whs.tex

compile-pdf: tangle weave
	latexmk --lualatex --interaction=nonstopmode -f whs.tex
	lualatex whs.tex

tangle: clean
	notangle -Rwhs.el whs.nw > whs.el
	notangle -Rwhs-pkg.el whs.nw > whs-pkg.el
	mkdir whs-${VERSION}
	mv -t whs-${VERSION} whs.el whs-pkg.el
	tar --create --file whs-${VERSION}.tar whs-${VERSION}
	tar --list --file whs-${VERSION}.tar

# Remove backup files and LaTeX garbage and cache files.
clean:
	$(RM) *~ *.aux *.bbl *.bcf *.blg *.brf *.dvi *.fdb_latexmk *.fls *.idx *.lof *.log *.out *.pdf *.run.xml *.tex *.toc *.xdy
	rm -rf whs-*/

tool-syntax:
	/usr/lib/noweb/markup ~/src/whs/whs.nw | \
	/usr/lib/noweb/autodefs.elisp | \
	/usr/lib/noweb/finduses | \
	/usr/lib/noweb/noidx -delay
