#!/usr/bin/env python3 

"""Groupwork practical on tree heights 2: Script calculates tree heights of trees in a dataset"""

__author__ = 'CMEE_AwesomeArdvarks'
__version__ = '0.0.1'

import sys
import csv
import numpy as np
import os # for pathname manipulations

# Define the treeheights function
def TreeHeight(degrees, distance):
    """calculates tree heights given distance and angle"""
    radians = degrees * np.pi / 180
    height = distance * np.tan(radians)
    return height

if len(sys.argv) != 2:  # 1st argument is the name of the script, 2nd argument should be the file given as an argument when the script is run 
    print("\nError: This script require 1 input file\n")
    sys.exit("Not attempting to run rest of script") # quits the script and won't run through rest of script if 1 file is not given as input

if len(sys.argv) == 2:
    print("\nThis script will calculate tree heights for trees in", sys.argv[1], "\n")
    
    with open(sys.argv[1], 'r') as f:
        
        Treefile = csv.reader(f)
        
        trees = []   
        for row in Treefile: 
            trees.append(row) # take the (initially) empty list (trees) and add the contents of the row to it 
            #print(row)
        # List comprehension: trees = [row for row in Treefile]
        trees.remove(trees[0]) # remove 1st row (the header)
        #print(trees)
            
        for t in trees:
            #print(t)
            t[1] = float(t[1]) # change the distances datatype to integer
            t[2] = float(t[2]) # change the degree datatype to integer 
            a = TreeHeight(t[2], t[1])  # work out the height of each tree using the function
            #print(a)
            t.append(a) # add a 4th thing (t[3]) to each t in trees  
        #print(trees)

        #Save the csv file in results 
        with open("../results/"+os.path.basename(os.path.splitext(sys.argv[1])[0])+"_treeheights.csv", 'w') as g:    
            treescsv = csv.writer(g)
            treescsv.writerow(['Species', 'Distance.m', 'Angle.degrees', 'Tree.Height.m']) # write a header row
            for t in trees:
                treescsv.writerow(t) # write the rest of the rows (each row is a 't', which contains species, distance, angle, and height)


