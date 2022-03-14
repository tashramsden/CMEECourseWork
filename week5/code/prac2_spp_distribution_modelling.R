#### Species Distribution Modelling ----

# https://github.com/davidorme/Masters_GIS

rm(list=ls())

# HACK: preventing errors later... WILL get lots of warnings but never mind!
library(lwgeom)
sf_use_s2(FALSE)

## packages ----
# there are lots on CRAN for doin spp dist
# focussing on dismo here - bit old but single framework for diff models and nice vignette

# install.packages('raster') # Core raster GIS data package
# install.packages('sf') # Core vector GIS data package
# install.packages('sp') # Another core vector GIS package
# install.packages('dismo') # Species Distribution Modelling
# install.packages('rgdal') # Interface to the Geospatial Data Abstraction Library

library(sp)
library(rgdal)
library(raster)
library(sf)
library(dismo)

## Intro ----
# We will be using R to characterise a selected species environmental 
# requirements under present day climatic conditions and then projecting the 
# availability of suitable climatic conditions into the future. This 
# information will then be used to analyse projected range changes due to
# climate change. During this process we will analyse the performance of 
# species distribution models and the impacts of threshold choice, variable 
# selection and data availability on model quality.


## Data preparation ----

# 2 main inputs for SDM:
# set of points describing locations where spp known to be
# set of env raster layers - variables to characterise spp env niche

## a. Focal spp distribution ----

# Mountain tapir (Tapirus pinchaque)
# fairly narrow distribution
# 2 distribution data sources:
# 1. IUCN Red List - good source of polygon spp ranges - usually expert drawn 
# maps (interpretations of sighting data and local info)
# 2. GBIF database - point obs - v important to be critical of point data 
# and carefully clean it - description of this here:
vignette('sdm')  

# view both kinds of data:


# IUCN - single MULTIPOLYGON feature showing discontinuous sections of spp range
# many feature attributes

tapir_IUCN <- st_read('../data/iucn_mountain_tapir/data_0.shp')
print(tapir_IUCN)


# GBIF data is a table of observations, some of which include coordinates. One thing that GBIF does is to publish a DOI for every download, to make it easy to track particular data use. This one is https://doi.org/10.15468/dl.t2bkzx.

# NOTE: although GBIF files have .csv - are actually TAB DELIMITED so use read.delim()
# lots of text, need to use stringsAsFactors=FALSE
# need to remove rows w no coords

# Load the data frame
tapir_GBIF <- read.delim('../data/gbif_mountain_tapir.csv', 
                         stringsAsFactors=FALSE)
# Drop rows with missing coordinates
tapir_GBIF <- subset(tapir_GBIF, ! is.na(decimalLatitude) | ! is.na(decimalLongitude))
# Convert to an sf object 
tapir_GBIF <- st_as_sf(tapir_GBIF, coords=c('decimalLongitude', 'decimalLatitude'))
st_crs(tapir_GBIF) <- 4326
print(tapir_GBIF)


# now superimpose these 2 datasets so they ~broadly~ agree
# no obvious problems that require data cleaning

# Load some (coarse) country background data
ne110 <- st_read('../data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp')

# Create a modelling extent for plotting and cropping the global data.
model_extent <- extent(c(-85,-70,-5,12))

# Plot the species data over a basemap
plot(st_geometry(ne110), xlim=model_extent[1:2], ylim=model_extent[3:4], 
     bg='lightblue', col='ivory')
plot(st_geometry(tapir_IUCN), add=TRUE, col='grey', border=NA)
plot(st_geometry(tapir_GBIF), add=TRUE, col='red', pch=4, cex=0.6)
box()


## b. Predictor variables ----

# going to use climatic variables to describe env, in particular the BIOCLIM 
# variables - based on single temp and precip values - in 19 combos that thought 
# to capture more bio relevant aspects of climate: https://www.worldclim.org/data/bioclim.html

# use getData
# data consist of stack of 19 BIOCLIM vars at 10 arc-minute resolution (1/6th degree)
# Load the data
bioclim_hist <- getData('worldclim', var='bio', res=10, path='../data')
bioclim_2050 <- getData('CMIP5', var='bio', res=10, rcp=60, model='HD', 
                        year=50, path='../data')

