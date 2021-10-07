#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileLaTeX.sh
# Description: Bash script to compile LaTeX

pdflatex $1
bibtex $(basename "$1" .tex)
pdflatex $1
pdflatex $1
evince $(basename "$1" .tex).pdf &

## Cleanup
rm *.aux
rm *.log
rm *.bbl
rm *.blg
