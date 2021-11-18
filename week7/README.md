# Week 7

**Topics covered this week:** [Biological Computing in Python II](https://mhasoba.github.io/TheMulQuaBio/notebooks/06-Python_II.html#) (numpy, scipy, arrays, matrices, profiling, vectorization)

Languages: Python3 (version 3.10)

Project strcuture: 6 python script files and an R script in the code directory; the reuslts directory will be populated by running these.


## Code Files:

* [**LV1.py**](code/LV1.py)
  * Runs a Lotka-Volterra model and produces two plots of consumer-resource density:
  `LV_model.pdf` and `LV_model2.pdf` showing densities over time and plotted against eachother respectively.

* [**profileme.py**](code/profileme.py)
  * A script for exploring profiling; try running `run -p profileme.py` from ipython3.

* [**profileme2.py**](code/profileme2.py)
  * Another python script to compare to the first `profileme.py`.

* [**timeitme.py**](code/timeitme.py)
  * Imports some functions from the profileme scripts; for exploring profiling using the timeit and time modules. 

* [**oaks_debugme.py**](code/oaks_debugme.py)
  * A script that reads the csv file, `TestOaksData.csv`, from the data directory and determines whether tree species are oaks or not. Oak species are then written to a new csv, `JustOaksData.csv`, in the data directory.

* [**TestR.R**](code/TestR.R)
  * An R script that prints "Hello, this is R!".

* [**TestR.py**](code/TestR.py)
  * Using python subprocess to run `TestR.R` and save the outputs and any errors to files in the results directory.


## Author

Tash Ramsden | tash.ramsden21@imperial.ac.uk
