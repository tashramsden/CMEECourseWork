#!/usr/bin/env python3

"""Profiling code"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'


# profiling = locate sections of code where speed bottlenecks exist
# in general: run -p function/script_name

def my_squares(iters):
    """Takes a number, returns the squares of the numbers up to this number in a list."""
    out = []
    for i in range(iters):
        out.append(i ** 2)
    return out

def my_join(iters, string):
    """Takes a number, iters, and a string; returns a new string which contains the orginal string repeated iters times, each spearated by a comma and space."""
    out = ''
    for i in range(iters):
        out += string.join(", ")
    return out

def run_my_funcs(x,y):
    """Takes a number and string; passes these to my_squares() and my_join().
    When finished, returns 0"""
    print(x,y)
    my_squares(x)
    my_join(x,y)
    return 0

run_my_funcs(10000000,"My string")

# here, my_join() taking up lots of run time (calling join() LOTS)
