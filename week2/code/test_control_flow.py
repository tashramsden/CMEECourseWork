#!/usr/bin/env python3

"""Some functions exemplifying the use of control statements."""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

import sys
import doctest

def even_or_odd(x=0):
    """Find whether a number x is even or odd.
    
    >>> even_or_odd(10)
    '10 is even!'

    >>> even_or_odd(5)
    '5 is odd!'

    whenever a float is provided, the closest integer is used:
    >>> even_or_odd(3.2)
    '3 is odd!'

    in case of negative numbers, the posiitve is taken:
    >>> even_or_odd(-2)
    '-2 is even!'

    """
    # define function to be tested
    if x % 2 == 0:
        return "%d is even!" % x
    return "%d is odd!" % x

def main(argv):
    """Main entry point of the program"""
    print(even_or_odd(22))
    print(even_or_odd(33))
    return 0

if __name__ == "__main__":
    status = main(sys.argv) 

doctest.testmod()  # to run with embedded tests
