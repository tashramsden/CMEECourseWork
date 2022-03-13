import os
from ctypes import *

workingdir = os.getcwd()
file = workingdir + "/matrix.so"

cdll.LoadLibrary("file")
cmatrix = CDLL("file")

# bindings for the library's functions - would only have to do this once
cmatrix.new_int_matrix.argtypes = [c_int, c_int]
cmatrix.new_int_matrix.restype = c_void_p

cmatrix.delete_matrix.argtypes = [c_int, c_int]

cmatrix.get_element.argtypes = [c_int, c_int, c_void_p]
cmatrix.get_element.restype = c_int


mat = cmatrix.new_int_matrix(5, 5)

cmatrix.get_element(0, 0, mat)
# also try going out of bounds:
cmatrix.get_element(0, 10, mat) # will quit python - coded so that exits program when error
