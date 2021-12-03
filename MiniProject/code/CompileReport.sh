#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileReport.sh
# Description: Bash script to compile LaTeX, pdf output saved to ../results

pdflatex BacterialGrowthModelling.tex
bibtex BacterialGrowthModelling
pdflatex BacterialGrowthModelling.tex
pdflatex BacterialGrowthModelling.tex

# save output pdf to results
cp BacterialGrowthModelling.pdf ../results
rm BacterialGrowthModelling.pdf

# evince ../results/BacterialGrowthModelling.pdf &

rm *.aux
rm *.log
rm *.bbl
rm *.blg
