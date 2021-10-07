#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: ConcatenateTwoFiles.sh
# Description: More shell variable examples - join 2 files

# Note: 3 variables need to be passed here not just 2! ($3 isn't created automatically)

# cat $1 > $3
# cat $2 >> $3
# echo "Merged File is"
# cat $3

if [ $# -eq 0 ] || [ $# -eq 1 ] || [ $# -eq 2 ]; then
    echo "You need to provide 3 arguments in total: 2 files to be concatenated and an output file.";
    exit;
else
    cat $1 > $3;
    cat $2 >> $3;
    echo "Merged File is";
    cat $3;
    exit;
fi
