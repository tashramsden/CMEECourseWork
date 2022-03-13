# Week 23 - Machine Learning

**Topics covered this week:** Unsupervised methods (PCA, PCoA and NMDS; clustering: hierarchical, k-means and model-based); supervised methods (regression trees, LAR and lasso, support vector machines); artificial neural networks; convolutional neural networks and recurrent neural networks.

Day-long hackathon on Friday with the aim to obtain data, design an artificial neural network and optimise it in order to classify images of insects into their orders; see our [group git page](https://github.com/eamonnmurphy/mlhackathon).

Project structure: In the code directory there are several R scripts exploring methods in machine learning (described below). There are also several data files in the data directory which are used in some of the practical exercises.

Languages: R (version 4.1.2).

Required R packages: `mvtnorm`, `splits`, `mclust`, `vegan`, `raster`, `corrplot`, `cluster`, `tree`, `randomForest`, `gbm`, `lars`, `e1071`, `neuralnet`, `NeuralNetTools`, `keras`, `tensorflow` 
(Note: Installing tensorflow and keras can be a pain! (see first answer here for fix: https://stackoverflow.com/questions/63220597/python-in-r-error-could-not-find-a-python-environment-for-usr-bin-python)).


## Code Files:

* [**day1_unsupervised.R**](code/day1_unsupervised.R) and [**prac1_unsupervised.R**](code/prac1_unsupervised.R)
  * Scripts exploring unsupervised methods including:
    * Principle component analysis (PCA)
    * Principle co-ordinate analysis (PCoA)
    * Non-metric multidimensional scale (NMDS)
    * Hierarchical clustering
    * K-means clustering 
    * Model-based clustering

* [**day2_supervised.R**](code/day2_supervised.R) and [**prac2_supervised.R**](code/prac2_supervised.R)
  * Scripts exploring supervised methods including:
    * Regression trees (bagged, random forest and boosted variations)
    * Least angle regression (LAR) and lasso
    * Support vector machines (SVM)

* [**day3_artifical_neural_networks.R**](code/day3_artificial_neural_networks.R)
  * Designing artificial neural networks, using `keras`.

* [**day4_convolutional_neural_nets.R**](code/day4_convolutional_neural_nets) and [**prac4_neural_networks.R**](code/prac4_neural_networks.R)
  * Designing and fitting different neural networks including convolutional and recurrent neural nets for image classification.

* Day 5: hackathon (see our [group git page](https://github.com/eamonnmurphy/mlhackathon)).

## Author

Tash Ramsden | tash.ramsden21@imperial.ac.uk
