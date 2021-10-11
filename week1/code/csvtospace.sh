#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tcsvtospace.sh
# Description: Practical - convert csv to space separated values file and save to ../results
# Arguments: 1 -> Optional:
#                   Can be the name of a csv file
#                   Can be the name of a directory (which hopefully contains csv files)
#                   If left blank, default is to convert csvs from ../data/temperatures

## 1. Convert individual csv files

# if [ $# -ne 1 ]; then
#     echo "You need to provide one input csv file (commas will be replaced with a space).";
#     exit;
# else
#     filename=$(basename "$1")
#     extension="${filename##*.}"
#     # echo $extension
#     # checks if csv file passed
#     if [ $extension != "csv" ]; then
#         echo "You need to provide a csv file (commas will be replaced with spaces).";
#         exit;
#     else
#         echo "Creating a space separated value version of $1 ...";
#         cat $1 | tr -s "," " " >> "../results/$(basename "$1" .csv).txt";
#         echo "Done!";
#         exit;
#     fi
# fi


## 2. Converts all csv files in a directory to space separated 
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


## 3. Converts csv files in ../data/temperatures by default - outputs always saved to results
## Can be passed a relative path to a different directory, any csv files here will be converted
## Can be passed name of csv file, only this will be converted

if [ $# -ne 1 ] && [ $# -ne 0 ]; then
    echo -e "\nPlease provide a maximum of one argument:"
    echo "Provide a relative path if you want to convert csv files in another directory (default is ../data/temperatures)"
    echo -e "Or provide a csv file to be converted.\n"
    exit;
fi

# if no args passed, convert csvs in ../data/temperatues as default
if [ $# -eq 0 ]; then
    echo -e "\nProvide a relative path if you want to convert csv files in another directory (default is ../data/temperatures)"
    echo -e "Or provide a csv file to be converted.\n"
    # echo "You need to provide one input: either a csv file or a directory containing csv files.";
    # exit;
    CSV_LOC=../data/temperatures;
fi

# if a directory passed, search for csvs here
if [ $# -eq 1 ] && [ -d $1 ]; then
    CSV_LOC=$1;
    echo -e "\nSearching $CSV_LOC for csv files... If none exist nothing will happen.\n"

# if a csv file passed just convert this
elif [ $# -eq 1 ]; then
    filename=$(basename "$1")
    extension="${filename##*.}"
    # echo $extension
    # checks if csv file passed
    if [ $extension != "csv" ]; then
        echo -e "\nYou need to provide either a csv file or relative path to a directory.";
        echo -e "You can also pass no arguments: csv files in ../data/temperatures will be converted by default.\n"
        exit;
    else
        echo -e "\nCreating a space separated value version of $1 ...";
        cat $1 | tr -s "," " " >> "../results/$(basename "$1" .csv).txt";
        echo -e "Done!\n";
        exit;
    fi

fi

# if no args or if directory passed, search for csv files here to convert
shopt -s nullglob # if no .csvs found do not print error
for csv in $CSV_LOC/*.csv;
    do
        echo "Creating a space separated value version of $csv ...";
        cat $csv | tr -s "," " " >> "../results/$(basename "$csv" .csv).txt";
        echo -e "Done!\n";
    done
exit;
