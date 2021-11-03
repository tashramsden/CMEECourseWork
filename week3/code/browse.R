## The browser() function for debugging
## In browser: use n to take single step, c to exit browser and continue,
## Q to exit browser and abort

Exponential <- function(N0 = 1, r = 1, generations = 10) {
    # Runs a simulation of exponential growth
    # Returns a vector of length generations

    N <- rep(NA, generations)  # Creates a vector of NA

    N[1] <- N0
    for (t in 2:generations) {
        N[t] <- N[t-1] * exp(r)
        # browser()  # FOR DEBUGGING
    }
    return (N)
}

# plot(Exponential(), type="l")

pdf("../sandbox/Exponential_growth.pdf", 6, 6)
print(plot(Exponential(), type="l", main="Exponential growth", xlab="Generations", ylab="Population Size"))
dev.off()
