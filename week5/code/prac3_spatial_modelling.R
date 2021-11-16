## Spatial modelling ----

# https://github.com/davidorme/Masters_GIS

# see for more detail: https://rspatial.org/raster/analysis/index.html

## packages ----

# install.packages('ncf')
# install.packages('raster')
# install.packages('sf')
# install.packages('SpatialPack') # For clifford test
# install.packages('spdep') # Spatial dependence
# install.packages('spatialreg')
# install.packages('nlme') # GLS
# install.packages('spgwr')
# install.packages('spmoran')

library(ncf)
library(sp)  # required for loading raster
library(raster)
library(sf)
library(spdep)
library(fastmatrix)
library(SpatialPack)
library(spatialreg)
library(nlme)  # masks getData from raster
library(spgwr)
library(spmoran)


## Dataset ----

# data from paper trying to predict what limits spp ranges:
# McInnes, L., Purvis, A., & Orme, C. D. L. (2009). Where do species’ geographic ranges stop and why? Landscape impermeability and the Afrotropical avifauna. Proceedings of the Royal Society Series B - Biological Sciences, 276(1670), 3063-3070. http://doi.org/10.1098/rspb.2009.0656
# won't be looking at range edges but will use 4 variables from the data

# all saved as GeoTIFF files, so we're starting w raster data
# cover the Afrotropics, projected in the Behrmann equal area projection
# cylindrical equal area projection w latitude of true scale of 30degrees
# means that distances on the projected map correspond to dists over the 
# surface of Earth at +/-30 degrees of latitude

# this is why strange res of data: 96.48627 km
# circumference of the Earth at ±30° - the length of the parallels at ±30° - 
# is ~ 34735.06 km and this resolution splits the map into 360 cells giving a 
# resolution comparable to a degree longitude at 30° N. Unlike a one degree 
# resolution grid, however, these grid cells all cover an equal area on the 
# ground (96.48627 x 96.48627 = 9309.6km^2, roughly the land area of Cyprus)

# variables for each grid cell:
# avian spp richness across Afrotropics
# mean elevation
# average annual temp
# average annual actual evapotranspiration (AET)


## a. Loading the data ----

# load the four variables from their TIFF files
rich <- raster('../data/avian_richness.tif')
aet <- raster('../data/mean_aet.tif')
temp <- raster('../data/mean_temp.tif')
elev <- raster('../data/elev.tif')

# quick explore:

# Look at the details of the richness data
print(rich)
# get dimensions, resolution, extent, coord ref sys, and
# range of data: between 10 and 667 spp per cell

# plot maps of the variables - think about spatial patterns
par(mfrow=c(2,2), mar=c(2,2,2,2))
plot(rich, main='Avian species richness')
plot(aet, main='Mean AET')
plot(temp, main='Mean annual temperature')
plot(elev, main='Elevation')

# explore further w hist()
# plot a histogram of the values in each raster, setting nice 'main' titles
hist(rich, main='Avian species richness')
hist(aet, main='Mean AET')
hist(temp, main='Mean annual temperature')
hist(elev, main='Elevation')


## b. Formatting the data as a dataframe ----

# currently rasters, some methods require data frame

# first use stack() to superimpose the 4 rasters into single object
# NOTE: only works because these all have same projection, resolution and extent
# Stack the data
data_stack <- stack(rich, aet, elev, temp)
print(data_stack)

# second sue as() to convert format
# cobvert to SpatialPixelDataFrame format from sp package
# useful because works v like df but identifies geometry as pixels
# NOTE: the names of the variables in the data frame have been set from the 
# original TIFF filenames, not our variable names in R
data_spdf <- as(data_stack, 'SpatialPixelsDataFrame')
summary(data_spdf)

# can aslo convert to sf object
# sf vs SpatialPixelDataFrame - differ in how geometry represented:
# SpatialPixelDataFrame: holds the data as values in PIXELS - so "knows" that 
# the data represent areas
# sf: default conversion holds the data as values at a point
data_sf <- st_as_sf(data_spdf)
print(data_sf)

