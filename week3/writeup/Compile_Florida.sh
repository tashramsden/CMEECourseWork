#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileFlorida.sh
# Description: Bash script to compile LaTeX, pdf output
# Arguments: 1 -> The name of a LaTeX .tex file in the working directory (can have .tex extension or none)


if [ $# -ne 1 ] || [ -d $1 ]; then
    echo "You need to provide the name of one TeX file to compile from the current directory.";
    exit;
fi

## Inputs from working directory, output goes to results (can pass FirstExample or FirstExample.tex)
pdflatex $(basename "$1" .tex).tex
bibtex $(basename "$1" .tex)
pdflatex $(basename "$1" .tex).tex
pdflatex $(basename "$1" .tex).tex
evince $(basename "$1" .tex).pdf &

# # save output pdf to results instead
# cp $(basename "$1" .tex).pdf ../results
# rm $(basename "$1" .tex).pdf
# evince ../results/$(basename "$1" .tex).pdf &

rm *.aux
rm *.log
rm *.bbl
rm *.blg
