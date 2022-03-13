## Maximum likelihood - day 4 - Confidence intervals----

rm(list=ls())
# setwd("Documents/CMEECourseWork/max_likelihood/code")

# Lecture 4 ----
# linear regression - test for intercept - Likelihood ratio test

# read data
recapture.data <- read.csv("../data/recapture.csv")

# scatterplot
plot(recapture.data$day, recapture.data$length_diff)

# M1 (from yesterday) ----
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

M1 <- optim(par=c(1,1), regression.no.intercept.log.likelihood,
            dat=recapture.data, method='L-BFGS-B',
            lower=c(-1000,0.0001), upper=c(1000,10000),
            control=list(fnscale=-1), hessian=T)


# M1 has 2 params: b and sigma
# plot log-likelihood surface against b and sigma ----
# bivariate function => 3D plot

?persp()

# define range of params to be plotted
b <- seq(2, 4, 0.1)
sigma <- seq(2, 5, 0.1)

# log-likelihood value stored in a matrix
log.likelihood.value <- matrix(nr=length(b), nc=length(sigma))

# compute the log-likelihood value for each pair of params
for (i in 1:length(b)) {
    for (j in 1:length(sigma)) {
        log.likelihood.value[i,j] <- regression.no.intercept.log.likelihood(parm=c(b[i], sigma[j]),
                                                                            dat=recapture.data)
    }
}

# interested in the relative log-likelihood value 
# relative to the peak (maximum)
rel.log.likelihood.value <- log.likelihood.value - M1$value

# function for 3D plot
persp(b, sigma, rel.log.likelihood.value, 
      theta=30, phi=20, xlab="b", ylab="sigma", zlab="rel.log.likelihood.value",
      col="grey")
# not super informative


# contour plot ----
contour(b, sigma, rel.log.likelihood.value,
        xlab="b", ylab="sigma", xlim=c(2.5, 3.9), ylim=c(2.0, 4.3),
        levels=c(-1:-5, -10), cex=2)
# draw a cross to indicate the maximum
points(M1$par[1], M1$par[2], pch=3)

# draw -1.92 line (circle) on the contour map
contour.line <- contourLines(b, sigma, rel.log.likelihood.value,
                             levels=-1.92)[[1]]
lines(contour.line$x, contour.line$y, col="red", lty=2, lwd=2)

# draw -2.99 line (circle) on the contour map
contour.line <- contourLines(b, sigma, rel.log.likelihood.value,
                             levels=-2.99)[[1]]
lines(contour.line$x, contour.line$y, col="red", lty=2, lwd=2)


# CI: approximate normality of MLE ----

# optim() 2D param space: b and sigma
# with the HESSIAN MATRIX
result <- optim(par=c(1,1), regression.no.intercept.log.likelihood,
                method='L-BFGS-B',
                lower=c(-1000,0.0001), upper=c(1000,10000),
                control=list(fnscale=-1), dat=recapture.data, hessian=T)
result
# hessian matrix:
result$hessian

# the variance-covariance matrix is the negative of the inverse of the hessian matrix:
# use solve() function
var.cov.matrix <- (-1) * solve(result$hessian)
var.cov.matrix  # variance-covariance structure

# for b alone: 95% CI = 3.1629 +/- 1.96*sqrt(0.04227)


## Practical 4 ----

# Q1 ----

coin.log.likelihood <- function(p, y=35, n=50){
    log(choose(n, y)*p^y*(1-p)^(n-y))
}

p <- seq(0.1, 0.9, 0.01)
log.likelihood.value <- coin.log.likelihood(p=p)
plot(p, log.likelihood.value, type="l", ylab="log-likelihood")

## zoom in a bit to maximum
p <- seq(0.5, 0.9, 0.01)
log.likelihood.value <- coin.log.likelihood(p=p)
plot(p, log.likelihood.value, type="l", ylab="log-likelihood")

# plot line 1.92 below the max value of log likelihood
max_p <- optimize(coin.log.likelihood, interval=c(0,1), maximum=TRUE)$maximum
max_value <- coin.log.likelihood(max_p)
abline(h = (max_value-1.92), col="red", lty=2)

