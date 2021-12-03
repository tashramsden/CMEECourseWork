# MiniProject

**About**: A fully reproducible computing project aiming to determine a best fitting model for a large dataset of bacterial growth curves, as per 
[The Computing Miniproject](https://mhasoba.github.io/TheMulQuaBio/notebooks/Appendix-MiniProj.html#) guidelines.

**Languages**: R (version 4.1.2), Python3 (version 3.10.0), Bash (version 5.0.17(1)), LaTeX (pdfTeX version 3.14159265-2.6-1.40.20).

**Required R packages**: `dplyr`, `minpack.lm`, `rollRegres`, `ggplot2`.

**Required Python package**: `subprocess`.

**Package uses**:
  * `dplyr` used throughout R scripts for ease of use with data frame manipulation.
  * `minpack.lm` used to fit non-linear models. Implements the Levenberg-Marquart optimization algorithm which is more robust
  than the Gauss-Newton algorithm implemented in the base-R nls() function.
  * `rollRegres` used to fit a rolling regression through all datasets to improve estimation of the exponential growth rate parameter.
  * `ggplot2` used for generating final plots to be included in the report.
  * Python's `subprocess` used to run all project scripts in the final [**run_MiniProject.py**](code/run_MiniProject.py) script; outputs/errors were captured in files.

**LaTeX packages**: `graphicx`, `caption`, `subcaption`, `geometry`, `helvet`, `setspace`, `lineno`, `natbib`, `authblk`.

**Project strcuture**: Code directory contains R scripts for data prepping as well as model fitting, plotting and analysis. 
LaTeX scripts and accompanying bibliography and compiling script are also in the code directory, as well as a python script which runs all others. 
The data driectory contains the csv file of bacterial growth data and an accompanying meta data file: 
[LogisticGrowthData.csv](data/LogisticGrowthData.csv) and [LogisticMetaData.csv](LogisticMetaData.csv). There is also a run_logs directory within 
the data directory which will be filled with subprocess outputs from running the python script. 
The results directory will be populated upon running the project, there is a subdirectory called supplementary which will 
contain figures for the supplementary section of the report.

## Code Files:

* [**DataPrep.R**](code/DataPrep.R)
  * Reads the data files [LogisticGrowthData.csv](data/LogisticGrowthData.csv) and [LogisticMetaData.csv](LogisticMetaData.csv).
  * Performs data wrangling and saves the output data as `modified_growth_data.csv` in the data directory.

* [**ModelFit.R**](code/ModelFit.R)
  * Main R script for fitting models to all datasets.
  * Reads `modified_growth_data.csv`, outputs `model_params.csv`, `selection_stats_log_space.csv` and `selection_stats_not_log_space.csv` to data directory.
  * Uses functions defined in the 4 following R scripts:

  * [**DefineModels.R**](code/DefineModels.R)
    * Contains the 3 non-linear model functions; logistic, modified Gompertz and Baranyi.

  * [**ParamSampling.R**](code/ParamSampling.R)
    * Contains 3 functions which calculate new starting values for the parameters of the 3 non-linear models, 
    fits these models, and saves the start values along with an AICc score.

  * [**TryFinalFits.R**](code/TryFinalFits.R)
    * 3 functions for the last fit of the non-linear models to each dataset. 
    Fits the models with the best starting values, catches any errors if model fitting unsuccessful.
  
  * [**GetStats.R**](code/GetStats.R)
    * Calculates the selection criteria for each model fit. Functions which calculate these criteria in 
    log space and in not-log space for the log models and not-log models.
  
* [**PlotAnalyse.R**](code/PlotAnalyse.R)
  * Reads the csv files created by the ModelFit.R script and produces final plots for the report. 
  Calculates counts of best models according to AICc and BIC and Akaike and Schwarz weights.
 
* [**BacterialGrowthModelling.tex**](code/BacterialGrowthModelling.tex)
  * Main report script: "Mechanistic Models Outperform Phenomenological Models for Predicting Bacterial Growth".
 
* [**Supplementary.tex**](code/Supplementary.tex)
  * Supplementary figures material, will be concatenated onto the end of the main report.
  
* [**BacteriaBiblio.bib**](code/BacteriaBiblio.bib)
  * Bibliography for the report.

* [**CompileReport.sh**](code/CompileReport.sh)
  * Compiles the LaTeX documents with bibliography. Saves the output pdf to the results directory.
  
* [**run_MiniProject.py**](code/run_MiniProject.py)
  * Runs the R scripts: DataPrep.R, ModelFit.R and PlotAnalyse.R before running the CompileReport.sh bash script.


## Author

Tash Ramsden | tash.ramsden21@imperial.ac.uk
