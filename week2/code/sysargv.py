#!/usr/bin/env python3

"""Script exploring sys.argv: try running the script with different numbers of arguments, e.g. run sysargv.py 1 2 var3"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
print("This is the name of the script: ", sys.argv[0])
print("Number of arguments: ", len(sys.argv))
print("The arguments are: ", str(sys.argv))
