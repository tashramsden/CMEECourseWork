#!/usr/bin/env python3

"""Quick profiling with timeit"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

##############################################################################
# loops vs. list comprehensions: which is faster?
##############################################################################

iters = 1000000

import timeit

from profileme import my_squares as my_squares_loops

from profileme2 import my_squares as my_squares_lc

##############################################################################
# loops vs. the join method for strings: which is faster?
##############################################################################

mystring = "my string"

from profileme import my_join as my_join_join

from profileme2 import my_join as my_join


# try running these from ipython:
# %timeit my_squares_loops(iters)
# %timeit my_squares_lc(iters)
# %timeit (my_join_join(iters, mystring))
# %timeit (my_join(iters, mystring))


# or also just time the functions like this:
import time
start = time.time()
my_squares_loops(iters)
print("my_squares_loops takes %f s to run." % (time.time() - start))

start = time.time()
my_squares_lc(iters)
print("my_squares_lc takes %f s to run." % (time.time() - start))

# BUT:
# timeit reruns and takes ave time
# vs time will give diff answer each time
