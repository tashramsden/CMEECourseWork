#!/usr/bin/env python3

"""Workflow with subprocess: this script will run TestR.R and save the output and any bash messages/errors to the results directory."""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'


import subprocess
subprocess.Popen("Rscript --verbose TestR.R > ../results/TestR.Rout 2> ../results/TestR_errFile.Rout", shell=True).wait()
# verbose flag means that all bash/R outputs will be saved to the err file