# Affine transformation -- sidebar!!!
# transform this point data to polygon 
# each cell is dentre of a cell w sides of ~96km: can use those points to 
# define AFFINE TRANSFORMATIONS
# means we can create a template polygon that is the right size for the grid 
# cells, centred on zero and then use the points to move them all into the 
# right place.
# (polygon grid not actually great way to store data..)
# Get the cell resolution
cellsize <- res(rich)[[1]]
# Make the template polygon
template <- st_polygon(list(matrix(c(-1,-1,1,1,-1,-1,1,1,-1,-1), ncol=2) * cellsize / 2))
# Add each of the data points to the template
polygon_data <- lapply(data_sf$geometry, function(pt) template + pt)  # pass pt to function which will do template + pt where pt is each item indatasf$geometry
data_poly <- st_sf(avian_richness = data_sf$avian_richness, 
                   geometry=polygon_data)
plot(data_poly['avian_richness'])


## c. More data exploration ----
# now have data w spatial info and which match up the diff variables across locations
# plot SpatialPixelDataFrame vs sf versions:
# Plot the richness data as point data
dev.off()  # prevent error
# MAKE SURE plot window wide enough now otherwise get error
# lots of fiddly options below - just for consistent layout
layout(matrix(1:3, ncol=3), widths=c(5,5,1))
plot(data_spdf['avian_richness'], col=hcl.colors(20), what='image')
plot(data_sf['avian_richness'], key.pos=NULL, reset=FALSE, main='', 
     pal=hcl.colors, cex=0.7, pch=20)
plot(data_spdf['avian_richness'], col=hcl.colors(20), what='scale')


# plot the variables against each other
par(mfrow=c(1,3), mar=c(5,5,1,1))
# Now plot richness as a function of each environmental variable
plot(avian_richness ~ mean_aet, data=data_sf)
plot(avian_richness ~ mean_temp, data=data_sf)
plot(avian_richness ~ elev, data=data_sf)


## Correlations and spatial data ----

# corr coef between -1 and 1 showing how 2 variables co-vary
# once corr calculated, need to assess how strong it is GIVEN amount of data: 
# easy to have large r value in small dataset by chance

# corr coefs assume indpendence but not true for spatial data
# spatial autocorrelation

# easy way to remove non-independence - calculate significance tests as if you 
# had fewer data points, ie fewer d.f.
# now use this to compare standard measures of corr to spatially corrected ones:
# modified corr test - does not change corr statistic itself but calculates new
# effective sample size and uses this in calculating F stat

# Use the modified.ttest function from SpatialPack
temp_corr <- modified.ttest(x=data_sf$avian_richness, y=data_sf$mean_temp, 
                            coords=st_coordinates(data_sf))
print(temp_corr)

aet_corr <- modified.ttest(x=data_sf$avian_richness, y=data_sf$mean_aet, 
                           coords=st_coordinates(data_sf))
print(aet_corr)

elev_corr <- modified.ttest(x=data_sf$avian_richness, y=data_sf$elev, 
                            coords=st_coordinates(data_sf))
print(elev_corr)


# what about correlations between the expl variables?
temp_elev <- modified.ttest(x=data_sf$mean_temp, y=data_sf$elev, 
                            coords=st_coordinates(data_sf))
print(temp_elev)  # STRONG negative correlation between elevation and temp

temp_aet <- modified.ttest(x=data_sf$mean_aet, y=data_sf$mean_temp, 
                           coords=st_coordinates(data_sf))
print(temp_aet)  # no sig corr between temp and evotranspiration

elev_aet <- modified.ttest(x=data_sf$mean_aet, y=data_sf$elev, 
                           coords=st_coordinates(data_sf))
print(elev_aet)  # no sig corr here either


## Neighbourhoods ----

# neighbourhood of cells - defines set of other cells that are connected 
# to a focal cell, often w a given weight
# one way of providing spatial structure to the stat methods 

# spdep package provides a good guide (vignette('nb')) on the details, but we 
# will look at two functions: dnearneigh and knearneigh


## a. dnearneigh ----

# find which cells are within a given distance of a focal point
# can also put min distance to exclude nearby - but keep that 0 here
# w raster data where points are on grid, can use this function to generate 
# rook and queen move neighbours - to do, need to get res of raster and use to 
# set appropriate distances

