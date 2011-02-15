all: clean
	for i in *.tex; do pdflatex "$$i"; done
	for i in *.tex; do pdflatex "$$i"; done
	open *.pdf

clean:
	rm -f *.{aux,log,dvi,lof,lot,pdf,toc}

cleantex:
	rm -f sections/*.tex
