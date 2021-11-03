# Week 3

**Topics covered this week:** [Biological Computing in R](https://mhasoba.github.io/TheMulQuaBio/notebooks/07-R.html#) (variables, creating and manipulating data, importing and exporting data, functions, vectorization, errors and debugging). 
[Data Management and Visualization](https://mhasoba.github.io/TheMulQuaBio/notebooks/08-Data_R.html) (Data wrangling, data visualization, tidyverse and ggplot)

Languages: R (version 4.1.1), Shell, LaTeX

Project structure: 25 R script files in the code directory, 1 LaTeX .tex file and a shell script file (described below), some of these will manipulate files from the data directory. The results directory will be populated by running the R scripts, and some quick plots will be saved to the sandbox directory.

Required R packages: `ggplot2`, `tidyverse`, `maps` (see below for specific scripts with these requirements)

## Code Files:

* [**basic_io.R**](code/basic_io.R)
  * Basic script to read and write csv files; will read `trees.csv` from data directory and write `MyData.csv` to results.

* [**control_flow.R**](code/control_flow.R)
  * A simple script to experiment with if statements and loops.

* [**break.R**](code/break.R)
  * A short while loop to demonstrate the `break` statement in R.

* [**next.R**](code/next.R)
  * A quick for loop demonstrating the `next` statement in R.

* [**boilerplate.R**](code/boilerplate.R)
  * Simple script containing a function that prints the class of 2 variables passed to it.

* [**R_conditionals.R**](code/R_conditionals.R)
  * Contains three functions with conditional statements; functions to check if an interger is even, a power of 2, or a prime.

* [**TreeHeight.R**](code/TreeHeight.R)
  * Reads `trees.csv` from the data directory; calculates heights of trees given distance of each tree from its base and angle to its top, using the trigonometric formula; and saves these results to `TreeHts.csv` in the results directory.

* [**Vectorize1.R**](code/Vectorize1.R)
  * Compares the run-time of a vectorized function to a non-vectorized function.

* [**preallocate.R**](code/preallocate.R)
  * Compares run-time of a function using vector preallocation to a function without preallocation.

* [**apply1.R**](code/apply1.R)
  * Using R's `apply` function to "apply" R's inbuilt functions to a randomly generated matrix.

* [**apply2.R**](code/apply2.R)
  * Using R's `apply` function to "apply" a newly-defined function to a randomly generated matrix.

* [**sample.R**](code/sample.R)
  * Using `sample`, `lapply` and `sapply`: comparing run-times of functions with and without vectorization and preallocation.

* [**Ricker.R**](code/Ricker.R)
  * Runs the [Ricker model](https://cdnsciencepub.com/doi/abs/10.1139/f54-039) for 10 generations, saves the output plot `Ricker.pdf` to the sandbox directory.

* [**Vectorize2.R**](code/Vectorize2.R)
  * Compares the run-time of a stochastic Ricker model to the same model after vectorization.

* [**browse.R**](code/browse.R)
  * A script to demonstrate the use of `browser()` for debugging. 
  `browser()` function currently commented out, uncomment to test.
  In browser: use `n` to take single step, `c` to exit browser and continue, `Q` to exit browser and abort. 
  * A plot `Exponential_growth.pdf` will be save to the sandbox directory.

* [**try.R**](code/try.R)
  * Using `try()` to catch errors.
  Calculates a sample mean unless the sample size is too small, in which case an error message will be printed but the script will keep running.

* [**DataWrang.R**](code/DataWrang.R)
  * Data wrangling techniques using mostly base R: inspects and wrangles `PoundHillData.csv` and displays its metadata `PoundHillMetaData.csv`.
  * Requires `tidyverse`.

* [**DataWrangTidy.R**](code/DataWrangTidy.R)
  * Carrying out the same data wrangling as in [**DataWrang.R**](code/DataWrang.R) but using packages from `tidyverse`.
  * Requires `tidyverse`!

* [**PP_Dists.R**](code/PP_Dists.R)
  * Analysing the `EcolArchives-E089-51-D1.csv` dataset from the data directory. 
  * Produces plots of predator-prey distributions for different types of feeding interaction: `Pred_Subplots.pdf`, `Prey_Subplots.pdf` and `SizeRatio_Subplots.pdf` will be saved to the results directory, as well as `PP_Results.csv` whihc contains summary statistics.
  * Requires `ggplot2` and `tidyverse`.

* [**Girko.R**](code/Girko.R)
  * Runs a simulation and produces a plot in the results directory called `Girko.pdf` to demonstrate Girko's cicular law.
  * Requires `ggplot2`.

* [**MyBars.R**](code/MyBars.R)
  * Exploring ggplot's geom_text for plot annotation; uses data from `Results.txt` (in the data directory); creates `MyBars.pdf` in the results directory.
  * Requires `ggplot2`.

* [**plotLin.R**](code/plotLin.R)
  * Using mathematical annotation on plot axes and within the plot area; creates `MyLinReg.pdf` in the results directory.
  * Requires `ggplot2`.

* [**PP_Regress.R**](code/PP_Regress.R)
  * Regression analyses and visualization of data from `EcolArchives-E089-51-D1.csv`. 
  * Creates `PP_Regress.pdf` and `PP_Regress_Results.csv`; these contain the visualization and results of linear regression analyses investigating the relationship between predator and prey mass for various predator lifestages and feeding interaction types.
  * Requires `ggplot2` and `tidyverse`.

* [**GPDD.R**](code/GPDD.R)
  * Mapping in R: using the `maps` package (required) to plot the Global Population Dynamics Database (GPDD) (`GPDDFiltered.RData` in data directory).
  * The plot `GPDD_map.pdf` will be saved to the sandbox.

* [**Florida_warming.R**](code/Florida_warming.R)
  * Analysing temperature data from Florida between 1901 and 2000 from `KeyWestAnnualMeanTemperature.RData` to answer the question: Is Florida getting warmer? 
  * Calculates the correlation coefficient between temperature and time; performs a permutation analysis to compare the distribution of random correlation coefficients generated to the observed coefficient; calculates a p-value based on this.
  * Produces the plots `florida_data.pdf` and `florida_coefs_hist.pdf`. These are saved to the results directory and will be used in [Florida_warming.tex](code/Florida_warming.tex) to produce a report.
  * Requires `ggplot2`.

* [**Florida_warming.tex**](code/Florida_warming.tex)
  * A LaTeX report of the results of `Florida_warming.R`.
  * Make sure that `Florida_warming.R` has been run before compiling.

* [**Compile_Florida.sh**](code/Compile_Florida.sh)
  * A shell script that compiles `Florida_warming.tex` into a pdf.
  * The script runs `Florida_warming.R` before compiling to ensure that the plots to be included in the report have been generated.


## Author

Tash Ramsden | tash.ramsden21@imperial.ac.uk
