## Maximum likelihood - practical 2 ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/max_likelihood/code")

# Lecture content ----

# Likelihood function:
# (coin toss - get 7 heads on 10 tosses)
binomial.likelihood <- function(p){
    choose(10,7)*p^7*(1-p)^3
}
# calculate likelihood at eg p=0.1
binomial.likelihood(p=0.1)
# plot likelihood for range of p values (between 0 & 1 - probability - bounded)
p<-seq(0, 1, 0.01)
likelihood.values <- binomial.likelihood(p)
plot(p, likelihood.values, type='l')

# more often - study log-likelihood
# reuse function above
log.binomial.likelihood <- function(p){
    log(binomial.likelihood(p=p))
}
# plot log-likelihood
p<-seq(0, 1, 0.01)
log.likelihood.values <- log.binomial.likelihood(p)
plot(p, log.likelihood.values, type='l')

# find value of p such that likelihood is maximised
optimize(binomial.likelihood, interval=c(0,1), maximum=TRUE)

optimize(log.binomial.likelihood, interval=c(0,1), maximum=TRUE)


## Tutorial - Q7 ----

# read data
recapture.data <- read.csv("../data/recapture.csv")

# scatterplot
plot(recapture.data$day, recapture.data$length_diff)

# PERSPECTIVE 1 (model the RESPONSE) 

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
    
    # MODEL ON Y. - vectorised
    # each y[i] is normally and independently distributed. with mean a+b*x[i]
    # and a common variance sigma^2. 
    # vectorised code:
    density <- dnorm(y, mean=a+b*x, sd=sigma, log=T)
    # the log-likelihood is the sum of the indiv log-density
    return(sum(density))
}

## or 

# PERSPECTIVE 2 (model the ERROR)

## SAME AS ABOVE APART FROM ONE SECTION:

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

# just to see what log-likelihood is when a=1, b=1, and sigma=1
regression.log.likelihood(c(1,1,1), dat=recapture.data)

# TO OPIMISE THE LOG-LIKELIHOOD FUNCTION IN R ----
# optimize() is one dimensional (ie for univariate only),
# optim() generalises to MULTI-DIMENSIONAL cases
optim(par=c(1,1,1),  # initial values for the params
      regression.log.likelihood,  # function to be optimised
      method='L-BFGS-B',  # optimisation algorithm (this one requires box-like upper and lower bounds vs nothing to specify for Nelder-Mead)
      lower=c(-1000,-1000,0.0001), upper=c(1000,1000,10000),  # lower and upper bounds of param space
      control=list(fnscale=-1), dat=recapture.data, hessian=T)  # fnscale=-1 means to maximise (default=minimise)
# can add more control params eg tolerance in control
# Hessian matrix provides info about var-cov structure of param ests
# BEST: try multiple sets of init params to ensure all converge to GLOBAL max


# # (of course can do same w built-in lm())
# m <- lm(length_diff ~ day, data=recapture.data)
# summary(m)  # intercept and slope give a and b
# abline(m)
# 
# n <- nrow(recapture.data)
# sqrt(var(m$residual)*(n-1)/n)  # sigma^2
