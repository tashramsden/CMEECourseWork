#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileLaTeX.sh
# Description: Bash script to compile LaTeX

# THIS ONE IF LEAVE .TEX AND .BIB IN CODE DIR #########################

# if [ $# -ne 1 ]; then
#     echo "You need to provide one TeX file to compile.";
#     exit;
# fi

# ## This works fine but pdf will be saved to code directory not results
# # pdflatex $(basename "$1" .tex).tex
# # bibtex $(basename "$1" .tex)
# # pdflatex $(basename "$1" .tex).tex
# # pdflatex $(basename "$1" .tex).tex
# # evince $(basename "$1" .tex).pdf &

# pdflatex --output-directory ../results $(basename "$1" .tex).tex
# # .bib has to be in same location as outputs for biblio to be compiled correctly
# cp *.bib ../results
# cd ../results ; bibtex $(basename "$1" .tex)
# cd ../code
# bibtex $(basename "$1" .tex)
# pdflatex --output-directory ../results $(basename "$1" .tex).tex
# pdflatex --output-directory ../results $(basename "$1" .tex).tex
# evince ../results/$(basename "$1" .tex).pdf &

# ## Cleanup
# rm ../results/*.aux
# rm ../results/*.log
# rm ../results/*.bbl
# rm ../results/*.blg
# # remove copied .bib file too
# rm ../results/*.bib

# THIS ONE TO RUN WITH .TEX AND .BIB IN LATEX DIR

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
