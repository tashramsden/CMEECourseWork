#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tcsvtospace.sh
# Description: Practical - convert csv to space separated values file

#TODO: 
# 1. swap commas for spaces
# 2. convert to diff named file
# 3. save output to same dir as original file?
# 4. NOT THIS: work for multiple files (ie just give dir and it will convert all files)
# 5. handle if no args

# This converts csv to space sv and saves w .txt extension BUT saves to working dir....
# echo "Creating a space separated value version of $1 ..."
# cat $1 | tr -s "," "  " >> "$(basename "$1" .csv).txt" 
# echo "Done!"
# exit

# # saves to results folder...
if [ $# -ne 1 ]; then
    echo "You need to provide one input csv file (commas will be replaced with a space).";
    exit;
else
    echo "Creating a space separated value version of $1 ...";
    cat $1 | tr -s "," " " >> "../results/$(basename "$1" .csv).txt";
    echo "Done!";
    exit;
fi



# # WHERE DO WE WANT OUTPUTS?!
# for file in ../data/temperatures/*.csv;
#   do
#     echo "Creating a space separated value version of $file ...";
#     cat $file | tr -s "," "  " >> "../data/temperatures/$(basename "$file" .csv).txt"; 
#     echo "Done!";
#   done
#   exit
