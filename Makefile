weave: clean
	noweave -delay -autodefs elisp -index whs.nw > whs.tex

compile-pdf: tangle weave
	latexmk --lualatex --interaction=nonstopmode -f whs.tex
	lualatex whs.tex

tangle: clean
	notangle -Rwhs.el whs.nw > whs.el

# Remove backup files and LaTeX garbage and cache files.
clean:
	$(RM) *~ *.aux *.bbl *.bcf *.blg *.brf *.dvi *.fdb_latexmk *.fls *.idx *.lof *.log *.out *.pdf *.run.xml *.tex *.toc *.xdy
	$(RM) whs.el

tool-syntax:
	/usr/lib/noweb/markup whs.nw | /usr/lib/noweb/autodefs.elisp | /usr/lib/noweb/finduses | /usr/lib/noweb/noidx -delay
