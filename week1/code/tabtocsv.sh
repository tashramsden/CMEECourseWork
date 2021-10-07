#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tabtocsv.sh
# Description: substitute the tabs in the files with commas
#
# Saves the output into a .csv file
# Arguments: 1 -> tab delimited file
# Date: Oct 2021

# $1 is the argument placeholder for a var (here the filename)

# echo "Creating a comma delimited version of $1 ..."
# cat $1 | tr -s "\t" "," >> $1.csv
# echo "Done!"
# exit

# below checks if no args were supplied, if so prints feedback and exits
# in bash, # treated as special param which expands to number of positional params
# so here, this will count how many args passed and check if == 0

if [ $# -ne 1 ]; then
    echo "You need to provide one input file (should be separated by tabs which will be replaced with commas).";
    exit;
else
    echo "Creating a comma delimited version of $1 ...";
    cat $1 | tr -s "\t" "," >> $1.csv;
    echo "Done!";
    exit;
fi