# Relabel the future variables to match the historical ones
names(bioclim_2050) <- names(bioclim_hist)

# Look at the data structure
print(bioclim_hist)

# these 2 datasets contain HISTORICAL climate data (1970-2000)
# and PROJECTED FUTURE climate for 2050 taken from Hadley model using RCP 6.0
# NOTE: this is CMIP5 data -considered outdated (but easy to load!)
# both datasets from http://www.worldclim.org

# compare BIO 1 (mean annual temp) between the 2 datasets:

par(mfrow=c(3,1), mar=c(1,1,1,1))
# Create a shared colour scheme
breaks <- seq(-300, 350, by=20)
cols <- hcl.colors(length(breaks) - 1)
# Plot the historical and projected data
plot(bioclim_hist[[1]], breaks=breaks, col=cols)
plot(bioclim_2050[[1]], breaks=breaks, col=cols)
# Plot the temperature difference
plot(bioclim_2050[[1]] - bioclim_hist[[1]], col=hcl.colors(20, palette='Inferno'))

# immediately crop env data down to SENSIBLE modelling region
# # sensible hard to define...may change when see model outputs
# for now use small spatial subset for quick running!

# Reduce the global maps down to the species' range
bioclim_hist_local <- crop(bioclim_hist, model_extent)
bioclim_2050_local <- crop(bioclim_2050, model_extent)


## c. Pseudo-absence data ----

# many methods require absence data (either for fitting/evaluating performance)
# rarely have true absence data (only from exhaustive studies) 
# usually just presence data
# modelling commonly uses pseudo-absence data or background locations
# background data might be sampled completely at random, where pseudo-absence 
# makes some attempt to pick locations that are somehow separated from 
# presence observations

# dismo package has randomPoints() for selecting background data

# useful - works directly w the env layers to pick points representing cells
# avoids getting duplicate points in the same cells
# need to provide a mask layer that shows which cells are valid choices
# can exclude cells that contain obs locations by setting p to use the coords 
# of the obs locations

# Create a simple land mask
land <- bioclim_hist_local[[1]] >= 0
# How many points to create? We'll use the same as number of observations
n_pseudo <- nrow(tapir_GBIF)
# Sample the points
pseudo_dismo <- randomPoints(mask=land, n=n_pseudo, p=st_coordinates(tapir_GBIF))
# Convert this data into an sf object, for consistency with the
# next example.
pseudo_dismo <- st_as_sf(data.frame(pseudo_dismo), coords=c('x','y'), crs=4326)


# can also use GIS to do something a little more sophisticated. This isn’t necessarily the best choice here, but is an example of how to do something more structured. The aim here is to pick points that are within about 100 km of observed points, but not closer than 20km. We are going to cheat and use degrees (1° is very roughly 100 km at the equator), but in practice it would be better to reproject the data and work with real distance units.
# Create buffers around the observed points
nearby <- st_buffer(tapir_GBIF, dist=1)
too_close <- st_buffer(tapir_GBIF, dist=0.2)
# merge those buffers
nearby <- st_union(nearby)
too_close <- st_union(too_close)
# Find the area that is nearby but _not_ too close
nearby <- st_difference(nearby, too_close)
# Get some points within that feature in an sf dataframe

pseudo_nearby <- st_as_sf(st_sample(nearby, n_pseudo))

# plot those 2 points side by side for comparison
par(mfrow=c(1,2), mar=c(1,1,1,1))
# Random points on land
plot(land, col='grey', legend=FALSE)
plot(st_geometry(tapir_GBIF), add=TRUE, col='red')
plot(pseudo_dismo, add=TRUE)
# Random points within ~ 100 km but not closer than ~ 20 km
plot(land, col='grey', legend=FALSE)
plot(st_geometry(tapir_GBIF), add=TRUE, col='red')
plot(pseudo_nearby, add=TRUE)

# useful for detail on pseudo absences: Barbet‐Massin, M., Jiguet, F., Albert, C.H. and Thuiller, W. (2012), Selecting pseudo‐absences for species distribution models: how, where and how many?. Methods in Ecology and Evolution, 3: 327-338.


