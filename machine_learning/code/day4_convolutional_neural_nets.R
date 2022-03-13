## Machine learning - day4 - convolutional and recurrent neural networks ----

rm(list=ls())

# Setup
library(keras)
install_keras()


## Basic image classification ----

# Load data (a classic (easy) dataset)
raw.data <- dataset_fashion_mnist()
resp <- raw.data$train$y
exp <- raw.data$train$x

# Do a bit of renaming and scaling, and plot for sense
lookup <- c("T-shirt/top", "Trouser", "Pullover", "Dress",
            "Coat", "Sandal", "Shirt", "Sneaker", "Bag", "Ankle boot")
exp <- exp / 255  # divide by 255 to scale data (greyscale 1:256 divide by 255 to get vals 0:1 instead)
par(mfrow=c(5,5))
for(i in seq_len(5*5)) {
    image(t(exp[i,28:1,]), main=lookup[resp[i]+1], col=grey.colors(255))
}
# ... the images are upside-down, hence the 28:1 statment,
# ... and R needs matrices rotated to plot, hence the use of *t*ranspose
# ... and keras needs labels (resp) to start at 0, hence +1


# Define model
model <- keras_model_sequential()
model %>%
    # layer flatten = change matrix of image into 1D vector
    # ie THIS IS NOT A CONVOLUTIONAL MODEL - just categorical input as prev models (yesterday)
    layer_flatten(input_shape = c(28, 28)) %>%  # input data = 28x28 pixel image
    # units = num nodes, here 128 is reasonable (ie prev layer 784 nodes and want to taper down at reasonable rate)
    layer_dense(units = 128, activation = 'relu') %>%
    layer_dropout(rate = 0.5) %>%
    # output layer:
    # using softmax activation - response is categorical (ie trousers/not) 
    # - 10 categories -> 10 output layers
    layer_dense(units = 10, activation = 'softmax')
# Compile model
model %>% compile(
    optimizer = 'adam',  # 
    loss = 'sparse_categorical_crossentropy',  # categorical response
    metrics = c('accuracy')
)
# Fit model and independently validate
model %>% fit(exp, resp, epochs = 5)
test.resp <- raw.data$test$y
test.exp <- raw.data$test$x
test.exp <- test.exp/255
model %>% evaluate(test.exp, test.resp)
# accurate!
predictions <- model %>% predict(test.exp)
table(apply(predictions, 1, which.max)-1, test.resp)
## looks v good (w only 5 epochs)
# correctly predicted categories on the whole


## Convolutional network ----

# Model specification
conv <- keras_model_sequential() %>%
    # kernel size = c(3,3) means detector is 3x3 pixels
    # filters = 20 ~ only looking at snapshot of end data
    # conv = convolve
    layer_conv_2d(filters = 20, kernel_size = c(3,3), activation = 'relu',
                  # input shape = 28x28 pixel image w 1 channel (ie black&white)
                  input_shape = c(28,28,1)) %>%
    # pooling - ie compressing data - averaging/summing - ie take input image and sum 2x2 cells (~ reducing resolution)
    layer_max_pooling_2d(pool_size = c(2, 2)) %>%
    #layer_dropout(rate = 0.25) %>%
    
    # now that done processing as an image -> now flatten and examine as flat structure -> network
    layer_flatten() %>%
    layer_dense(units = 20, activation = 'relu') %>%
    layer_dense(units = 10, activation = 'softmax') %>%
    compile(
        optimizer = 'adam',
        loss = 'sparse_categorical_crossentropy',
        metrics = c('accuracy')
        )
## accuracy during fitting increases over epochs 
# even in first epoch accuracy higher than where prev flattened model ended!
# and much faster

# Re-arrange data and fit model
array.exp <- array(exp, dim=c(dim(exp), 1))
conv %>% fit(array.exp, resp, epochs = 10)
# even higher accuracy!!!

conv %>% evaluate(test.exp, test.resp)
# accurate!
predictions <- conv %>% predict(test.exp)
table(apply(predictions, 1, which.max)-1, test.resp)
# fab!

# (If you want to subset the data a bit more, try)
subset.exp <- exp[1:500,,]
s.array.exp <- array(subset.exp, dim=c(dim(subset.exp), 1))
conv %>% fit(s.array.exp, resp[1:500], epochs = 10)
# Much faster!


## Freezing networks ----

## NOT freezing! - just adding more on to the network
new <- keras_model_sequential() %>%
    conv() %>%
    layer_dense(units = 10, activation = "softmax") %>%
    compile(
        optimizer = 'adam',
        loss = 'sparse_categorical_crossentropy',
        metrics = c('accuracy')
    )
# using already-trained components - now train w new data
new %>% fit(s.array.exp, resp[1:500], epochs = 10)


## freezing
# Freeze the whole thing - ie weights don't change now
freeze_weights(conv)
# ...or...
# Look at the model to figure out the layer names
conv
# Selectively unfreeze the last layer
unfreeze_weights(conv, from="dense_2")
# Re-compile the model (you must do this before use after any freezing or unfreezing)
new %>% compile(
    optimizer = 'adam',
    loss = 'sparse_categorical_crossentropy',
    metrics = c('accuracy')
)


## Augmentation/image shattering ----

# Let's do 20 training epochs
for(i in 1:20){
    # Randomly alter the training data
    augmented <- array.exp + rnorm(length(as.numeric(exp)), sd=.1)  # try diff sd
    # Train once on new data
    conv %>% fit(augmented, resp, epochs=1)
}
# reassess model fit


## Recurrent neural networks ----

# Simulate a time series (y) with first-order autocorrelation - similar to last time step
y <- rep(0, 101)
for(i in seq(2, length(y))) {
    y[i] <- y[i-1] + rnorm(1)  # ie same as last time-step + some error
}
y <- as.numeric(scale(y))  # SCALE THE VARIABLE!!!
# ... why are we scaling the variable?
# Make a predictor variable that is the previous time-step (x)
# and then split into training/test data
x <- y[1:100]
x_train <- array(t(matrix(x[1:50], 5, 10)), dim=c(10,5,1))
x_test <- array(t(matrix(x[51:100], 5, 10)), dim=c(10,5,1))
y_train <- y[seq(6,51, by=5)]
y_test <- y[seq(56,101, by=5)]
# ... note we are using arrays, grouping our data into runs of
#     5 sequential points, with 10 training/test replicates,
#     and an overall dimension of 1 (i.e., a single variable)
# Build the model itself - spot the RNN layer!...


model <- keras_model_sequential() %>%
    # input shape = 5x1, 5 time series estimates, asking it to predict the next 1
    # will be 4 recurrences 
    layer_dense(input_shape=c(5,1), units=5) %>%
    layer_simple_rnn(units=5) %>%
    layer_dense(units=1)
# Train the model
model %>%
    compile(
        loss = "mean_squared_error",
        optimizer = optimizer_rmsprop(),
        metrics = list("mean_squared_error")
    )
# Let store the training data so that we can...
history <- model %>% fit(
    x_train, y_train, epochs = 500
)
# ...plot it out, along with model predictions
plot(history)
plot(predict(model, x_test)[,1] ~ y_test)
# not that great...


