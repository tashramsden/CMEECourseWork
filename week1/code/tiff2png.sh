#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tiff2png.sh
# Description: More shell variable examples - convert all tiffs in a directory to png and save to same location as input
# Arguments: 1 -> Optional: the name of a directory (which hopefully contains tiff files)
#                 Default: If $1 left blank, will default to ../data and convert all tifs here

if [ -z "$1" ]; then  # -z checks if $1 is empty string
    echo "Provide a relative path if you want to convert .tifs in another directory (default is ../data)."
    # default directory
    TIF_LOC=../data; 
else
    # checks input is a directory
    if [ -d "$1" ]; then
        TIF_LOC=$1;
        echo "Searching $TIF_LOC for .tif files... If none exist nothing will happen."
    else
        echo "Please provide the name of a directory which (ideally) contains .tifs (if no arguments passed, default is ../data).";
        exit;
    fi
fi

# if more than one arg passed, code still runs but ignores additional args
if [ $# > 1 ]; then
    echo "NOTE: You provided more than one argument but only the first will be considered."
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
