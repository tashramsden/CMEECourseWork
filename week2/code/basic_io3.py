#!/usr/bin/env python3

"""Storing objects. Writes a binary file, testp.p, to ../sandbox containing the contents of a dictionary, then reads this binary file and prints its contents"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

# To save an object (even complex) for later use
my_dictionary = {"a key": 10, "another_key": 11}

import pickle

# b here means accept binary files
f = open("../sandbox/testp.p", "wb")
pickle.dump(my_dictionary, f)
f.close()

## Load the data again
f = open("../sandbox/testp.p", "rb")
another_dictionary = pickle.load(f)
f.close()

print(another_dictionary)
