## Machine learning - day3 - artificial neural networks ----

rm(list=ls())
library(neuralnet)  # generally not use this - but get nice plots for starting
library(NeuralNetTools)

# keras/tensorflow can be a pain! (see first answer here for fix: https://stackoverflow.com/questions/63220597/python-in-r-error-could-not-find-a-python-environment-for-usr-bin-python)
library(keras)  # high-level wrapper for tensorflow 
install_keras()

library(tensorflow)
install_tensorflow() 


# Intro
x <- rnorm(1000)
y <- -x
data <- data.frame(scale(cbind(x,y)))

# v simple model - no hidden layers
# still lots of steps = ie forward and back passes
model <- neuralnet(y ~ x, hidden=0, data=data)
plot(model)

# some slightly more complex data
explanatory <- data.frame(replicate(10, rnorm(400)))
names(explanatory) <- letters[1:10]
response <- with(explanatory, a*2 -0.5*b - i*j + exp(abs(c)))
# scale expl vars - NO exploding gradient problem here!!!
data <- data.frame(scale(cbind(explanatory,response)))

# split into training data
training <- sample(nrow(data), nrow(data)/2)

# fairly complex problem - 2 standard linear terms, an interaction and weird 
# exponent of a non-negative num (response)

model <- neuralnet(response~a+b+c+d+e+f+g+h+i+j,
                   dat=data[training,], hidden=5)  # 5 hidden nodes
cor.test(compute(model, data[-training,1:10])$net.result[,1],
         data$response[-training])
plot(model)  # nums show weights on lines
# so many steps to converge

## performs so well - v high R^2
# difficult to decipher - is this a good model/parsimonious?


# library(NeuralNetTools)
garson(model, bar_plot=FALSE)
garson(model)
# sums up weights -> importance
# only guaranteed to work for neural nets w single hidden layer
# even then doesn't work that well


## tensorflow ----

# Simulate data (this time adding noise to the response variable)
exp <- replicate(10, rnorm(400))
resp <- exp[,1]*2 -0.5*exp[,2] - exp[,7]*exp[,8] + exp(abs(exp[,3])) + rnorm(nrow(exp))
# Scale data and making training subset
exp <- as.matrix(scale(exp)); resp <- as.numeric(scale(resp))
training <- sample(nrow(exp), nrow(exp)/2)

# Get Keras ready

# library(keras)
# install_keras()
# 
# library(tensorflow)
# install_tensorflow()

# Specific model
model <- keras_model_sequential()  # want sequential network - ie flow through network straight - no loops
model %>%
    # model w 2 hidden layers, each w 15 nodes, and output layer w 1 node
    layer_dense(units = 15, activation = 'relu', input_shape=10) %>%
    # relu = rectifier activation function
    # input shape = 10 nodes in first layer - must be same num as input vars (explanatory)
    layer_dense(units = 15, activation = 'relu') %>%
    layer_dense(units = 1)

# Compile model
model %>% compile(
    loss = 'mean_squared_error',  # measure of error
    optimizer = optimizer_rmsprop(),  # use built-in optimizer
    metrics = c('mean_squared_error')  # report and record metrics on its fit to the data
)
# Train model with data
model %>% fit(exp[training,], resp[training], epoch=500)  # epoch = iteration (forward+back)

# Validate model with indep data
plot(predict(model, exp[-training,])[,1] ~ resp[-training])
cor.test(predict(model, exp[-training,])[,1], resp[-training])
## looks v good!


## Keras has v cool training dashboard
# if, while training, tell Keras where to store log-files - can visualise them later
# setwd("/home/tash/Documents/CMEECourseWork/machine_learning/code")
model %>% fit(
    exp[training,], resp[training], epoch=500,
    callbacks = callback_tensorboard("../keras_log")
)
tensorboard("../keras_log")
# Ooooh!