# Give dnearneigh the coordinates of the points and the distances to use
rook <- dnearneigh(data_sf, d1=0, d2=cellsize)
queen <- dnearneigh(data_sf, d1=0, d2=sqrt(2) * cellsize)
# these v similar but queen has more cells linked as neighbours 
print(rook)
print(queen)
# using head func- can see row nums in df that are neighbours
head(rook)
head(queen)

# also look at num of neighbours in each set = CARDINALITY, store this in 
# data_sf df then visualise num of neighbours

# Store the neighbourhood cardinalities in data_sf
data_sf$card_rook <- card(rook)
data_sf$card_queen <- card(queen)
# Look at the count of rook and queen neighbours for each point
plot(data_sf[c('card_rook', 'card_queen')], key.pos=4)
# edges have fewer neighbours

# THIS DOES NOT LOOK RIGHT - should not get the stripes in central Africa w
# only 1/2 rook neighbours
# reason: using EXACTLY the resolution as the distance - minor rounding diffs
# can lead to distance-based measures going wrong!
# ALWAYS: plot data and check!!!

# FIX THE NEIGHBOURS
# simple solution: make distance v slightly larger
# Recreate the neighbour adding 1km to the distance
rook <- dnearneigh(data_sf, d1=0, d2=cellsize + 1)
queen <- dnearneigh(data_sf, d1=0, d2=sqrt(2) * cellsize + 1)
data_sf$card_rook <- card(rook)
data_sf$card_queen <- card(queen)
plot(data_sf[c('card_rook', 'card_queen')], key.pos=4)
# looks much better!!


## b. knearneigh ----

# NOTE: in details of rook and queen - some regions have no links
print(rook)

# these are points w no other point within the provided distance
# these are islands: São Tomé and Principe, Comoros, and Réunion
# (just so happens that Mauritius falls into 2 cells so has itself as a neighbour)

# knearneigh ensures all points have same num neighbours by looking for k 
# closest locations - end up w matrix
knn <- knearneigh(data_sf, k=8)
# We have to look at the `nn` values in `knn` to see the matrix of neighbours
head(knn$nn, n=3)


## c. Spatial weights ----

# neighbourhood functions give sets of neighbours, most spatial modelling 
# require WEIGHTS to be assigned to neighbours

# use nb2listw in spdep to take plain sets of neighbours and make them weighted 
# neighbour lists
# queen <- nb2listw(queen) ## ERROR
# this doesn't work because there are some locations w no neighbours, can:
# remove points w no neighbours (given these are islands offshore this is reasonable)
# use neighbourhood system in which they're not isolated, eg knearneigh -BUT
# ask self whether a modelt hat arbitrarily links offshore islands is realsitic!


## c.1 More data cleaning ----

# easy to use subset on data_sf to remove cells w 0 neighbours
# also should remove Mauritius (2 cells w cardinality of 1)
# but there is a coastal cell w a rook cardinality of 1 in north Madagascar - should include!
# so use GIS operation:
# Polygon covering Mauritius
mauritius <- st_polygon(list(matrix(c(5000, 6000, 6000, 5000, 5000,
                                      0, 0, -4000, -4000, 0), 
                                    ncol=2)))
mauritius <- st_sfc(mauritius, crs=crs(data_sf, asText=TRUE))
# Remove the island cells with zero neighbours
data_sf <- subset(data_sf, card_rook > 0)
# Remove Mauritius
data_sf <- st_difference(data_sf, mauritius)

# now recalculate neighbourhood objects to use this reduced set of loactions
rook <- dnearneigh(data_sf, d1=0, d2=cellsize + 1)
queen <- dnearneigh(data_sf, d1=0, d2=sqrt(2) * cellsize + 1)
data_sf$card_rook <- card(rook)
data_sf$card_queen <- card(queen)
knn <- knearneigh(data_sf, k=8)
print(rook)  # now none w 0 links


## c.2 Calculating weights ----

# several weighting styles - choice affects result stats:
# one option: binary weights (cells are connected or not) 
# here, use default ROW STANDARDISED (style="W") - means neighbours of a 
# location all get the same weight but the sum of neighbour weights for a
# location is always one

