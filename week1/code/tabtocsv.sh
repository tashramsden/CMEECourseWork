#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tabtocsv.sh
# Description: substitute the tabs in the files with commas
# Saves the output into a .csv file in same location as input file
# Arguments: 1 -> tab delimited file
# Date: Oct 2021

# $1 is the argument placeholder for a var (here the filename)

# checks if one file provided, if not exits
# in bash, # treated as special param which expands to number of positional params
# so here, this will count how many args passed and check if != 1

if [ $# -ne 1 ]; then
    echo "You need to provide one input file (should be separated by tabs which will be replaced with commas).";
    exit;
elif ! [ -f $1 ]; then
    echo "Please provide a file as an input.";
    exit;
fi

echo "Creating a comma delimited version of $1 ..."

## strip extension (whatever it is) and save output .csv to same location as input file
# echo ${1:: -4}  # this would strip extension - UNLESS file w no extension, then would remove end of name...
filename=$(basename "$1")  # remove path
extension="${filename##*.}"  # isolate extension
path_and_name=${1//$extension/csv}  # get path + name by removing extension from original input (means take $1 remove bit after // replace w bit after /)
cat $1 | tr -s "\t" "," >> $path_and_name
echo "Done!"
exit