## d. Testing and training dataset ----

# important part of modelling - keep separate data for TRAINING the model
# (fitting the model to data) and for TESTING (checking model performance)
# here, use a 20:80 split (retain 20% for testing)

# Use kfold to add labels to the data, splitting it into 5 parts
tapir_GBIF$kfold <- kfold(tapir_GBIF, k=5)
# Do the same for the pseudo-random points
pseudo_dismo$kfold <- kfold(pseudo_dismo, k=5)
pseudo_nearby$kfold <- kfold(pseudo_nearby, k=5)

# important concept in test and training is cross validation:
# model fitted and tested multiple times using diff subsets of the data
# to check model performance not dependent on one specific partition of the data

# common approach is K-FOLD cross-validation:
# splits data into k partitions and uses each partition in turn as the test data

# alternative approaches to model evaluation: Warren, DL, Matzke, NJ, Iglesias, TL. Evaluating presence‐only species distribution models with discrimination accuracy is uninformative for many applications. J Biogeogr. 2020; 47: 167– 180.


## Species Distribution Modelling ----

## a. The BIOCLIM model ----

# one of earliest SDM is BIOCLIM: Nix, H.A., 1986. A biogeographic analysis of Australian elapid snakes. In: Atlas of Elapid Snakes of Australia. (Ed.) R. Longmore, pp. 4-15. Australian Flora and Fauna Series Number 7. Australian Government Publishing Service: Canberra.
# not v good method - but possible to fit w presence only data
# samples env layers at spp locations
# a cell in the wider map gets a score based on how close to the spp median 
# value for each layer it is
# often called a BIOCLIMATIC ENVELOPE approach
# BIOCLIM variables loaded earlier were designed to be used w this BIOCLIM algorithm

## a.1 Fitting the model ----

# need env layers and a matrix of xy coords for training data showing where spp observed
# st_coordinates() useful for extracting point coords 

# Get the coordinates of 80% of the data for training 
train_locs <- st_coordinates(subset(tapir_GBIF, kfold != 1))
# Fit the model
bioclim_model <- bioclim(bioclim_hist_local, train_locs)

# plot model output to show envelopes 
# p used to show climatic envelope that contains a certain proportion of the data
# a and b arguments set which layers in the env data are compared
par(mfrow=c(1,2), mar=c(3,3,1,1))
plot(bioclim_model, a=1, b=2, p=0.9)
plot(bioclim_model, a=1, b=5, p=0.9)
# NOTE: in second plot the 2 vars (mean annual temp BIO1 and max temp of 
# warmest month BIO5) are extremely strongly correlated
# prob not an issue for this method but in lots of models V BAD to have strongly
# correlated expl vars - multicollinearity - can cause big stats issues


## a.2 Model predictions ----

# now can use model params to predict the bioclim score for the whole map
# NOTE: lots of the map has score of 0: none of the environmental variables in 
# these cells fall within the range seen in the occupied cells

bioclim_pred <- predict(bioclim_hist_local, bioclim_model)
# Create a copy removing zero scores to focus on within envelope locations
bioclim_non_zero <- bioclim_pred
bioclim_non_zero[bioclim_non_zero == 0] <- NA
par(mfrow=c(1,1))
plot(land, col='grey', legend=FALSE)
plot(bioclim_non_zero, col=hcl.colors(20, palette='Blue-Red'), add=TRUE)


## a.3 Model evaluation ----

# evaluate w retained test data
# NOTE: do have to provide absence data: all of the standard performance metrics
# come from a confusion matrix, which requires false and true negatives.

# The output of evaluate gives us some key statistics, including AUC.

test_locs <- st_coordinates(subset(tapir_GBIF, kfold == 1))
test_pseudo <- st_coordinates(subset(pseudo_nearby, kfold == 1))
bioclim_eval <- evaluate(p=test_locs, a=test_pseudo, model=bioclim_model, 
                         x=bioclim_hist_local)
print(bioclim_eval)

# and create standard plots
# ROC curve and how kappa changes as threshold used on the model predictions varies
# threshold function allows us to find an optimal threshold for a particular 
# measure of performance: here we find the threshold that gives the best kappa.

