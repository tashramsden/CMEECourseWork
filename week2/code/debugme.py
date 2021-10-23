#!/usr/bin/env python3

"""Script for testing debugging: originally produced ZeroDivisionError; explored ipdb.set_trace() for debugging; implemented exceptions to catch errors"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

def buggyfunc(x):
    """Takes a number, x, iterates from this down to 0, divides original input by this reduced number"""
    y = x
    for i in range(x):
        try: 
            y = y - 1
            z = x / y
        # import ipdb; ipdb.set_trace()
        # import pdb; pdb.set_trace()
        except ZeroDivisionError:
            print(f"The result of dividing a number by zero is undefined")
        except:
            print(f"This didn't work; x = {x}; y = {y}")
        else:
            print(f"OK; x = {x}; y = {y}, z = {z};")
    return z

buggyfunc(20)
