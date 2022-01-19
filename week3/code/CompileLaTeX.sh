#!/bin/bash
# Author: Grace gls21@ic.ac.uk
# Script: CompileLaTeX.sh
# Description: creates a pdf version of a LaTeX document. This version of CompileLatex will not work for Latex documents with bibliographies. 
# Arguments: 1 .tex file
# Date: Oct 2021

Rscript TAutoCorr.R

echo -e "\nCreating a pdf version of LaTeX document\n"

if [ $# -ne 1 ]
then
    echo -e "\nError: This script requires a .tex file as an input\n"
    exit

else
    if [[ $1 == *.tex ]]
    then
        pdflatex $1
        pdflatex $1
        mv $(basename -s .tex $1).pdf ../results
        evince ../results/$(basename -s .tex $1).pdf &     # without the &, it will not do the rm bit 

        ##Cleanup
        rm *.aux
        rm *.log
        exit
        
    else
        pdflatex $1.tex
        pdflatex $1.tex
        mv $1.pdf ../results
        evince ../results/$1.pdf &

        ##Cleanup
        rm *.aux
        rm *.log
        exit
    fi 

    echo -e "\nDone!\n"
fi