par(mfrow=c(1,2))
# Plot the ROC curve
plot(bioclim_eval, 'ROC', type='l')
# Find the maximum kappa and show how kappa changes with the model threshold
max_kappa <- threshold(bioclim_eval, stat='kappa')
plot(bioclim_eval, 'kappa', type='l')
abline(v=max_kappa, lty=2, col='blue')


## a.4 Species distribution ----

# gives us all the information we need to make a prediction about the 
# species distribution:

# Apply the threshold to the model predictions
tapir_range <- bioclim_pred >= max_kappa
par(mfrow=c(1,1))
plot(tapir_range, legend=FALSE, col=c('grey','red'))
plot(st_geometry(tapir_GBIF), add=TRUE, pch=4, col='#00000022')

## a.5 Future predictions ----

# predicted distribution of the Mountain Tapir in 2050 and the predicted 
# range change 

# Predict from the same model but using the future data
bioclim_pred_2050 <- predict(bioclim_2050_local, bioclim_model)
# Apply the same threshold
tapir_range_2050 <- bioclim_pred_2050 >= max_kappa

par(mfrow=c(1,3))
plot(tapir_range, legend=FALSE, col=c('grey','red'))
plot(tapir_range_2050, legend=FALSE, col=c('grey','red'))

# This is a bit of a hack - adding 2 * hist + 2050 gives:
# 0 + 0 - present in neither model
# 0 + 1 - only in future
# 2 + 0 - only in hist
# 2 + 1 - in both
tapir_change <- 2 * (tapir_range) + tapir_range_2050
cols <- c('lightgrey', 'blue', 'red', 'grey30')
plot(tapir_change, col=cols, legend=FALSE)
legend('topleft', fill=cols, legend=c('Absent','Future','Historical', 'Both'), bg='white')


## b. Generalised Linear Model (GLM) ----

# kind of regression that allows us to model presence/absence as a binary 
# response variable more appropriately

## b.1 Data restructuring ----

# needs model formula
# need to restructure our data into a data frame of species presence/absence 
# and the environmental values observed at the locations of those observations

# need to combine tapir_GBIF and pseudo_nearby into a single data frame:

# Create a single sf object holding presence and pseudo-absence data.
# - reduce the GBIF data and pseudo-absence to just kfold and a 
# presence-absence value
present <- subset(tapir_GBIF, select='kfold')
present$pa <- 1
absent <- pseudo_nearby
absent$pa <- 0
# - rename the geometry column of absent to match so we can stack them together.
names(absent) <- c('geometry','kfold','pa')
st_geometry(absent) <- 'geometry'
# - stack the two dataframes
pa_data <- rbind(present, absent)
head(pa_data)

# extract env values for each of these points and add into the data frame
envt_data <- extract(bioclim_hist_local, pa_data)
pa_data <- cbind(pa_data, envt_data)
head(pa_data)


## b.2 Fitting the model ----

# using model formula
# family=binomial(link = "logit") allows us to model binary data better

# 3 key things:

# 1. number of bioclim variables has been reduced from the full set of 19 
# down to five. because of the issue of multicollinearity - some pairs of 
# bioclim variables are very strongly correlated. The five variables are 
# chosen to represent related groups of variables (SEE "Reducing the set of variables" SECTION AT THE END TO SEE HOW - BUT DON'T WORRY ABOUT IT!)

# 2. subset argument is used to hold back one of the kfold partitions for testing

# 3. predict method for a GLM needs an extra argument (type='response') to make 
# it give us predictions as the probability of species occurrence
# default model prediction output (?predict.glm) is on the scale of the linear 
# predictors

# model fitting:
glm_model <- glm(pa ~ bio2 + bio4 + bio3 + bio1 + bio12, data=pa_data, 
                 family=binomial(link = "logit"),
                 subset=kfold != 1)
# GLM gives significance of diff vars (simialr to lm summary)
# Look at the variable significances - which are important
summary(glm_model)

# look at response plots: show how the probability of a species being present
# changes with a given variable - predictions for each var in turn - holding 
# all other vars at their median value
# Response plots
response(glm_model, fun=function(x, y, ...) predict(x, y, type='response', ...))


