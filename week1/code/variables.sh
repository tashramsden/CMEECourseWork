#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: variables.sh
# Description: Exploring variables in shell scripts

# NOTE: lack of spaces for assigning variables!

# Shows the use of variables
MyVar="some string"
echo "The current value of the variable is:" $MyVar
echo "Please enter a new string"
read MyVar
echo "The current value of the variable is:" $MyVar

# Reading multiple values
echo "Enter two numbers separated by space(s)"
read a b
# check if $a and $b are numbers and that only 2 inputs provided
if ! [[ "$a" =~ ^[0-9]*\.[0-9]+$ ]] || ! [[ "$b" =~ ^[0-9]*\.[0-9]+$ ]]; then
  echo "Please enter 2 numbers only.";
  exit;
else
  echo "You entered" $a "and" $b". Their sum is:";
  # works with floats too
  mysum=`echo "$a + $b" | bc`;
  echo $mysum;
fi
