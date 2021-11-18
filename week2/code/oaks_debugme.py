#!/usr/bin/env python3

"""Reads ../data/TestOaksData.csv; determines whether the tree species are oaks or not. 
Oak species written to a new csv, ../data/JustOaksData.csv"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

import csv
import sys
import doctest

#Define function
def is_an_oak(name):
    """ Returns True if name is 'quercus' 
    
    >>> is_an_oak('Fagus')
    False

    >>> is_an_oak('Quercus')
    True

    >>> is_an_oak('Quercuss')
    False

    >>> is_an_oak('Querc')
    False

    """
    return name.lower() == 'quercus'

def main(argv): 
    """Reads ../data/TestOaksData, writes only oak information to ../data/TestOaksData.csv"""
    f = open('../data/TestOaksData.csv','r')
    g = open('../data/JustOaksData.csv','w')
    taxa = csv.reader(f)
    csvwrite = csv.writer(g)
    for row in taxa:
        print(row)
        print ("The genus is: ") 
        print(row[0] + '\n')
        if is_an_oak(row[0]):
            print('FOUND AN OAK!\n')
            csvwrite.writerow([row[0], row[1]])    

    return 0
    
if (__name__ == "__main__"):
    status = main(sys.argv)

doctest.testmod()
