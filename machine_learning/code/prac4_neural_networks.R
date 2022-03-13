## Practical 4 - neural networks ----

rm(list=ls())
library(keras)

## Exercises 7.5 ----

# data from keras - handwriting
mnist <- dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y

# ?dataset_mnist

# visualise for sense
lookup <- c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
x_train <- x_train / 255  # scale data
par(mfrow=c(5,5))
for(i in seq_len(5*5)) {
    image(t(x_train[i,28:1,]), main=lookup[y_train[i]+1], col=grey.colors(255))
}

## a) train a "flat" deep learning network w at least 2 hidden layers on these data
# data = handwritten digits (the numbers 0–9), so set up your output layer accordingly

model <- keras_model_sequential()
model %>%
    # layer flatten = change matrix of image into 1D vector
    layer_flatten(input_shape = c(28, 28)) %>%  # input data = 28x28 pixel image
    layer_dense(units = 128, activation = 'relu') %>%
    layer_dropout(rate = 0.5) %>%
    # output layer:
    # using softmax activation - response is categorical (ie is 0/not) 
    # - 10 categories (0 to 9) -> 10 output layers
    layer_dense(units = 10, activation = 'softmax')
# ?layer_dense

# Compile model
model %>% compile(
    optimizer = 'adam',  # 
    loss = 'sparse_categorical_crossentropy',  # categorical response
    metrics = c('accuracy')
)

# Fit model and independently validate
model %>% fit(x_train, y_train, epochs = 5)

x_test <- x_test / 255
model %>% evaluate(x_test, y_test)
predictions <- model %>% predict(x_test)

table(apply(predictions, 1, which.max)-1, y_test)


## b) Fit a convolutional neural network to the data of the same hidden 
# structure as in my example code above.

# Model specification
conv <- keras_model_sequential() %>%
    layer_conv_2d(filters = 20, kernel_size = c(3,3), activation = 'relu',
                  input_shape = c(28,28,1)) %>%
    layer_max_pooling_2d(pool_size = c(2, 2)) %>%
    # layer_dropout(rate = 0.25) %>%
    layer_flatten() %>%
    layer_dense(units = 20, activation = 'relu') %>%
    layer_dense(units = 10, activation = 'softmax') %>%
    compile(
        optimizer = 'adam',
        loss = 'sparse_categorical_crossentropy',
        metrics = c('accuracy')
    )

# rearrange data and fit model
conv %>% fit(x_train, y_train, epochs = 10)

conv %>% evaluate(x_test, y_test)
predictions <- conv %>% predict(x_test)
table(apply(predictions, 1, which.max)-1, y_test)


## c) Add, subtract, and/or alter hidden layers in order to get your model 
# to fit faster than it does in part (b) above.

conv <- keras_model_sequential() %>%
    layer_conv_2d(filters = 10, kernel_size = c(3,3), activation = 'relu',  # reduced filters 
                  input_shape = c(28,28,1)) %>%
    layer_max_pooling_2d(pool_size = c(4, 4)) %>%  # increased pool size
    layer_dropout(rate = 0.25) %>%  # add drop out
    layer_flatten() %>%
    # layer_dense(units = 20, activation = 'relu') %>%  # removed extra layer
    layer_dense(units = 10, activation = 'softmax') %>%
    compile(
        optimizer = 'adam',
        loss = 'sparse_categorical_crossentropy',
        metrics = c('accuracy')
    )

# rearrange data and fit model
conv %>% fit(x_train, y_train, epochs = 10)

conv %>% evaluate(x_test, y_test)
predictions <- conv %>% predict(x_test)
table(apply(predictions, 1, which.max)-1, y_test)


## d) Which of the two models, (b) or (c), do you think is the best fit to 
# your data? Things to think about: if your model fits faster, does it matter
# if its quality increases more slowly across epochs?

# fit faster model - doesn't matter if starts at lower accuracy in epoch 1 - 
# increases over epochs to be ~ as high as slower model

