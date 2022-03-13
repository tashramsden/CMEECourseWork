from ctypes import *
cdll.LoadLibrary("calc.so")  # need absolute path
mycalc = CDLL("calc.so")
# mycalc.add_float(2.1, 4.4)
mycalc.add_float.argtypes = [c_float, c_float]
mycalc.add_float.restype = c_float
mycalc.add_float(2.1, 4.4)

import os
import subprocess
subprocess.run(["gcc", "calc.c", "main.c"])

#CompletedProcess(args=['gcc', 'calc.c', 'main.c'], returncode=0)

subprocess.run(["gcc", "-shared", "-Wall", "-0"< "calc.so", "-fPIC", "calc.c"])
