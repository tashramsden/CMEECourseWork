## Maximum likelihood - day 3 - Likelihood ratio test----

rm(list=ls())
# setwd("Documents/CMEECourseWork/max_likelihood/code")


# Lecture 3 ----
# linear regression - test for intercept - Likelihood ratio test

# read data
recapture.data <- read.csv("../data/recapture.csv")

# scatterplot
plot(recapture.data$day, recapture.data$length_diff)

# M2 ----
## MODEL FORM YESTERDAY - M2 (full/most complex model)
# log-likelihood for the params
# params have to be inputs as a vector (parm)
regression.log.likelihood<-function(parm, dat) {
    # define params: parm
    # 3 params: a, b, sigma. BE CAREFUL OF THE ORDER
    a <- parm[1]
    b <- parm[2]
    sigma <- parm[3]
    
    # define the data: dat
    # first column = x, second column = y
    x <- dat[,1]
    y <- dat[,2]
    
    # MODEL ON THE ERROR TERMS. - vectorised
    error.term <- (y-a-b*x)
    # error.term[i] ARE IID NORMAL, WITH MEAN 0 AND A COMMON VARIANCE sigma^2
    density <- dnorm(error.term, mean=0, sd=sigma, log=T)
    
    # the log-likelihood is the sum of the indiv log-density
    return(sum(density))
}

# taking regression.log.likelihood as M2 (full model)

# M1 ----
# log-likelihood function for M1 (WITHOUT AN INTERCEPT)
regression.no.intercept.log.likelihood<-function(parm, dat) {
    # define the params
    # NO INTERCEPT this time
    b <- parm[1]
    sigma <- parm[2]
    
    # define the data
    # SAME AS BEFORE
    x <- dat[,1]
    y <- dat[,2]
    
    # define the error term - no intercept here
    error.term <- (y-b*x)
    
    # REMEMBER THE NORMAL pdf?
    density <- dnorm(error.term, mean=0, sd=sigma, log=T)
    
    # log-likelihood is the sum of densities
    return(sum(density))
}


## Perform the likelihood-ratio test (LRT) ----
M1 <- optim(par=c(1,1), regression.no.intercept.log.likelihood,
            dat=recapture.data, method='L-BFGS-B',
            lower=c(-1000,0.0001), upper=c(1000,10000),
            control=list(fnscale=-1), hessian=T)
M2 <- optim(par=c(1,1,1), regression.log.likelihood,
            dat=recapture.data, method='L-BFGS-B',
            lower=c(-1000,-1000,0.0001), upper=c(1000,1000,10000),
            control=list(fnscale=-1), hessian=T)
# THE TEST STATISTIC D
D <- 2*(M2$value - M1$value)
D
# CRITICAL VALUE
qchisq(0.95, df=1)

# D < critical value => accept hypothesis that intercept is 0 at a=0.05


## Non-constant variance ----

# in this data - variance is increasing w day
# easily incorporated w MLE (vs not w built-in lm())

# Log-likelihood function: non-constant variance

regression.non.constant.var.log.likelihood<-function(parm, dat) {
    # define the params
    # SAME AS M1
    b <- parm[1]
    sigma <- parm[2]
    
    # define the data
    # SAME AS BEFORE
    x <- dat[,1]
    y <- dat[,2]
    
    # define the error term - no intercept here
    error.term <- (y-b*x)
    
    # sd is now x*sigma - non constant ----
    # ie st dev of error terms increases linearly w num of days
    density <- dnorm(error.term, mean=0, sd=x*sigma, log=T)
    
    # log-likelihood is the sum of densities
    return(sum(density))
}

# maximise the log-likelihood
# call it M4
M4 <- optim(par=c(1,1), regression.non.constant.var.log.likelihood,
            dat=recapture.data, method='L-BFGS-B',
            lower=c(-1000,0.0001), upper=c(1000,10000),
            control=list(fnscale=-1))
M4


## Practical Q4 ----

rm(list=ls())

# read in data
flowering <- read.table("../data/flowering.txt", header=T)
names(flowering)
str(flowering)
# state: alive (1) or dead (0)
# flowers = num flowers
# root = size of root

# visualise
par(mfrow=c(1,2))
plot(flowering$Flowers, flowering$State)
plot(flowering$Root, flowering$State)
# not v informative

# logistic log-likelihood 
# 2 args: parm is vector of params, dat is input dataset
logistic.log.likelihood <- function(parm, dat) {
    # define params
    a <- parm[1]
    b <- parm[2]
    c <- parm[3]
    
    # define response variable (first col of dat)
    State <- dat[,1]
    # and explanatory variables
    Flowers <- dat[,2]
    Root <- dat[,3]
    
    # model success probability, via expit transformation
    p <- exp(a + b*Flowers + c*Root) / (1 + exp(a + b*Flowers + c*Root))
    
    # the log-likelihood function
    log.like <- sum(State*log(p) + (1-State)*log(1-p))
    
    return(log.like)
}

# test
logistic.log.likelihood(c(0,0,0), dat=flowering)
# gives log-likelihood evaluated at a, b, c = 0


# maximise log-likelihood function w optim 
# use default method - a, b, c can be any real nums - do not need to impose bounds
M1 <- optim(par=c(0,0,0), 
            logistic.log.likelihood,
            dat=flowering, 
            control=list(fnscale=-1))
M1
# MLE for the params:
M1$par
# associated log-likelihood value:
M1$value


# now try model including an interaction between Flowers and Root
# pi = expit(a + b*Flowers_i + c*Root_i + d*Flowers_i*Root_i)

logistic.log.likelihood.int <- function(parm, dat) {
    # define params
    a <- parm[1]
    b <- parm[2]
    c <- parm[3]
    d <- parm[4]
    
    # define response variable (first col of dat)
    State <- dat[,1]
    # and explanatory variables
    Flowers <- dat[,2]
    Root <- dat[,3]
    
    # model success probability - WITH INTERACTION
    p <- exp(a + b*Flowers + c*Root + d*Flowers*Root) / (1 + exp(a + b*Flowers + c*Root + d*Flowers*Root))
    
    # the log-likelihood function
    log.like <- sum(State*log(p) + (1-State)*log(1-p))
    
    return(log.like)
}

# maximise log-likelihood function w optim 
M2 <- optim(par=c(0,0,0,0), 
            logistic.log.likelihood.int,
            dat=flowering, 
            control=list(fnscale=-1))
M2


# Likelihood ratio test for the interaction term at alpha=5% sig level

# THE TEST STATISTIC D
D <- 2*(M2$value - M1$value)
D
# CRITICAL VALUE
qchisq(0.95, df=1)

# D > critical value => reject M1 simpler model - interaction term is necessary
