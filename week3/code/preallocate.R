## Exploring preallocation in R

## No pre-allocation of vector - will be repeatedly resized ##
NoPreallocFun <- function(x) {
    a <- vector()  # empty vector
    for (i in 1:x) {
        a <- c(a, i)
        # print(a)
        # print(object.size(a))
    }
}

# print("Run-time with no preallocation (for vector of size 10 and then 10000):")
# print(system.time(NoPreallocFun(10)))
# print(system.time(NoPreallocFun(10000)))  # to actually see differences in speed - but comment out print(a) and object size first!

print(system.time(NoPreallocFun(1000)))


## Pre-allocation - faster ##
PreallocFun <- function(x) {
    a <- rep(NA, x)  # pre-allocated vector
    for (i in 1:x) {
        a[i] <- i
        # print(a)
        # print(object.size(a))
    }
}

# print("Run-time with preallocation (for vector of size 10 and then 10000):")
# print(system.time(PreallocFun(10)))
# print(system.time(PreallocFun(10000)))

print(system.time(PreallocFun(1000)))
