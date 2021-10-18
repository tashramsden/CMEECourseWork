#!/usr/bin/env python3

"""File inputs. Opens test.txt in ../sandbox and prints the lines; first as they appear and then with blank lines removed"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'


# # Open a file for reading
# f = open("../sandbox/test.txt", "r")
# # use "implicit" for loop:
# # if object is a file, python will cycle over lines
# for line in f:
#     print(line)

# f.close()

# # Same example, skip blank lines
# f = open("../sandbox/test.txt", "r")
# for line in f:
#     if len(line.strip()) > 0:
#         print(line)

# f.close()

#############################

## The same but using with open
## (don't have to remember to close file afterwards)

# Open a file for reading
with open('../sandbox/test.txt', 'r') as f:
    # use "implicit" for loop:
    # if the object is a file, python will cycle over lines
    for line in f:
        print(line)

# Once you drop out of the with, the file is automatically closed

# Same example, skip blank lines
with open('../sandbox/test.txt', 'r') as f:
    for line in f:
        if len(line.strip()) > 0:
            print(line)
