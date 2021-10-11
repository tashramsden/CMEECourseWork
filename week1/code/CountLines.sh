#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: Countlines.sh
# Description: More shell variable examples - Count lines in a file
# Arguments: 1 -> A file

# check 1 input
if [ $# -ne 1 ]; then
    echo "Please provide one file as an input.";
    exit;
fi

# check if file
if ! [ -f "$1" ]; then
    echo "Please provide a file as an input.";
    exit;
fi

NumLines=`wc -l < $1`
echo "The file $1 has $NumLines lines"
echo
