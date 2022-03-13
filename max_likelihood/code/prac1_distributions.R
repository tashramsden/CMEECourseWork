## Maximum likelihood - practical 1 ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/max_likelihood/code")

# distributions in R
# norm, pois, binom, etc
# prefixes: 
# r : random nums from the dist (eg rnorm)
# d : distribution (ie values for pmf/pdf)
# p : values for cdf
# q : values for quantiles


## Q3 ii)

# poisson distribution ----
x <- 0:10
y <- dpois(x, lambda=2)
plot(x, y, pch=16, ylab="pmf", xlab="outcome")

# Pr(X<=3) - long unnecessary version
tot_sum <- 0
for (i in 0:3) {
    tot_sum <- tot_sum + (((2^i) * exp(-2)) / factorial(i))
}

# Pr(X=4)
dpois(4, lambda=2)
# Pr(X<=3)
sum(dpois(0:3, lambda=2))
# or equivalent:
ppois(3, lambda=2)


# rpois() - simulate poisson random nums
x <- rpois(1000, lambda=2)
x
hist(x)

# fixed set of random nums
set.seed(123)
x <- rpois(10, lambda=2)
y <- rpois(10, lambda=2)
x == y  # not all equal
x
# reset random seed
set.seed(123)
z <- rpois(10, lambda=2)
x == z  # ARE all equal
z


# Q4 

# exponential distribution ----
x <- seq(0, 5, 0.01)
y <- dexp(x, rate=2)
plot(x, y, type="l", ylab="pdf", xlab="outcome")

# calculate probability from pdf - area under curve between limits
integrate(dexp, lower=0, upper=1, rate=2)


# Q5 

## normal distribution ----
x <- seq(-3, 3, 0.1)
y <- dnorm(x, mean=0, sd=1)
plot(x, y, type="l", ylab="pdf", xlab="outcome")

# Pr(2 <= X <= 3)
integrate(dnorm, lower=2, upper=3, mean=0, sd=1)
pnorm(3) - pnorm(2)

# Pr(-1.96 <= X <= 1.96)
integrate(dnorm, lower=-1.96, upper=1.96, mean=0, sd=1)
pnorm(1.96) - pnorm(-1.96)


# Q6

## Central limit theorem ----
# for ANY distribution with finite expected value and variance, the sample mean
# of the random samples from that distribution tends to be normally distributed

# eg. negative binomial dist (ie not normal!)
# plot 1000 negative binomial random nums w r=1, p=0.2
y <- rnbinom(1000, 1, 0.2)
hist(y)
# not normal!

# generate 3000 negative binomial random nums
# and put them into a 1000 by 30 matrix
y <- matrix(rnbinom(30*1000, 1, 0.2), nr=1000, nc=30)

# calculate row mean (sample mean)
y.row.mean <- apply(y, 1, mean)

# plot histogram of these 1000 row means
hist(y.row.mean)  # normal!

