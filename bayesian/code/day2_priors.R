## Bayesian stats 2 - prior ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/bayesian/code")


# Lecture ----

Beta_func <- function(a,b) {
    curve(dbeta(x, shape1=a, shape2=b), from=0, to=1,
          main=bquote(paste(alpha, " = ", .(a), " | ", beta, " = ", .(b), sep="")),
          ylab="Density")
    abline(v=a/(a+b),col="red",lty=3)
}

## symmetrical beta
a <- b <- c(1,5,10,100)
par(mfrow=c(2,2))
for(i in 1:length(a)) {
    Beta_func(a=a[i], b=b[i])
}

## U shape
a <- c(0.8, 0.1, 0.2, 0.2, 0.8, 0.8)
b <- c(0.8, 0.1, 0.8, 0.1, 0.9, 0.1)
par(mfrow=c(2,3))
for(i in 1:length(a)) {
    Beta_func(a=a[i], b=b[i])
}

## n shape  - fill in later from lecture slides
a <- c(1, 50, 2, )



# Prior, likelihood, unnormalised posterior, and posterior - practical ----

rm(list=ls())

# _**SCENARIO - part 1**
#     Your data will be now an alignment 12s RNA gene sequences from human and orangutan. 
# You have checked this alignment and you know that there are a total of $n = 948$ nucleotides.
# When you compare the two sequences, you can count the differences to estimate how closely related they are. In total, you observe $x = 90$ differences.
# 
# Now, we want to be able to estimate the molecular distance, $d$, 
# between the two sequences, which will help us understand how closely related these two species are. There are different models of nucleotide substitution that we could use, but we will focus on the simplest one based on the assumption that human and orangutan are quite similar: we will use the Jukes and Cantor (JC69) model.
# 
# _**QUESTION 1**_
#     Write down the posterior distribution in a Bayesian framework (i.e., prior, likelihood, marginal likelihood). Find out what your parameter of interest is and what data you have. 

# param of interest = substitution rate, mu, for JC69 model
# data = num differences,x / total sites,n
x = 90
n = 948


# Likelihood function under the JC69 model
L_d <- function(d, x, n){
    return( (3/4 - 3*exp(-4*d/3)/4)^x * (1/4 + 3*exp(-4*d/3)/4)^(n - x) )
}

# Prior function on my parameter of interest.
# We will assume that an exponential distribution 
# fits best and that the mean will be 0.2
prior_d <- function(d, mu){
    return( exp(-d/mu) / mu )
}


# define the unnormalised posterior
    
# Unnormalised posterior = prior x likelihood
unnorm_post <- function(d, mu, x, n) {
    return(prior_d(d=d , mu=0.2) * L_d(d=d , x=90, n=948))
}


# Use the `integrate` function to find the normalising constant C and then 
# write the function for the posterior distribution. 

marginal_likelihood <- integrate( f=Vectorize(unnorm_post), 
                                  lower=0, upper=Inf, abs.tol = 0, 
                                  mu = 0.2, x=90, n=948)
marginal_likelihood
# C = normalising constant (ie multiply by 1/marginal_likelihood (easier) == divide by marginal_likelihood)
C <- (1 / marginal_likelihood[[1]])


post_func <- function(d, mu, x, n, C) {
    return(C * unnorm_post(d, mu, x, n))
}

# compute posterior, eg
# post_func(d=0.1, mu=0.2, x=90, n=948, C=C)


## Plot the posterior and the prior together. What can you tell about your Bayesian inference?

curve(post_func(d=x, mu=0.2, x=90, n=948, C=C), from=0, to=1, ylab="Density", col="red", lty=3)
curve(prior_d(d=x, mu=0.2), add=T)
legend(x="topright", legend=c("Prior", "Posterior"), col=c("black", "red"), 
       lty=c(1,3))
# Bayesian inference successful - now have narrow CIs - have ideniifies likely 
# region of vals of d (molecular distance)


# What is the probability that your parameter of interest, $d$, is larger than 0.2?

# integrate posterior function between 0.2 and Inf -> get area under curve - 
# ie prob of d being 0.2 or above
integrate( f=Vectorize(post_func), 
           lower=0.2, upper=Inf, abs.tol = 0, 
           mu=0.2, x=90, n=948, C=C)
# v small chance!
