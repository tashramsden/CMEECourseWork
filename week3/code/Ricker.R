## Running the Ricker model

Ricker <- function(N0=1, r=1, K=10, generations=50) {

    # Runs a simulation of the Ricker model
    # Returns a vector if length generations

    N <- rep(NA, generations)  # creates a vector of NAs of length generations

    N[1] <- N0
    for (t in 2:generations) {
        N[t] <- N[t-1] * exp(r*(1.0-(N[t-1]/K)))  # DIFFERENCE model - time steps
    }
    return (N)

}

# plot(Ricker(generations=10), type="l")

pdf("../sandbox/Ricker.pdf", 6, 6)
print(plot(Ricker(generations=10), type="l", xlab="Generations", ylab="Population Size", main="Ricker Model"))
dev.off()
