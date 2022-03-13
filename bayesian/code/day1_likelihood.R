## Bayesian stats 1 - likelihood ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/bayesian/code")


## Lecture 1 ----

## eg success of breeding event

# prob of one val of p, eg p=0.5
dbinom(x=3, size=8, prob=0.5)
# if p=0.5, then likelihood of data = 0.22

# for sequence of p vals
p_vals <- seq(0, 1, 0.001)
likelihood_vals <- dbinom(x=3, size=8, prob=p_vals)

plot(p_vals, likelihood_vals, type="l")

# get maximum likelihood value
max_like_val <- max(likelihood_vals)

# find value of param p that gives the max likelihood
which(likelihood_vals %in% max_like_val)
p_vals[39]
# or all together:
p_vals[which(likelihood_vals %in% max_like_val)]
# so value of p = 0.38 => max likelihood of 0.28


# define likelihood function - can use optimisation algorithm to find max
likelihood_binomial <- function(p, n=8, k=3) {
    # probability (dbinom)
    prob <- dbinom(x=k, size=n, prob=p)
    return(prob)
}

likelihood_binomial(p=p_vals)

# maximise the likelihood using optim/optimize

# optimize only max ONE PARAM - must be the one in FIRST position of function
optimize(likelihood_binomial, interval=c(0,1), maximum=TRUE)
# maximum = p val that maximises likelihood
# objective = maximum likelihood value, ie max likeilhood of observing the data

optim(par=c(1),  # initial values for the param
      fn=likelihood_binomial,  # function to be optimised
      control=list(fnscale=-1),
      hessian=T) 


## Practical 1 - probabilities and likelihood ----

rm(list=ls())

# Exercise 1 ----

# scenario: after 62 visits to the field, observe 19 diff bird specimens
# what is prob with which you observe a bird specimen?

# Define number of attempts (n) and successes (k)
n <- 62
k <- 19

binomial.likelihood <- function(p, n=62, k=19) {
    prob <- dbinom(x=k, size=n, prob=p)
    return(prob)
}
optimize(binomial.likelihood, interval=c(0,1), n=62, k=19, maximum=TRUE)
# maximum likelihood = 0.109, ie ~10% chance observing a bird specimen
# value of p which maximises likelihood = 0.306

?optimize

# Exercise 2 ----

# generate a random data set in which we assume that the weight of 80 specimens
# of pandas follow a normal distribution. 
# assume that our mean is 110 Kg, with a standard deviation of 20.

lnL_norm <- function(theta, D=weight) {
    # Define the mean and the standard deviation, which are passed 
    # to one argument as a numeric vector of length 2
    mu <- theta[1]
    sigma <- theta[2]
    # Define log-normal distribution, a sum over all possible values passed 
    # to data, D
    lnL <- sum( dnorm( x = D, mean = mu, sd = sigma, log = TRUE ) )
    # Return likelihood 
    return( lnL )
}

set.seed(12345)
# Simulate data 
n  <- 80
mu <- 110
sd <- 20
# Get weight measurements for n = 80 panda specimens
weight <- rnorm(n=n, mean=mu, sd=sd)

# plot this normal dist
hist(x=weight, freq=FALSE)
curve( dnorm(x, mean = mu, sd = sd), add = TRUE, col = "red" )

# lnL_norm(theta=c(1, 1), D=weight)

# what are the values of the params mu and st dev that maximise this likelihood function?
optim(par=c(1,1),  # initial values for the param
      fn=lnL_norm,  # function to be optimised
      control=list(fnscale=-1), # MAXIMISE function (not default=min)
      hessian=T) 
# mu = 113.38, sd=18.80
