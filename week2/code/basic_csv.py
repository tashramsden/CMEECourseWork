#!/usr/bin/env python3

"""Reads testcsv.csv from ../data; prints species information and writes new file, bodymass.csv, to ../data with species and bodymass info"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

import csv

# Read a file containing:
# 'Species','Infraorder','Family','Distribution','Body mass male (Kg)'
with open("../data/testcsv.csv", "r") as f:

    csvread = csv.reader(f)
    temp = []
    for row in csvread:
        temp.append(tuple(row))
        print(row)
        print("The species is", row[0])

# write a file containing only species name and body mass
with open("../data/testcsv.csv", "r") as f:
    with open("../data/bodymass.csv", "w") as g:

        csvread = csv.reader(f)
        csvwrite = csv.writer(g)
        for row in csvread:
            print(row)
            # print(row[0])
            # print(row[4])
            csvwrite.writerow([row[0], row[4]])
