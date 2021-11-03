# Runs the stochastic Ricker equation with gaussian fluctuations

rm(list = ls())  # removes functions already in workspace

# set.seed(12345)  # set seed and view res for both models to check same output

stochrick <- function(p0 = runif(1000, .5, 1.5), r = 1.2, K = 1, 
                      sigma = 0.2, numyears = 100) {  # sigma is st dev

    N <- matrix(NA, numyears, length(p0))  #initialize empty matrix

    N[1, ] <- p0

    for (pop in 1:length(p0)) {  # loop through the populations

        for (yr in 2:numyears) {  # for each pop, loop through the years

            N[yr, pop] <- N[yr-1, pop] * exp(r * (1 - N[yr - 1, pop] / K) + rnorm(1, 0, sigma)) # add one fluctuation from normal distribution
    
        }
  
    }

    return(N)

}

print("Non-Vectorized Stochastic Ricker takes:")
print(system.time(res1<-stochrick()))
# View(res1)


# Now write another function called stochrickvect that vectorizes the above to
# the extent possible, with improved performance: 

# set.seed(12345)

stochrickvect <- function(p0 = runif(1000, .5, 1.5), r = 1.2, K = 1, 
                          sigma = 0.2, numyears = 100) {

    N <- matrix(NA, numyears, length(p0))  # initialize empty matrix

    N[1, ] <- p0
    
    # generate matrix of random fluctuations to be added to EACH N value 
    matrix_size <- length(p0) * (numyears - 1)
    random_flucts <- matrix(rnorm(matrix_size, 0, sigma), nrow = numyears-1,
                            ncol = length(p0))

    # cannot vectorize rows (years) as calculations depend on previous year (not independent)
    for (yr in 2:numyears) {  # for each pop, loop through the years (rows)

        # pop can be vectorized as all pops independent of each other
        # N[yr,] selects whole column (population)
        # NOT THIS: N[yr, ] <- N[yr-1, ] * exp(r * (1 - N[yr - 1, ] / K) + rnorm(1, 0, sigma))  # this adds the same value to every pop
        N[yr, ] <- N[yr-1, ] * exp(r * (1 - N[yr - 1, ] / K) + random_flucts[yr-1,])  # add one fluctuation TO EACH VALUE
      
    }

    return(N)

}

print("Vectorized Stochastic Ricker takes:")
print(system.time(res2<-stochrickvect()))
# View(res2)  # view res1 and res2 - are exactly the same when seed set
