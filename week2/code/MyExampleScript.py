#!/usr/bin/env python3

"""A simple script with a function to calculate the square of a number"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

def foo(x):
    """Returns the square of a number, x"""
    x *= x  # same as x = x*x
    print(x)

foo(2)
