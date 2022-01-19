#!/bin/bash
# Author: Awesome Aarvarks 
# Script: run_get_TreeHeight.sh
# Desc: test get_TreeHeight.R and get_TreeHeight.py with trees.csv
# Arguments: 1 .csv file)
# Date: Dec 2021

echo -e "Testing get_TreeHeight.R \n"
Rscript get_TreeHeight.R ../data/trees.csv

echo -e "Testing get_TreeHeight.py"
python3 get_TreeHeight.py ../data/trees.csv