#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileLaTeX.sh
# Description: Bash script to compile LaTeX, pdf output saved to ../results
# Arguments: 1 -> The name of a LaTeX .tex file in the working directory (can have .tex extension or none)


if [ $# -ne 1 ] || [ -d $1 ]; then
    echo "You need to provide the name of one TeX file to compile from the current directory.";
    exit;
fi


#### This method a bit clunky - hard coded paths.... (but DOES allow compiling from different (set) directory than working dir and outputs pdf to results)
## .tex and .bib must be saved in ../data/LaTeX - arg passed is still just name of file NOT inc. path - FirstExample or FirstExample.tex

# pdflatex --output-directory ../results ../data/LaTeX/$(basename "$1" .tex).tex
## .bib has to be in same location as outputs for biblio to be compiled correctly
# cp ../data/LaTeX/*.bib ../results
# cd ../results ; bibtex $(basename "$1" .tex)
# cd ../code
# bibtex ../data/LaTeX/$(basename "$1" .tex)
# pdflatex --output-directory ../results ../data/LaTeX/$(basename "$1" .tex).tex
# pdflatex --output-directory ../results ../data/LaTeX/$(basename "$1" .tex).tex
# evince ../results/$(basename "$1" .tex).pdf &

## Cleanup
# rm ../results/*.aux
# rm ../results/*.log
# rm ../results/*.bbl
# rm ../results/*.blg
# # remove copied .bib file too
# rm ../results/*.bib


## Alternatively!!
## Inputs from working directory, output goes to results (can pass FirstExample or FirstExample.tex)
pdflatex $(basename "$1" .tex).tex
bibtex $(basename "$1" .tex)
pdflatex $(basename "$1" .tex).tex
pdflatex $(basename "$1" .tex).tex

# save output pdf to results instead
cp $(basename "$1" .tex).pdf ../results
rm $(basename "$1" .tex).pdf

# evince ../results/$(basename "$1" .tex).pdf &

rm *.aux
rm *.log
rm *.bbl
rm *.blg
