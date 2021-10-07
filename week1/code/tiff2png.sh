#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tiff2png.sh
# Description: More shell variable examples - convert tiff to png

# # this works on .tif files in current dir and saves them there
# for f in *.tif;
#     do
#         echo "Converting $f";
#         convert "$f" "$(basename "$f" .tif).png";
#     done


# # this works for .tif files in sandbox and saves them there
# for f in ../sandbox/*.tif;
#     do
#         echo "Converting $f";
#         convert "$f" "../sandbox/$(basename "$f" .tif).png";
#     done


# FOR ABOVE: in terminal just run bash tiff2png.sh (no need to pass args, all .tif files in current dir/sandbox will be converted)


# FOR BELOW: in terminal provide dir containing tif files as arg

# echo "Please provide the relative path to the directory containing your .tif files (leave blank to use current dir)."
# read dir
# if [$dir == ""]; then
#     for f in *.tif;
#         do
#             echo "Converting $f";
#             convert "$f" "$(basename "$f" .tif).png";
#         done
#     exit;
# else
#     for f in $dir/*.tif;
#         do
#             echo "Converting $f";
#             convert "$f" "$dir/$(basename "$f" .tif).png";
#         done
#     exit;
# fi

# If no dir arg provided uses working dir, else will find dir
DIR=${1:-""}
if [$DIR == ""]; then
    for f in *.tif;
        do
            echo "Converting $f";
            convert "$f" "$(basename "$f" .tif).png";
        done
    exit;
else
    for f in $DIR/*.tif;
        do
            echo "Converting $f";
            convert "$f" "$DIR/$(basename "$f" .tif).png";
        done
    exit;
fi
