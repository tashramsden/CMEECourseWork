#!/usr/bin/env python3

"""File output. Creates a file, testout.txt in ../sandbox containing numbers from 0 to 99"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

# Save the elements of a list to a file
list_to_save = range(100)

f = open("../sandbox/testout.txt", "w")
for i in list_to_save:
    f.write(str(i) + "\n")

f.close()
