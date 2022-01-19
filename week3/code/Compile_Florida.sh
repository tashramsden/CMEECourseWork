#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: Compile_Florida.sh
# Description: Bash script to compile Florida_warming.tex LaTeX, pdf output
# Arguments: 0 (specific for Florida_warming.tex)

# run R script, graphics will be saved to results directory - used in .tex
Rscript Florida_warming.R

# (no biblioraphy for this)
pdflatex Florida_warming.tex
pdflatex Florida_warming.tex
pdflatex Florida_warming.tex
# evince Florida_warming.pdf &

rm *.aux
rm *.log
