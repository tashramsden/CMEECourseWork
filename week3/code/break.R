# The break statement in R

i <- 0  # initialise i

while(i < Inf) {
    if (i == 10) {
        break
    }  # break out of while loop!
    else {
        cat("i equals ", i , " \n")
        i <- i + 1  # update i
    }
}