# NOTE: convert knn to same format (nb) as the rook and queen neighbourhoods first
rook <- nb2listw(rook, style='W')
queen <- nb2listw(queen, style='W')
knn <- nb2listw(knn2nb(knn), style='W')


## Spatial autocorrelation metrics ----

# can be measured globally and locally (note that global here means the whole 
# of the dataset and not the whole of the Earth)


## a. Global spatial autocorrelation ----

# several stats that quantify level of global spatial autocor
# test if dataset as a whole shows spatial autocor

# commonly used: Moran's I and Geary's C

# Moran's I - between -1 and 1: 
# 0 = no autocor, 
# -1 = strong negative autocor (rare case where nearby cells have unexpectedly differet values)
# 1 = nearby cells similar
# Geary's C - scale is the other way round (0 = strong auto corr, 1 = random)

moran_avian_richness <- moran.test(data_sf$avian_richness, rook)
print(moran_avian_richness)  # I nearly 1 - lots of spatial autocorr

geary_avian_richness <- geary.test(data_sf$avian_richness, rook)
print(geary_avian_richness)  # C nearly 0 - lots of spatial autocorr


# what about w different neighbourhood schemes?
moran_avian_richness2 <- moran.test(data_sf$avian_richness, queen)
print(moran_avian_richness2)  # v similar - a bit less auto corr

moran_avian_richness3 <- moran.test(data_sf$avian_richness, knn)
print(moran_avian_richness3)  # v similar as well - slightly less


# what about the other variables?
moran_temp <- moran.test(data_sf$mean_temp, rook)
print(moran_temp)  # lots of spatial autocorr

moran_aet <- moran.test(data_sf$mean_aet, rook)
print(moran_aet)  # v high autocorr

moran_elev <- moran.test(data_sf$elev, rook)
print(moran_elev)  # a bit less autocorr, still high


## b. Local spatial autocorrelation ----

# local indicators of spatial autocorr (LISA)
# show areas of stronger/weaker similarity (WHERE is the autocorr)

# calculate similar stat as global but only within the neighbourhood 
# around each cell - can map these values

# localmoran function returns matrix of values
# columns contain observed I, expected value, variance, z stats and p value
# rows contain location specific measures of each variable - can loads htem into data_sf
local_moran_avian_richness <- localmoran(data_sf$avian_richness, rook)
data_sf$local_moran_avian_richness <- local_moran_avian_richness[, 'Ii'] # Observed Moran's I
plot(data_sf['local_moran_avian_richness'], cex=0.6, pch=20)

# similar function localG just calculates a z stat showing strength of local autocorr
data_sf$local_g_avian_richness <- localG(data_sf$avian_richness, rook)
plot(data_sf['local_g_avian_richness'], cex=0.6, pch=20)

# avian richness shows strong positive spatial autocorr 
# particularly strong in mountains around Lake Victoria

# trying the same with diff neighbourhoods:
# queen
local_moran_avian_richness <- localmoran(data_sf$avian_richness, queen)
data_sf$local_moran_avian_richness <- local_moran_avian_richness[, 'Ii'] # Observed Moran's I
plot(data_sf['local_moran_avian_richness'], cex=0.6, pch=20)
# knn
local_moran_avian_richness <- localmoran(data_sf$avian_richness, knn)
data_sf$local_moran_avian_richness <- local_moran_avian_richness[, 'Ii'] # Observed Moran's I
plot(data_sf['local_moran_avian_richness'], cex=0.6, pch=20)


## Autoregressive models ----

# once set of neighbours defined, can fit spatial autoregressive (SAR) model
# stat model predicting value of response variables in a cell using the 
# predictor variables AND values of the response variable in neighbouring cells
# why they're called autoreg - fit response variable partly as a response to itself

# many forms: Kissling, W.D. and Carl, G. (2008), Spatial autocorrelation and the selection of simultaneous autoregressive models. Global Ecology and Biogeography, 17: 59-71. doi:10.1111/j.1466-8238.2007.00334.x

