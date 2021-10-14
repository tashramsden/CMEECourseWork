#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tiff2png.sh
# Description: More shell variable examples - convert tiff to png and save to same location as input
# Arguments: 1 -> Optional - the name of a directory (which hopefully contains tiff files)
#                 If $1 left blank, will default to ../data

## basic 
# for f in *.tif;
#     do
#         echo "Converting $f";
#         convert "$f" "$(basename "$f" .tif).png";
#     done


# default: converts .tifs in ../data and saves .pngs to same location
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
        # convert "$f" "../results/$(basename "$f" .tif).png";  # output to results
        # convert "$f" "${f:: -4}.png";  # could remove some of name if no extension...
        filename=$(basename "$f")  # remove path
        extension="${filename##*.}"  # isolate extension
        path_and_name_png=${f//$extension/png}  # path + name + png extension by removing original extension
        convert "$f" $path_and_name_png;
    done
exit;
