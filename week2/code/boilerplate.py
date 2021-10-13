#!/usr/bin/env python3

"""Description of this program or application.
You can use several lines."""
# can access docstrings at run time, try import boilerplate, then help(boilerplate)

__appname__ = '[application name here]'
__author__ = 'your name (your@email.address)'
__version__ = '0.0.1'
__license__ = 'License for this code/program'

## imports ##
import sys  # module to interface the program w the operating system

## constants ##


## functions ##
def main(argv):
    """Main entry point of the program"""
    print("This is a boilerplate")
    return 0

if __name__ == "__main__":
    """Makes sure the "main" function is called from command line"""
    status = main(sys.argv)  # calls main, passes args, status will be 0 if main runs successfully
    sys.exit(status)  # terminates program, w status code
    # sys.exit("I am exiting right now!")
