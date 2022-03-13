## Practical 2 - supervised ----

rm(list=ls())
library(tree)
library(randomForest)
library(gbm)


## Exercises 4.4: regression trees, lasso & LAR, support vector machines ----

## Q1 ----

set.seed(123)
# data:
# fuel efficiency of several kinds of car (mpg—miles per gallon), and can be
# described as a function of various other properties of the cars
# (simplified) from Quinlan (1993) “Combining Instance-Based and Model-Based Learning” in Proceedings on the Tenth International Conference of Machine Learning, 236–243
cars <- read.table("../data/auto-mpg.txt")

## a) Fit a regression tree to a training subset of data.
training <- sample(nrow(cars), nrow(cars)/2)
model <- tree(mpg~., data=cars[training,])

## b) Plot out the resulting model, and explain in a few short sentences what the output shows.
plot(model)
text(model)
summary(model)
# displacement is biggest factor in mpg - below 169.5 displacement -> higher mpg
# if <169.5 then horsepower next most important vs >169.5 then weight more key

## c) Validate your regression tree using independent data
cor.test(predict(model, cars[-training,]), cars$mpg[-training])

## d) Fit a lasso regression to these data. Plot out your model and explain what the
# fitting process is showing you as it progresses.

# explanatory var has to be a matrix
expl <- as.matrix(subset(cars, select = c(-mpg, -car.names)))
response = cars$mpg

model <- lars(expl, response, type="lasso")

# plot model
plot(model)

# wrapper function to get some coef estimates for the sig coefs
signif.coefs <- function(model, threshold=0.001){
    coefs <- coef(model)
    signif <- which(abs(coefs[nrow(coefs),]) > threshold)
    return(setNames(coefs[nrow(coefs),signif], signif))
}
signif.coefs(model)
# 5 expl vars significant (with this threshold value!)


## e) Now fit a LAR to these data. Compare your results with those of parts 
# (a), (c), and (d) above. Which model do you find the easiest to interpret? Why?

model <- lars(expl, response, type="lar")
plot(model)
signif.coefs(model)

# find the normal regression tree easiest to interpret- nice plot!


## Q2 ----

# dataset on forest fires
# task: model area of forest on fire as a function of various weather factors and
# some forest-fire indicators that the Canadian govt uses

# since response var is area might want to employ a log10(area+1) transformation to it
# BUT note: shouldn't really do this "in the wild!"

set.seed(123)

full_fires <- read.csv("../data/forestfires.csv")
full_fires$area <- log10(full_fires$area+1)
hist(full_fires$area)
str(full_fires)

# fires <- subset(full_fires, select = c(-X, -Y, -day, ))

fires <- subset(full_fires, select=c(-day, -month))
# fires <- full_fires

## a) Fit a regression tree to this data. Explain what it means intuitively.

training <- sample(nrow(fires), nrow(fires)/2)
model1_reg <- tree(area~., data=fires[training,])

# examine model
plot(model1_reg)
text(model1_reg)
summary(model1_reg)
# quite complex - lots of diff interacting factors
# temp most important


## b) Fit a bagged tree, a random forests model, and a boosted tree to a
# training subset of these data.

# bagged
model2_bag <- randomForest(area~., data=fires[training,], mtry=ncol(fires)-1, importance=TRUE)
importance(model2_bag)

# random-forest
model3_forest <- randomForest(area~., data=fires[training,], importance=TRUE)
importance(model3_forest)

# boosted tree
model4_boost <- gbm(area~., data=fires[training,])
# summary and plots variable importance 
summary(model4_boost)

## temp most important expl var


## c) Using your independent data, determine which of these models has performed the best.

# regression tree normal
cor.test(predict(model1_reg, fires[-training,]), fires$area[-training])

# bagged
cor.test(predict(model2_bag, fires[-training,]), fires$area[-training])

# random forest
cor.test(predict(model3_forest, fires[-training,]), fires$area[-training])

# boosted 
cor.test(predict(model4_boost, fires[-training,]), fires$area[-training])

# bagged best here (all not wonderful...)


## d) Fit both a lasso and a LAR model to these data. Explain their results,
# and contrast their differences.

# lasso
expl <- as.matrix(subset(fires, select=c(-area)))
lasso_model <- lars(expl, fires$area, type="lasso")

# plot model
plot(lasso_model)
signif.coefs(lasso_model)
## 6 expl vars significant

# LAR
lar_model <- lars(expl, fires$area, type="lar")
plot(lar_model)
signif.coefs(lar_model)

# both give same results


## e) Fit a PCA to these data, extract the most significant terms, and fit a 
# LAR to these data. How different is this model from the one you fit in (d)? 
# Why do you think that is, and which model do you prefer?

pca <- prcomp(fires, scale=TRUE)
biplot(pca)
biplot(pca, choices=3:4)

summary(pca)
plot(pca)
# use 3/4 PCs 

# use for LAR
pca_matrix <- as.matrix(pca$x[,c(1,2,3,4)])
# LAR
lar_pca_model <- lars(pca_matrix, fires$area, type="lar")
plot(lar_pca_model)
signif.coefs(lar_pca_model)


## Q4 ----

set.seed(123)

# iris dataset
data(iris)

## a) Perform an SVM on the iris dataset. Validate your model using training data.
training <- sample(nrow(iris), nrow(iris)/2)
# using default radial kernel
SVM_model <- svm(Species~., data=iris[training,], type="C")  # type C = classification
# plot(SVM_model, iris[training,], formula=Petal.Width ~ Sepal.Length)
plot(SVM_model, iris, Petal.Width ~ Petal.Length,
     slice = list(Sepal.Width = 3, Sepal.Length = 4))

# try on validation data
table(predict(SVM_model, iris[-training,]), iris$Species[-training])
# great! - overwhelming majority correctly identified (ie most data in diagonals = correct)


## b) Train your model’s γ parameter. Does your model fit any better?
tune.svm(factor(Species)~., data=iris[-training,], gamma=c(.5,1,10), cost=c(1,10))

# use these vals of gmma and cost
SVM_model <- svm(Species~., data=iris[training,], type="C", gamma=0.5, cost=1) 
plot(SVM_model, iris, Petal.Width ~ Petal.Length,
     slice = list(Sepal.Width = 3, Sepal.Length = 4))
table(predict(SVM_model, iris[-training,]), iris$Species[-training])
# still v good - but worked well before anyway!


## c) make sense of the following code:

plot(SVM_model, iris, Sepal.Length ~ Sepal.Width, slice=
         list(Petal.Width=median(iris$Petal.Width),Petal.Length=median(iris$Petal.Length))
)
# compared to plots above - spp less separated - depends on which axes plotted!!!
# and bio question!!!







