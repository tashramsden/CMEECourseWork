#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: ConcatenateTwoFiles.sh
# Description: More shell variable examples - join 2 files, save output to ../results (inputs can be from different directories)
# Arguments: 1 -> A file name (+relative path - can have any location, doesn't have to be same as other file), 
#            2 -> A file name, 
#            3 -> Optional, provide a name for the output file

# Note: 3 variables need to be passed here not just 2! ($3 isn't created automatically)
# cat $1 > $3
# cat $2 >> $3
# echo "Merged File is"
# cat $3

# check num inputs
if [ $# -ne 3 ]; then
    if [ $# -ne 2 ]; then
        echo "You need to provide at least 2 arguments (max 3): 2 files to be concatenated and (optional) name an output file.";
        exit;
    else
        OUTPUT="../results/concatenated_output.txt";
    fi
else
    OUTPUT="../results/$3";
fi

# check if files
if ! [ -f "$1" ] || ! [ -f "$2" ]; then
    echo "Your inputs must be file names.";
    exit;
fi

cat $1 > $OUTPUT
cat $2 >> $OUTPUT
echo "Merged File, $OUTPUT, is"
cat $OUTPUT
exit
