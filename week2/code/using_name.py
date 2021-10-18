#!/usr/bin/env python3
# Filename: using_name.py

"""Exploring the special __name__ variable: in the ipython3 console try running the script using %run using_name.py, and try import using_name."""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

if __name__ == "__main__":
    print("This program is being run by itself")
else:
    print("I am being imported from another module")

print("This module's name is: " + __name__)
