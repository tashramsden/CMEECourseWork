#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tcsvtospace.sh
# Description: Practical - convert csv to space separated values file

if [ $# -ne 1 ]; then
    echo "You need to provide one input csv file (commas will be replaced with a space).";
    exit;
else
    filename=$(basename "$1")
    extension="${filename##*.}"
    # echo $extension
    # checks if csv file passed
    if [ $extension != "csv" ]; then
        echo "You need to provide a csv file (commas will be replaced with spaces).";
        exit;
    else
        echo "Creating a space separated value version of $1 ...";
        cat $1 | tr -s "," " " >> "../results/$(basename "$1" .csv).txt";
        echo "Done!";
        exit;
    fi
fi

## Below converts all csv files in a directory to space separated 
## default: ../data/temperatures
## optional: provide a relative path to a different dir containing csv files

# if [ -z "$1" ]; then  # -z checks if $1 is empty string
#     echo "Provide a relative path if you want to convert csv files in another directory (default is ../data/temperatures)."
#     CSV_LOC=../data/temperatures;
# else
#     CSV_LOC=$1;
#     echo "Searching $CSV_LOC for csv files... If none exist nothing will happen."
# fi

# shopt -s nullglob # if no .csvs found do not print error
# for csv in $CSV_LOC/*.csv;
#     do
#         echo "Creating a space separated value version of $csv ...";
#         cat $csv | tr -s "," " " >> "../results/$(basename "$csv" .csv).txt";
#         echo "Done!";
#     done
# exit;
