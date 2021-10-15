#!/bin/bash
# Author: Tash Ramsden ter21@imperial.ac.uk
# Script: variables.sh
# Description: Exploring variables in shell scripts + special variables

## special variables
echo "This script was called with $# parameters"
echo "The script's name is $0"
echo "The arguments are $@"
echo "The first argument is $1"
echo "The second argument is $2"

## Assigned variables - explicit declaration
# NOTE: lack of spaces for assigning variables!
MyVar="some string"
echo "The current value of the variable is:" $MyVar
echo
echo "Please enter a new string"
read MyVar
echo
echo "The current value of the variable is:" $MyVar
echo

## Reading multiple values
echo "Enter two numbers separated by space(s)"
read a b
echo "You entered" $a "and" $b". Their sum is:";
# works with floats too
mysum=`echo "$a + $b" | bc`;
echo $mysum;
