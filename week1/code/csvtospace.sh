#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: tcsvtospace.sh
# Description: Practical - convert csv to space separated values file and save to same location as inputs
# Arguments: 1 -> Optional:
#                   Can be the name of a csv file - only this will be converted
#                   Can be the name of a directory (which hopefully contains csv files) - all csvs converted
#                   If left blank, default is to convert all csvs from ../data/temperatures

if [ $# -ne 1 ] && [ $# -ne 0 ]; then
    echo -e "\nPlease provide a maximum of one argument, either:"
    echo "Provide a directory if you want to convert csv files in another directory (default is ../data/temperatures if no argument passed)"
    echo -e "Or provide a csv file to be converted.\n"
    exit;
fi

# if no args passed, convert csvs in ../data/temperatues as default
if [ $# -eq 0 ]; then
    echo -e "\nYou can provide a relative path if you want to convert csv files in another directory (default is ../data/temperatures)"
    echo -e "Or provide a csv file to be converted.\n"
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
        # cat $1 | tr -s "," " " >> "../results/$(basename "$1" .csv).ssv";  # output to ../results
        # cat $1 | tr -s "," " " >> "${1:: -4}.ssv";  # trim extension...
        path_and_name_ssv=${1//$extension/ssv}  # path + name + ssv extension by removing original extension
        cat $1 | tr -s "," " " >> $path_and_name_ssv;
        echo -e "Done!\n";
        exit;
    fi

fi

# if no args or if directory passed, search for csv files here to convert
shopt -s nullglob # if no .csvs found do not print error - will get message that "If none exist nothing will happen"
for csv in $CSV_LOC/*.csv;
    do
        echo "Creating a space separated value version of $csv ...";
        # cat $csv | tr -s "," " " >> "../results/$(basename "$csv" .csv).ssv";  # output to ../results
        # cat $csv | tr -s "," " " >> "${csv:: -4}.ssv";  # trim extension...
        filename=$(basename "$csv")  # remove path
        extension="${filename##*.}"  # isolate extension
        path_and_name_ssv=${csv//$extension/ssv}  # path + name + ssv extension by removing original extension
        cat $csv | tr -s "," " " >> $path_and_name_ssv;
        echo -e "Done!\n";
    done
exit;
