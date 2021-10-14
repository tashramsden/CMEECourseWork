#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileLaTeX.sh
# Description: Bash script to compile LaTeX, pdf output saved to ../results
# Arguments: 1 -> The name of a LaTeX .tex file in the working directory (can have .tex extension or none)


if [ $# -ne 1 ]; then
    echo "You need to provide one TeX file to compile from the current directory.";
    exit;
fi


#### This method a bit clunky - hard coded paths.... (but does allow compiling from different directory than working dir and outputs pdf to results)

## .TEX AND .BIB IN ../data/LaTeX
## must be saved in ../data/LaTeX - arg passed is still just name of file not path - FirstExample/FirstExample.tex

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
## Inputs from working directory, output goes to results
pdflatex $(basename "$1" .tex).tex
bibtex $(basename "$1" .tex)
pdflatex $(basename "$1" .tex).tex
pdflatex $(basename "$1" .tex).tex

# save ouput pdf to results instead
cp $(basename "$1" .tex).pdf ../results
rm $(basename "$1" .tex).pdf

evince ../results/$(basename "$1" .tex).pdf &

rm *.aux
rm *.log
rm *.bbl
rm *.blg