## b.3 Model predictions and evaluation ----

# same technique as before

# create prediction layer
glm_pred <- predict(bioclim_hist_local, glm_model, type='response')

# evaluate model using test data
# Extract the test presence and absence
test_present <- st_coordinates(subset(pa_data, pa == 1 & kfold == 1))
test_absent <- st_coordinates(subset(pa_data, pa == 0 & kfold == 1))
glm_eval <- evaluate(p=test_present, a=test_absent, model=glm_model, 
                     x=bioclim_hist_local)
print(glm_eval)

# find max kappa threshold 
# more complicated than before: the threshold we get is again on the scale 
# of the linear predictor. For this kind of GLM, we can use plogis to convert back.
max_kappa <- plogis(threshold(glm_eval, stat='kappa'))
print(max_kappa)

# model performance plots
par(mfrow=c(1,2))
# ROC curve and kappa by model threshold
plot(glm_eval, 'ROC', type='l')
plot(glm_eval, 'kappa', type='l')
abline(v=max_kappa, lty=2, col='blue')


## b.4 Species distribution ----

# use threshold to convert model outputs into predicted spp dist map and compare
# current suitability to future
par(mfrow=c(2,2))
# Modelled probability
plot(glm_pred, col=hcl.colors(20, 'Blue-Red'))
# Threshold map
glm_map <- glm_pred >= max_kappa
plot(glm_map, legend=FALSE, col=c('grey','red'))
# Future predictions
glm_pred_2050 <- predict(bioclim_2050_local, glm_model, type='response')
plot(glm_pred_2050, col=hcl.colors(20, 'Blue-Red'))
# Threshold map
glm_map_2050 <- glm_pred_2050 >= max_kappa
plot(glm_map_2050, legend=FALSE, col=c('grey','red'))

# simple way to describe the modelled changes is simply to look at a table 
# of the pair of model predictions:
table(values(glm_map), values(glm_map_2050), dnn=c('hist', '2050'))

# This GLM predicts a 31% loss of existing range for this species by 2050 and 
# almost no expansion into new areas.


## Sandbox - things to try w SDMs ----

## a. Modelling a diff spp ----
# return to this later for practice!!!


## b. Does background choice matter? ----

# examples above have used the spatially structured background data. 
# Does this matter? The plot below compares the GLM fitted with the
# structured background to the wider sample created using randomPoints.

# 1. Create the new dataset
present <- subset(tapir_GBIF, select='kfold')
present$pa <- 1
absent <- pseudo_dismo
absent$pa <- 0
# - rename the geometry column of absent to match so we can stack them together.
names(absent) <- c('geometry','kfold','pa')
st_geometry(absent) <- 'geometry'
# - stack the two dataframes
pa_data_bg2 <- rbind(present, absent)
# - Add the envt.
envt_data <- extract(bioclim_hist_local, pa_data_bg2)
pa_data_bg2 <- cbind(pa_data_bg2, envt_data)

# 2. Fit the model
glm_model_bg2 <-glm(pa ~ bio2 + bio4 + bio3 + bio1 + bio12, data=pa_data_bg2, 
                    family=binomial(link = "logit"),
                    subset=kfold != 1)

# 3. New predictions
glm_pred_bg2 <- predict(bioclim_hist_local, glm_model_bg2, type='response')

# 4. Plot modelled probability using the same colour scheme and using
# axis args to keep a nice simple axis on the legend
par(mfrow=c(1,3))
bks <- seq(0, 1, by=0.01)
cols <- hcl.colors(100, 'Blue-Red')
plot(glm_pred, col=cols, breaks=bks, main='Buffered Background',
     axis.args=list(at=c(0, 0.5, 1)))
plot(glm_pred_bg2, col=cols, breaks=bks, main='Extent Background',
     axis.args=list(at=c(0, 0.5, 1)))
plot(glm_pred - glm_pred_bg2, col= hcl.colors(100), main='Difference')


## c. Cross validation ----

