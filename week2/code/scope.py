#!/usr/bin/env python3

"""Testing variable scope - uncomment a section at a time to explore scope with global and local variables"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

#####################################################

## 1.
# _a_global = 10  # a global variable

# if _a_global >= 5:
#     _b_global = _a_global + 5  # also a global variable

# print("Before calling a_function, outside the function, the value of _a_global is", _a_global)
# print("Before calling a_function, outside the function, the value of _b_global is", _b_global)

def a_function1():
    """A function to demonstrate that if global variables are altered within a function, they will remain as they were outside of the function.
    
    This section also demonstrates that local variables are not available outside of the scope of the function they are created in."""
    _a_global = 4 # a local variable

    if _a_global >= 4:
        _b_global = _a_global + 5 # also a local variable

    _a_local = 3

    print("Inside the function, the value of _a_global is ", _a_global)
    print("Inside the function, the value of _b_global is ", _b_global)
    print("Inside the function, the value of _a_local is ", _a_local)

    return None

# a_function1()

# print("After calling a_function, outside the function, the value of _a_global is (still)", _a_global)
# print("After calling a_function, outside the function, the value of _b_global is (still)", _b_global)

# print("After calling a_function, outside the function, the value of _a_local is ", _a_local)


#####################################################


## 2.
# _a_global = 10

def a_function2():
    """A function to demonstrate that global variables are available within functions."""
    _a_local = 4
    
    print("Inside the function, the value _a_local is ", _a_local)
    print("Inside the function, the value of _a_global is ", _a_global)
    
    return None

# a_function2()

# print("Outside the function, the value of _a_global is", _a_global)


#####################################################


## 3.
# _a_global = 10

# print("Before calling a_function, outside the function, the value of _a_global is", _a_global)

def a_function3():
    """A function to demonstrate the use of the global keyword: when used, global variables can be altered from within a function."""
    global _a_global
    _a_global = 5
    _a_local = 4
    
    print("Inside the function, the value of _a_global is ", _a_global)
    print("Inside the function, the value _a_local is ", _a_local)
    
    return None

# a_function3()

# print("After calling a_function, outside the function, the value of _a_global now is", _a_global)


#####################################################


## 4.
def a_function4():
    """A function to explore scope with nested functions: a local variable is created here - will be made global by the nested function within. The global keyword will alter local variables globally (and make them available globally) but not within the scope of another function."""
    _a_global = 10

    def _a_function4_2():
        """Makes the local variable _a_global a global variable, and changes its value globally."""
        global _a_global
        _a_global = 20
    
    print("Before calling a_function4_2, value of _a_global is ", _a_global)

    _a_function4_2()
    
    print("After calling _a_function4_2, value of _a_global is ", _a_global)
    
    return None

# a_function4()

# print("The value of a_global in main workspace / namespace is ", _a_global)


#####################################################


## 5.
# _a_global = 10

def a_function5():
    """Nested function demonstrating scope and the global keyword. If a variable is defined globally, when altered using the global keyword it's value will be altered everywhere."""

    def _a_function5_2():
        """Alters a global variable using the global keyword."""
        global _a_global
        _a_global = 20
    
    print("Before calling a_function5_2, value of _a_global is ", _a_global)

    _a_function5_2()
    
    print("After calling _a_function5_2, value of _a_global is ", _a_global)

# a_function5()

# print("The value of a_global in main workspace / namespace is ", _a_global)
