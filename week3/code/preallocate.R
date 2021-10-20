## No pre-allocation of vector - will be repeatedly resized ##

NoPreallocFun <- function(x) {
    a <- vector()  # empty vector
    for (i in 1:x) {
        a <- c(a, i)
        print(a)
        print(object.size(a))
    }
}

system.time(NoPreallocFun(10))
# print(system.time(NoPreallocFun(10000)))  # to actually see differences in speed - but comment out print(a) and object size first!


## Pre-allocation - faster ##

PreallocFun <- function(x) {
    a <- rep(NA, x)  # pre-allocated vector
    for (i in 1:x) {
        a[i] <- i
        print(a)
        print(object.size(a))
    }
}

system.time(PreallocFun(10))
# print(system.time(PreallocFun(10000)))