# Fit a simple linear model
simple_model <- lm(avian_richness ~ mean_aet + elev + mean_temp, data=data_sf)
summary(simple_model)

# Fit a spatial autoregressive model: this is much slower and can take minutes to calculate
sar_model <- errorsarlm(avian_richness ~ mean_aet + elev + mean_temp, 
                        data=data_sf, listw=queen)
summary(sar_model)


# can then look at the PREDICTIONS of these models
# extract predicted values for each point, add to df and then map them

# extract the predictions from the model into the spatial data frame
data_sf$simple_fit <- predict(simple_model)
data_sf$sar_fit <- predict(sar_model)
# Compare those two predictions with the data
par(mfrow=c(2,2))
plot(data_sf[c('avian_richness','simple_fit','sar_fit')], 
     pal=function(n) hcl.colors(n, pal='Blue-Red'))
# can see v clearly that the SAR model is much better at predicting than the simple lm


# also look at RESIDUALS (differences between prediction and actual values)
# to highlight where models aren't working well, manipulate the colours so 
# negative residuals blue, positive red

# extract the residuals from the model into the spatial data frame
data_sf$simple_resid <- residuals(simple_model)
data_sf$sar_resid <- residuals(sar_model)
plot(data_sf[c('avian_richness','simple_resid', 'sar_resid')], 
     pal=function(n) hcl.colors(n, pal='Blue-Red'), key.pos=4)
# residuals more randomly spread in SAR


## a. Correlograms ----

# another way to visualise spatial autocorr
# show how the corr within a variable changes as the distance between pairs of 
# points being compared increases

# need coords of the spatial data and the values of the variables at each point

# add the X and Y coordinates to the data frame
data_xy <- data.frame(st_coordinates(data_sf))
data_sf$x <- data_xy$X
data_sf$y <- data_xy$Y

# calculate a correlogram for avian richness: a slow process!
rich.correlog <- with(data_sf, correlog(x, y, avian_richness, 
                                        increment=cellsize, resamp=0))
par(mfrow=c(1,1))
plot(rich.correlog)

# explanation: take a focal point and then make pairs of the value of that point 
# and all other points. These pairs are assigned to bins based on how far apart 
# the points are: the increment is the width of those bins in map units. 
# Once we’ve done this for all points - yes, that is a lot of pairs! - we 
# calculate the correlations between the sets of pairs in each bin. Each bin 
# has a mean distance among the points in that class.

# get significance of the corrs at each dist by resampling the data
# BUT v slow - so here not doing any resampling (resamp=0)

# get more control on the plot by turning object into df

par(mfrow=c(1,2))
# convert three key variables into a data frame
rich.correlog <- data.frame(rich.correlog[1:3])
# plot the size of the distance bins
plot(n ~ mean.of.class, data=rich.correlog, type='o')
# plot a correlogram for shorter distances
plot(correlation ~ mean.of.class, data=rich.correlog, type='o', 
     subset=mean.of.class < 5000)
# add a horizontal  zero correlation line
abline(h=0)

# see that num of pairs drops off dramatically at large distances
# (many more pairs at short dists) - can ignore end of corr plot (weird due to being based on few pairs)

# at short dists - lots of correlation - makes sense - this is what spatial 
# autocorr is!


# key use of correlograms - assess how well models have controlled for spatial 
# autocorr by looking at corr in residuals

# compare our 2 models:

# Calculate correlograms for the residuals in the two models
simple.correlog <- with(data_sf, correlog(x, y, simple_resid, 
                                          increment=cellsize, resamp=0))
sar.correlog <- with(data_sf, correlog(x, y, sar_resid, 
                                       increment=cellsize, resamp=0))

# Convert those to make them easier to plot
simple.correlog <- data.frame(simple.correlog[1:3])
sar.correlog <- data.frame(sar.correlog[1:3])

# plot a correlogram for shorter distances
par(mfrow=c(1,1))
plot(correlation ~ mean.of.class, data=simple.correlog, 
     type='o', subset=mean.of.class < 5000)
# add the data for the SAR model to compare them
lines(correlation ~ mean.of.class, data=sar.correlog,
      type='o', subset=mean.of.class < 5000, col='red')