# models above always use the same partitions for testing and training. A better
# approach is to perform k-fold cross validation to check that the model behaviour 
# is consistent across different partitions. This allows you to compare the 
# performance of models taking into account the arbitrary structure of the partitioning

# here using random partition of data, see this recent paper arguing for 
# spatially structured approach: Valavi, R, Elith, J, Lahoz‐Monfort, JJ, Guillera‐Arroita, G. blockCV: An r package for generating spatially or environmentally separated folds for k‐fold cross‐validation of species distribution models. Methods Ecol Evol. 2019; 10: 225– 232.

# 1. A way to get the ROC data from the output of evaluate:
# - this is not obvious because dismo uses a different coding approach (S4 methods) 
# that is a bit more obscure. Similarly, you need to know that to get the 
# AUC value, you need to use glm_eval@auc.
get_roc_data <- function(eval){
    #' get_roc_data
    #' 
    #' This is a function to return a dataframe of true positive
    #' rate and false positive rate from a dismo evalulate output
    #' 
    #' @param eval An object create by `evaluate` (S4 class ModelEvaluation)
    
    roc <- data.frame(FPR = eval@FPR, TPR = eval@TPR)
    return(roc)
}

# 2. want each model evaluation to be carried out using the same threshold 
# breakpoints, otherwise it is difficult to align the outputs of the different
# partitions. We can give evaluate a set of breakpoints but - for the GLM - 
# the breakpoints are on that mysterious scale of the linear predictors. The 
# following approach allows you to set those breakpoints.
# Take a sequence of probability values from 0 to 1
thresholds <- seq(0, 1, by=0.01)
# Convert to the default scale for a binomial GLM
thresholds <- qlogis(thresholds)
# Use in evaluate
eval <- evaluate(p=test_present, a=test_absent, model=glm_model, 
                 x=bioclim_hist_local, tr=thresholds)

# Make some objects to store the data
tpr_all <- matrix(ncol=5, nrow=length(thresholds))
fpr_all <- matrix(ncol=5, nrow=length(thresholds))
auc <- numeric(length=5)

# Loop over the values 1 to 5
for (test_partition in 1:5) {
    
    # Fit the model, holding back this test partition
    model <- glm(pa ~ bio2 + bio4 + bio3 + bio1 + bio12, data=pa_data, 
                 family=binomial(link = "logit"),
                 subset=kfold != test_partition)
    
    # Evaluate the model using the retained partition
    test_present <- st_coordinates(subset(pa_data, pa == 1 & kfold == test_partition))
    test_absent <- st_coordinates(subset(pa_data, pa == 0 & kfold == test_partition))
    eval <- evaluate(p=test_present, a=test_absent, model=glm_model, 
                     x=bioclim_hist_local, tr=thresholds)
    
    # Store the data
    auc[test_partition] <- eval@auc
    roc <- get_roc_data(eval)
    tpr_all[,test_partition] <- roc$TPR
    fpr_all[,test_partition] <- roc$FPR
}

# Create a blank plot to showing the mean ROC and the individual traces
par(mfrow=c(1,1))
plot(rowMeans(fpr_all), rowMeans(tpr_all), type='n')

# Add the individual lines
for (test_partition in 1:5) {
    lines(fpr_all[, test_partition], tpr_all[, test_partition], col='grey')
}

# Add the mean line
lines(rowMeans(fpr_all), rowMeans(tpr_all))

print(auc)
print(mean(auc))


## Reducing the set of variables (NOT IMPORTANT) ----
# using clustering to find groups to include in GLM above (don't worry about this!)

# We can use the values from the environmental data in a cluster algorithm.
# This is a statistical process that groups sets of values by their similarity
# and here we are using the local raster data (to get a good local sample of the 
# data correlation) to perform that clustering.
clust_data <- values(bioclim_hist_local)
clust_data <- na.omit(clust_data)
# Scale and center the data
clust_data <- scale(clust_data)
# Transpose the data matrix to give variables as rows
clust_data <- t(clust_data)
# Find the distance between variables and cluster
clust_dist <- dist(clust_data)
clust_output <- hclust(clust_dist)
plot(clust_output)
# And then pick one from each of five blocks - haphazardly.
rect.hclust(clust_output, k=5)
