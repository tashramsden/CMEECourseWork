#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileReport.sh
# Description: Bash script to compile LaTeX, pdf output saved to ../results


# Arguments: 1 -> The name of a LaTeX .tex file in the working directory (can have .tex extension or none)


# # PROB REMOVE LATER!!!?
# if [ $# -ne 1 ] || [ -d $1 ]; then
#     echo "You need to provide the name of one TeX file to compile from the current directory.";
#     exit;
# fi


pdflatex BacterialGrowthModelling.tex
bibtex BacterialGrowthModelling
pdflatex BacterialGrowthModelling.tex
pdflatex BacterialGrowthModelling.tex

# save output pdf to results instead
cp BacterialGrowthModelling.pdf ../results
rm BacterialGrowthModelling.pdf

# maybe comment out?!
evince ../results/BacterialGrowthModelling.pdf &

rm *.aux
rm *.log
rm *.bbl
rm *.blg