# add a horizontal  zero correlation line
abline(h=0)

# SAR model reduces correlation A LOT compared to lm
# still get some corr at v short distances (expected)


# Generalised least squares ----

# GLM - another extension of lm which allows expected corr between data points 
# to be included in the model

# differs from SAR - does not use list of cell neighbours, instead uses 
# mathematical function to describe a model of how corr changes w distance

# the gls function works in same way as lm but permits extra args

# can fit the simple model:
gls_simple <- gls(avian_richness ~ mean_aet + mean_temp + elev, data=data_sf)
summary(gls_simple)

# output v similar to lm (coefs identical to the lm above)
# one diff: glm inc matrix showing corrs ebtween expl variables
# elevation and temp highly corr - multicollinearity might be a problem (see prac2)

# to add spatial autocorr need to create a spatial corr structure
# eg below using Gaussian model
# ?corGaus
# esentailly describes how the expected corr decreases from an initial value w
# increasing distance until a threshold is reached - after that the data is 
# expected to be uncorrelated
# the constructor needs to know the spatial coords of the data (form=) 
# the other args set the shape of the curve 
# can set fixed=FALSE and model will try and optimise the range and nugget params (can take hours!)

# Define the correlation structure
cor_struct_gauss <- corGaus(value=c(range=650, nugget=0.1), 
                            form=~ x + y, fixed=TRUE, nugget=TRUE)
# Add that to the simple model - this might take a few minutes to run!
gls_gauss <- update(gls_simple,  corr=cor_struct_gauss)
summary(gls_gauss)

# output looks v similar but now includes description of corr structure
# model coefs have changed
# and significance of the variables - elev no longer sig.


# map the 2 model predictions
data_sf$gls_simple_pred <- predict(gls_simple)
data_sf$gls_gauss_pred <- predict(gls_gauss)
plot(data_sf[c('gls_simple_pred','gls_gauss_pred')], key.pos=4, cex=0.6, pch=20)


# compare residual autocorr

# Extract the residuals
data_sf$gls_simple_resid <- resid(gls_simple)
data_sf$gls_gauss_resid <- resid(gls_gauss)

# Calculate correlograms for the residuals in the two models
simple.correlog <- with(data_sf, correlog(x, y, gls_simple_resid, 
                                          increment=cellsize, resamp=0))
gauss.correlog <- with(data_sf, correlog(x, y, gls_gauss_resid, 
                                         increment=cellsize, resamp=0))

# Convert those to make them easier to plot
simple.correlog <- data.frame(simple.correlog[1:3])
gauss.correlog <- data.frame(gauss.correlog[1:3])

# plot a correlogram for shorter distances
plot(correlation ~ mean.of.class, data=simple.correlog, type='o', subset=mean.of.class < 5000)
# add the data for the SAR model to compare them
lines(correlation ~ mean.of.class, data=gauss.correlog, type='o', subset=mean.of.class < 5000, col='red')

# add a horizontal  zero correlation line
abline(h=0)

# OH NO! not the improvement we wanted...!
# can also look at relationship between observed and predicted richness
par(mfrow=c(1,2), mar=c(3,3,1,1), mgp=c(2,1,0))
lims <- c(0, max(data_sf$avian_richness))
plot(avian_richness ~ gls_simple_pred, data=data_sf, xlim=lims, ylim=lims)
abline(a=0, b=1, col='red', lwd=2)
plot(avian_richness ~ gls_gauss_pred, data=data_sf, xlim=lims, ylim=lims)
abline(a=0, b=1, col='red', lwd=2)

# BAD! It's clear that (although takes into account spatial autocorr)
# this spatial GLS is NOT a good description of the data

# DO NOT FORGET: ALL MODELS REQUIRE CAREFUL MODEL CRITICISM!!!


## Eigenvector filtering ----

# another approach for incorporating spatial structure
# eg below, take set of neighbourhood weights and convert them to eigenvector
# filters using meigen function from spmoran
# vignette('vignettes', package='spmoran')  # see for more data


