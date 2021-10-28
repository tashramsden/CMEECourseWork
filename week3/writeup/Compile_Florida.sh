#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileFlorida.sh
# Description: Bash script to compile Florida.tex LaTeX, pdf output
# Arguments: 0 (specific for Florida.tex)

# run R script, graphics will be saved to results directory - used in .tex
Rscript ../code/Florida.R

pdflatex Florida.tex
bibtex Florida
pdflatex Florida.tex
pdflatex Florida.tex
evince Florida.pdf &

rm *.aux
rm *.log
rm *.bbl
rm *.blg
