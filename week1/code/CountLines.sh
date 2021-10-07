#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: Countlines.sh
# Description: More shell variable examples - Count lines in a file

NumLines=`wc -l < $1`
echo "The file $1 has $NumLines lines"
echo