# NOTE: spmoran (currently!) version num 0.2.2 - less than 1 means still in 
# development
# be wary of in development/infrequently used packages
# in this case, Daisuke Murakami is a co-author of many papers with Daniel 
# Griffith on eigenvector filtering and the quality and detail in the vignette 
# is an excellent indication of the care and attention put into the package
# Murakami, D. and Griffith, D.A. (2015) Random effects specifications in eigenvector spatial filtering: a simulation study. Journal of Geographical Systems, 17 (4), 311-331.


# first, need to extract eigenvectors from neighbourhood list
# need diff format so recreate the initial neighbours and convert these to a 
# weights matrix rather than sets of neighbour weights

# Get the neighbours
queen <- dnearneigh(data_sf, d1=0, d2=sqrt(2) * cellsize + 1)
# Convert to eigenvector filters - this is a bit slow
queen_eigen <- meigen(cmat = nb2mat(queen, style='W'))

# queen_eigen object contains matrix, sf, of spatial filters (not the same as the sf data frame class)
# and a vector, ev, of eigenvalues
# each column in queen_eigen$sf shows a diff pattern in the spatial structure
# and has a value for each data point
# the corresponding eigenvalue is a measure of the strength of that pattern

# some examples:
# Convert the `sf` matrix of eigenvectors into a data frame
queen_eigen_filters <- data.frame(queen_eigen$sf)
names(queen_eigen_filters) <- paste0('ev_', 1:ncol(queen_eigen_filters))

# Combine this with the model data frame - note this approach
# for combining an sf dataframe and another dataframe by rows
data_sf <- st_sf(data.frame(data_sf, queen_eigen_filters))

# Visualise 9 of the strongest filters and 1 weaker one for comparison
plot(data_sf[c('ev_1', 'ev_2', 'ev_3', 'ev_4', 'ev_5', 'ev_6', 
               'ev_7', 'ev_8', 'ev_9', 'ev_800')],
     pal=hcl.colors, max.plot=10, cex=0.2)

# spmoran provides more sophisticated (time-consuming) ways 
# but we will just add some eigenvector filters to a standard linear model
# will use first 9 eigenvectors
eigen_mod <- lm(avian_richness ~ mean_aet + elev + mean_temp + ev_1 + ev_2 +
                    ev_3 + ev_4 + ev_5 + ev_6 + ev_7 + ev_8 + ev_9, data=data_sf)
summary(eigen_mod)

# in the output - don't really care about the coefs for each filter - they're 
# just there to control for spatial autocorr
# might want to remove non-significant filters


# look at RESIDUAL spatial auto corr and PREDICTIONS from this model (same methods as above)
data_sf$eigen_fit <- predict(eigen_mod)
data_sf$eigen_resid <- resid(eigen_mod)

eigen.correlog <- with(data_sf, correlog(x, y, eigen_resid, 
                                         increment=cellsize, resamp=0))
eigen.correlog <- data.frame(eigen.correlog[1:3])

par(mfrow=c(1,2))
plot(data_sf['eigen_fit'], pch=20, cex=0.7,  key.pos=NULL, reset=FALSE)
# plot a correlogram for shorter distances
plot(correlation ~ mean.of.class, data=simple.correlog, type='o', 
     subset=mean.of.class < 5000)
# add the data for the SAR model to compare them
lines(correlation ~ mean.of.class, data=eigen.correlog, type='o', 
      subset=mean.of.class < 5000, col='red')


# NOT THAT GREAT EITHER! 

# (To be fair to the spmoran package, the approach is intended to consider a much larger set of filters and go through a selection process.)
# The modelling functions in spmoran do not use the formula interface - which is a bit hardcore - but the code would be as follows. I do not recommend running this now - I have no idea of how long it would take to finish but it is at least quarter of an hour and might be days.
# # Get a dataframe of the explanatory variables
# expl <- data_sf[,c('elev','mean_temp','mean_aet')]
# # This retains the geometry, so we need to convert back to a simple dataframe
# st_geometry(expl) <- NULL
# # Fit the model, optimising the AIC
# eigen_spmoran <- esf(data_sf$avian_richness, expl, meig=queen_eigen, fn='aic')


#### CONCLUSION - autoregressive model gave best description of richness and 
# reduced spatial autocorr the most
