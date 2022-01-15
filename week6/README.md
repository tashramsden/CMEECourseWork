# Week 6

**Topics covered this week:** Genomics and Bioinformatics

Languages: R (version 4.1.2 "Bird Hippie")

Project strcuture: 4 R scripts exploring different aspects of genomics and bioinformatics; these scripts manipulate and analyse genomics data from the data directory. The results directory will be populated by running the code files.

Required R packages: `dplyr`, `ggplot2`, `vegan`.

## Code Files:

* [**prac1_allele_genotype_freq.R**](code/prac1_allele_genotype_freq.R)
  * Allele and genotype frequencies: manually calculating allele and genotype frequencies, and testing for Hardy Weinberg equilibrium in R. Saves summary data `bear_polymorphisms.csv` to the results directory.
  * Required packages: dplyr, ggplot2

* [**prac2_drift_mut_divergence.R**](code/prac2_drift_mut_divergence.R)
  * Genetic drift, mutation and divergence: using the molecular clock concept to calculate time since divergence in gecko species.
  * Required packages: dplyr

* [**prac3_coalescence.R**](code/prac3_coalescence.R)
  * Coalescence theory: estimating effective population size of killer whale populations using Watterson's and Tajima's estimators; calculating and plotting site frequency spectrum.

* [**prac4_demography.R**](code/prac4_demography.R)
  * Population subdivision and demographic inferences: inferring population structure and assessing isolation by distance in sea turtle populations using FST, a PCA and a dendogram.
  * Required packages: vegan


## Author

Tash Ramsden | tash.ramsden21@imperial.ac.uk
