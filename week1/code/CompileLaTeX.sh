#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileLaTeX.sh
# Description: Bash script to compile LaTeX, pdf output saved to ../results
# Arguments: 1 -> The name of a LaTeX .tex file which must be saved in ../data/LaTeX (can have.tex extension or none)

# .TEX AND .BIB IN ../data/LaTeX

if [ $# -ne 1 ]; then
    echo "You need to provide one TeX file to compile.";
    exit;
fi

# works if FirstExample OR FirstExample.tex passed
pdflatex --output-directory ../results ../data/LaTeX/$(basename "$1" .tex).tex
# .bib has to be in same location as outputs for biblio to be compiled correctly
cp ../data/LaTeX/*.bib ../results
cd ../results ; bibtex $(basename "$1" .tex)
cd ../code
bibtex ../data/LaTeX/$(basename "$1" .tex)
pdflatex --output-directory ../results ../data/LaTeX/$(basename "$1" .tex).tex
pdflatex --output-directory ../results ../data/LaTeX/$(basename "$1" .tex).tex
evince ../results/$(basename "$1" .tex).pdf &

## Cleanup
rm ../results/*.aux
rm ../results/*.log
rm ../results/*.bbl
rm ../results/*.blg
# remove copied .bib file too
rm ../results/*.bib
