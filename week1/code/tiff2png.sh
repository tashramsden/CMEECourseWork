#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tiff2png.sh
# Description: More shell variable examples - convert tiff to png

## basic 
# for f in *.tif;
#     do
#         echo "Converting $f";
#         convert "$f" "$(basename "$f" .tif).png";
#     done


# default: converts .tifs in ../data and saves .pngs to results
# optional: can take 1 relative path as input, will convert .tifs here

if [ -z "$1" ]; then  # -z checks if $1 is empty string
    echo "Provide a relative path if you want to convert .tifs in another directory (default is ../data)."
    TIF_LOC=../data;
else
    TIF_LOC=$1;
    echo "Searching $TIF_LOC for .tif files... If none exist nothing will happen."
fi

shopt -s nullglob # if no .tifs found do not print error
for f in $TIF_LOC/*.tif;
    do
        echo "Converting $f";
        convert "$f" "../results/$(basename "$f" .tif).png";
    done
exit;
