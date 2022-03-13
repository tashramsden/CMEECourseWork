## Machine learning - day2 - supervised ----
# Regression trees, LAR and lasso, support vector machnines

rm(list=ls())
library(tree)
library(randomForest)
library(gbm)
library(lars)
library(e1071)


## Regression trees ----

# plant diversity across a series of (a)biotic gradients—temperature, humidity, 
# soil Carbon, and herbivore diversity
# simulate some data under a reasonable biological model (greater diversity
# in tropics, and a sort-of trophic cascade effect of herbivory
# model plant diversity using Poisson - get noise in data

# simulate data:
# Build model of species diversity
data <- expand.grid(temperature=seq(0,40,4), humidity=seq(0,100,10),
                    carbon=seq(1,10,1), herbivores=seq(0,20,2))
data$plants <- runif(nrow(data), 3, 5)
data$plants <- with(data, plants + temperature * .1)
data$plants[data$humidity > 50] <- with(data[data$humidity > 50,],
                                        plants + humidity * .05)
data$plants[data$carbon < 2] <- with(data[data$carbon < 2,], plants - carbon)
data$plants <- with(data, plants + herbivores * .1)
data$plants[data$herbivores > 5 & data$herbivores < 15] <-
    with(data[data$herbivores > 5 & data$herbivores < 15,], plants - herbivores * .2)
# Draw random data from Poisson based on this
for(i in seq_len(nrow(data))) {
    data$plants[i] <- rpois(1, data$plants[i])
}

# fit regression tree
# library(tree)

# Pick some training data and then fit a model to it
training <- sample(nrow(data), nrow(data)/2)
model <- tree(plants~., data=data[training,])

# Examine the model
plot(model)
text(model)
# v intuitive - can see humidity key in diversity 
# and interactions clear too

# Look at the statistics of the model
model
summary(model)

# Check performance outside training set
cor.test(predict(model, data[-training,]), data$plants[-training])
# sort-r r: ~0.6

# Check cross-validation of model
# see how well model performs under diff tree depths (num of nodes)
plot(cv.tree(model))
# up to me what constitutes good fit/where to draw line
# here, clear this good - line goes down 
# but prob could fit simpler model w/o much change


## Bagged regression trees and random forest ----

# ave of many regression trees fit to bootstrapped subsets of data = solution to overfitting

# library(randomForest)
model <- randomForest(plants~., data=data[training,], mtry=ncol(data)-1)
# mtry arg in randomForest - each time trying to make new split - consider all vars available
# when randomly change available expl vars each time split considered in each 
# bootstrapped tree = random forest model
# -> bootstrapped trees resemble each other less (ie de-correlate the trees - improve ests)
cor.test(predict(model, data[-training,]), data$plants[-training])
# ave from MANY regreesion trees

# variable importance = ave decrease in mean squared error each time split in tree fit to expl var
# (r^2 of each var)
# simple way to understand what each var doing in model
model <- randomForest(plants~., data=data[training,], importance=TRUE)
importance(model)
cor.test(predict(model, data[-training,]), data$plants[-training])


## Boosted regression trees ----

# library(gbm)
model <- gbm(plants~., data=data[training,], distribution="poisson")
# summary and plots variable importance 
summary(model)
# - can see again clearly humidity most important

faster.model <- gbm(plants~., data=data[training,], distribution="poisson", shrinkage=.1)


## Lasso regression ----

# simulate data 
# 1000 explanatory vars, only 2 (cols 123 and 678) are significantly related to data
# would be so difficult to determine which important w linear regression
explanatory <- replicate(1000, rnorm(1000))
response <- explanatory[,123]*1.5 - explanatory[,678]*.5

# fit lasso regression
# library(lars)
model <- lars(explanatory, response, type="lasso")

# plot model
plot(model)

# wrapper function to get some coef estimates for the sig coefs
signif.coefs <- function(model, threshold=0.001){
    coefs <- coef(model)
    signif <- which(abs(coefs[nrow(coefs),]) > threshold)
    return(setNames(coefs[nrow(coefs),signif], signif))
}
signif.coefs(model)
# woohoo! -from 1000 input expl vars - correctly estimates the 2 that matter - v quickly!


## LAR ----
model <- lars(explanatory, response, type="lar")
plot(model)
signif.coefs(model)

# scaling data -- MUST - expl vars should be z-transformed 
bad.model <- lars(explanatory, response, type="lar", normalize=FALSE)
signif.coefs(bad.model, thresh=0) # Wow what a lot of coefficients!
signif.coefs(model, thresh=0) # Nothing wrong here :D



## Support vector machines - SVMs ----

# simulate data
# 2 random variables, make a set of points "in the middle" somehow different
data <- data.frame(replicate(2, rnorm(1000)))
data$y = (rowSums(data) > (median(rowSums(data)) - 1)) &
    (rowSums(data) < (median(rowSums(data)) + 1))
with(data, plot(X1, X2, pch=20, col=ifelse(y, "red", "black")))
# eg pretend y (colour) = presence of spp in climatic conditions
# x1 = temp
# x2 = humidity


# fit a SVM
# library(e1071)
training <- sample(nrow(data), nrow(data)/2)
# using default radial kernel
model <- svm(y~., data=data[training,], type="C")  # type C = classification
plot(model, data[training,])
# success!!!

# try on validation data
table(predict(model, data[-training,]), data$y[-training])
# great! - overwhelming majority correctly identified (ie most data in diagonals = correct)

# check performance of the params gamma and cost on non-training - cheating?
tune.svm(factor(y)~., data=data[-training,], gamma=c(.5,1,10), cost=c(1,10))

