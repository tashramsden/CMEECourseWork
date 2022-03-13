## Maximum likelihood - day 5 ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/max_likelihood/code")

library(BB)

# Practical Q3 - ANOVA and mixed models ----

dat <- read.csv("../data/drug.csv", header=T)
names(dat)

# treatemnt = explanatory var: 0=control, 1=treatment

# primary goal study effect of treatement (fixed effect) 
# need to estimate its coef and CI

# treat replicate as the random effect

# mixed effect model:
# yij = a + b*treatment_ij + tao_j + e_ij

# tao = random effect (4 here - one for each replicate) -> want to estimate 
# sigma_random to summarise among-replicate variation

# within-replicate likelihood
within.rep.like <- function(parm, dat) {
    #define data
    y <- dat$y
    treatment <- dat$treatment == 1
    
    f <- function(tau) {
        prod(dnorm(y, mean = parm[1] + parm[2] * treatment + tau,
                   sd = parm[3])) * dnorm(tau, mean=0, sd=parm[4])
    }
    f <- Vectorize(f, "tau")
    
    return(integrate(f, low=-Inf, upper=Inf, subdivisions=4000L)$value)
}

# overall likelihood is the product of 4 within-replicate likelihoods

# overall log-likelihood across 4 replicates 
overall.log.like <- function(parm, dat) {
    temp1 <- within.rep.like(parm, dat[dat$replicate==1,])
    temp2 <- within.rep.like(parm, dat[dat$replicate==2,])
    temp3 <- within.rep.like(parm, dat[dat$replicate==3,])
    temp4 <- within.rep.like(parm, dat[dat$replicate==4,])
    return(log(temp1) + log(temp2) + log(temp3) + log(temp4))
}

# maximise the overall log-likelihood to find the param estimates
initial.parm <- c(40, 2.3, 5, 6)
lower <- c(-50, -50, 0.001, 0.001)
upper <- c(100, 100, 100, 100)

# maximise with optim()
M <- optim(initial.parm, overall.log.like, dat=dat, method="L-BFGS-B",
           lower=lower, upper=upper, control=list(fnscale=-1), hessian=T)
M$par

# maximise with spg() from library BB
spg(initial.parm, overall.log.like, dat=dat, lower=lower, upper=upper,
    control=list(maximize=T))

# b_max = 2.33 => ie the treatment improves the health score by 2.33 units
# 3rd and 4th coefs are the sd ests sigma and sigma_random
# bigger proportion of variation contributed by the indivs (5.73)
# and 3.04 variation explained by the random effect (replicate group)