f <- function(p) {
    coin.log.likelihood(p) - coin.log.likelihood(max_p) + 1.92  # = distance between red line and curve (only ABOVE the red line)
}

# can see there are 2 points that lines intersect:

# upper CI
# must be between 0.7 (max of peak) and a big num eg 0.9 (see from graph)
uniroot(f, interval=c(0.7, 0.9))
# upper CI = 0.8148

# lower CI
uniroot(f, interval=c(0.1, 0.7))
# lower CI = 0.5618

abline(v=0.5651833, col="red", lty=2)
abline(v=0.8148, col="red", lty=2)


# Q3 ----
# profile likelihood with flowering.txt

rm(list=ls())

# read in data
flowering <- read.table("../data/flowering.txt", header=T)

## FROM YESTERDAY
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

M2 <- optim(par=c(0,0,0,0), 
            logistic.log.likelihood.int,
            dat=flowering, 
            control=list(fnscale=-1))
#### END: FROM YESTERDAY

## want to find the 95% CI for b (the coef of Flowers) ----

M2
# ML estimate for b = -0.07889
# if we move b away from this value, the log-likelihood decreases

# # THE WRONG APPROACH. SET b=-0.03, AND KEEP OTHERS AT THEIR MLE
# logistic.log.likelihood.int(parm=c(M2$par[1], -0.03, M2$par[3],
#                                    M2$par[4]), dat=flowering)
# ## NO!!! - there is no guarantee that at b=-0.03 the log-likelihood is maxed for a,c and d

# CORRECT APPROACH:
# fix b at a certain value, re-maximise (partially) the log-likelihood => profile likelihood

# profile log-likelihood for b (a function of b)
profile.log.likelihood<-function(b) {
    f <- function(parm_acd) {
        # parm_acd is a vect of length 3 for the 3 remaining params 
        # f is maximised wrt these 3 params
        logistic.log.likelihood.int(c(parm_acd[1], b,
                                      parm_acd[2], parm_acd[3]), dat=flowering)
    }
    # optimise a,c and d for this value of b
    temp <- optim(c(0, 0, 0), f, control=list(fnscale=-1))
    return(temp$value)
}

# profile log-likelihood value for b b=-0.03
profile.log.likelihood(b = -0.03)

# now evaluate the profile log-likelihood for b in the neighbourhood of b_hat (ie b when log-like maxed)

# plot the profile log-likelihood for a range of b, around its MLE
# (NOTE: each point involves a maximisation - computationally intensive)
b <- seq(-0.19, -0.004, 0.002)
profile.log.likelihood.value <- rep(NA, length(b))
for (i in 1:length(b)) {
    profile.log.likelihood.value[i] <- profile.log.likelihood(b[i])
}
# plot the profile log-likelihood
plot(b, profile.log.likelihood.value, type='l')
# draw a horizontal line which is 1.92 units below the maximum
abline(h=M2$value-1.92, col='red', lty=2)

# since just interested in one param here - the 95% CI for b is the region 
# where the profile log-likelihood above the red line (ie no more than 1.92 below the max)
# (can use same principle to profile 2/more params - see practical notes)


# find same by assuming normality ----
M2 <- optim(c(0,0,0,0), logistic.log.likelihood.int,
            dat=flowering, control=list(fnscale=-1), hessian=T)
M2$hessian

vcov <- (-1)*solve(M2$hessian)
vcov
# upper CI
M2$par[2] + 1.96*sqrt(vcov[2,2]) #vcov[2,2] = variance of b
# lower CI
M2$par[2] - 1.96*sqrt(vcov[2,2])


# do the same but w glm! ----
glm.M1 <- glm(State ~ Flowers+Root, family=binomial, data=flowering)
summary(glm.M1)

glm.M2 <- glm(State ~ Flowers*Root, family=binomial, data=flowering)
summary(glm.M2)
# residual deviance from this = 2*max value from M2
M2$value*2

anova(glm.M1, glm.M2, test="LRT")
# deviance = D from yesterday

# profile likelihood - same as nums from plot above
confint(glm.M2, 2, trace=T)
