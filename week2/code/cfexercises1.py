#!/usr/bin/env python3

"""Some input/output functions."""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

## imports ##
import sys

## functions ##
def foo_1(x=9):
    """Finds square root of a number, x"""
    return f"\nThe square root of {x} is {x ** 0.5}"

def foo_2(x=5, y=1.2):
    """Return the largest of two numbers"""
    if x > y:
        return f"\nThe bigger number of {x} and {y} is: {x}"
    return f"\nThe bigger number of {x} and {y} is: {y}"

# moves the biggest number to the last position (if re-run w output would sort all into ascending order)
def foo_3(x=8, y=9, z=3):
    """Moves the largest of 3 numbers to the last position"""
    if x > y:
        # swaps positions depending on relative size
        tmp = y
        y = x
        x = tmp
    if y > z:
        tmp = z
        z = y
        y = tmp
    return f"\nReordered list: {[x, y, z]}"

def foo_4(x=3):
    "Returns the factorial of a number, x"
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return f"\nThe factorial of {x} is {result}"

def foo_5(x=3):
    """Returns the factorial of a number, x, using a recursive method"""
    if x == 1:
        print("\nThe factorial is:")
        return 1
    return x * foo_5(x - 1)

def foo_6(x=3):
    """Returns the factorial of a number, x"""
    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return f"\nThe factorial is: {facto}"

def main(argv):
    """Main entry point of the program"""
    print(foo_1(16))
    print(foo_2(3.4, 3.5))
    print(foo_2(100, -3))
    print(foo_3(8, 4, 5))
    print(foo_4(20))
    print(foo_4(5))
    print(foo_5(5))
    print(foo_6(5))
    return 0

if __name__ == "__main__":
    status = main(sys.argv) 
    sys.exit(status) 
