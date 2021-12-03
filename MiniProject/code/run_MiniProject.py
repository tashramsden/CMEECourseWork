#!/usr/bin/env python3

"""Script to run all scripts.
Implementing python subprocess to run the reproducible miniproject code and compile report."""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

import subprocess

# Data prep:
print("Data prep...")
subprocess.Popen("Rscript --verbose DataPrep.R > ../data/run_logs/prep_out.Rout 2> ../data/run_logs/prep_other.Rout",
                 shell=True).wait()

# Model fitting:
print("Model fitting (may take a few minutes)...")
subprocess.Popen("Rscript --verbose ModelFit.R > ../data/run_logs/fitting_out.Rout "
                 "2> ../data/run_logs/fitting_other.Rout",
                 shell=True).wait()

# Plotting and data analysis:
print("Plotting and data analysis...")
subprocess.Popen("Rscript --verbose PlotAnalyse.R > ../data/run_logs/plot_analyse_out.Rout"
                 " 2> ../data/run_logs/plot_analyse_other.Rout",
                 shell=True).wait()

# Report compiling
print("Compiling report...")
with open("../data/run_logs/compile_stdout.txt", "wb") as out, open("../data/run_logs/compile_stderr.txt", "wb") as err:
    subprocess.Popen(["bash", "CompileReport.sh"], stdout=out, stderr=err)

print("Done! Find the report and plots in the results directory!")
