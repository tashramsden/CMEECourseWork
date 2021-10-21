doit <- function(x) {
    temp_x <- sample(x, replace = TRUE)
    if (length(unique(temp_x)) > 30) {  # only take mean if sample was sufficient
         print(paste("Mean of this sample was:", as.character(mean(temp_x))))
    } 
    else {
        stop("Couldn't calculate mean: too few unique values!")  # stops execution ad generates error action
    }
}

set.seed(1345)
popn <- rnorm(50)
hist(popn)

# run doit using lapply - repeat sampling 15 times
# lapply(1:15, function(i) doit(popn))  # WILL generate an error at some point when sample too small

## using TRY
result <- lapply(1:15, function(i) try(doit(popn), FALSE))  # FALSE means error messages NOT supressed - if TRUE won't see error messages at all
# error messages still generated, but script continues to run

# errors are stored in result
class(result)
result  # lots of output! - tells which runs produced eroor and why


## can also stroe the results "manually" using loop:
# result <- vector("list", 15)  # pre-allocate
# for (i in 1:15) {
#     result[[i]] <- try(doit(popn), FALSE)
# }

# result

