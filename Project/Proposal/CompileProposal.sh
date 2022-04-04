#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: CompileProposal.sh
# Description: Bash script to compile LaTeX

pdflatex proposal_BumblebeeSelection.tex
bibtex proposal_BumblebeeSelection
pdflatex proposal_BumblebeeSelection.tex
pdflatex proposal_BumblebeeSelection.tex

rm *.aux
rm *.log
rm *.bbl
rm *.blg