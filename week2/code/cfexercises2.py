#!/usr/bin/env python3

"""Some examples of loops and conditionals in functions"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'


###############################

def hello_1(x):
    """Takes a number, x, prints hello for numbers up to x which are divisible by 3"""
    for j in range(x):
        if j % 3 == 0:
            print("hello")
    print(" ")

hello_1(12)

###############################

def hello_2(x):
    """Takes a number, x, prints hello for numbers up to x if the number leaves a remainder of 3 when divided by 5 or 4"""
    for j in range(x):
        # print(j)
        if j % 5 == 3:
            print("hello")
        elif j % 4 == 3:
            print("hello")
    print(" ")

hello_2(12)

################################

def hello_3(x, y):
    """Takes 2 numbers, x and y, prints hello n times, where n = y - x"""
    for i in range(x, y):
        print("hello")
    print(" ")

hello_3(3, 17)

################################

def hello_4(x):
    """Takes a number, x, prints hello for every 3 numbers between x and 15"""
    while x != 15:
        print("hello")
        x = x + 3
    print(" ")

hello_4(0)

################################

def hello_5(x):
    """Takes a number, x, increases x by 1 up to 99 and prints hello when this number equals 18, and prints hello 7 times when it equals 31"""
    while x < 100:
        if x == 31:
            for k in range(7):
                print("hello")
        elif x == 18:
            print("hello")
        x = x + 1
    print(" ")

hello_5(12)

################################

# WHILE loop with BREAK
def hello_6(x, y):
    """Takes 2 arguments: x and a number. If x is True, increases the number by 1 and prints hello {number} until the number reaches 6 and the function exits"""
    while x: 
        print("hello! " + str(y))
        y += 1
        if y == 6:
            break
    print(" ")

hello_6(True, 0)

################################
