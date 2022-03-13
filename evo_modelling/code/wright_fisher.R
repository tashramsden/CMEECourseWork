## Evolutionary modelling 1 - Wright-Fisher ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/evo_modelling/code")


## Genetic Drift Simulator - Wright-Fisher ----

sim_genetic_drift <- function(p0=0.5, t=10, N=10) {
    # p0 = initial freq of allele 0, t = time in gens, N = pop size
    
    # Initialisation
    # population = list containing all allelic configs from gen 0 to t
    population <- list()
    length(population) <- t + 1
    names(population) < rep(NA, t+1)
    for (i in 1:length(population)) {
        names(population[i] <- paste(c("Generation", i-1), collapse=""))
    }
    # keep track of allele freq over time as a vector
    allele.freq <- rep(NA, t+1)
    
    # at gen 0 there are 2*N*p0 copies of allele 0
    # shuffle these alleles and assign into 2xN matrix
    k <- ceiling(2*N*p0)
    population[[1]] <- matrix(sample(c(rep(0, k), rep(1, 2*N-k))), nr=2)
    
    # initial allele freq
    allele.freq[1] <- sum(population[[1]] == 0) / (2*N)
    
    
    # Propagation
    for (i in 1:t) {
        # sample alleles for next gen based on allele freq at current gen
        population[[i+1]] <- matrix(sample(0:1, size=2*N, 
                                    prob=c(allele.freq[i], 1-allele.freq[i]),
                                    replace=TRUE), nr=2)
        # allele freq at next gen
        allele.freq[i+1] <- sum(population[[i+1]] == 0) / (2*N)
    }
    
    # Outputs
    return(list(population=population, allele.freq=allele.freq))
}

# sim_genetic_drift()

# approximate allele freq using Monte Carlo simulation
# with N=200, p0=0.5, t=10

result_MC <- rep(NA, 10000)
for (i in 1:length(result_MC)) {
    # save final allele freq each time (t+1 = 11)
    result_MC[i] <- sim_genetic_drift(p0=0.5, N=200, t=10)$allele.freq[11] 
}

hist(result_MC)
mean(result_MC)  # mean allele freq == init allele freq
var(result_MC)  # "true" answer according to formula by Waples (1989) == 0.0061


## Drift and effective pop size ----

# create emtpy result matrices
result_N20<-matrix(nc=51, nr=30)
result_N200<-result_N20
# run sims
for (i in 1:nrow(result_N20)) {
    result_N20[i,]<-sim_genetic_drift(p0=0.5, N=20, t=50)$allele.freq
    result_N200[i,]<-sim_genetic_drift(p0=0.5, N=200, t=50)$allele.freq
}
# plot 1
matplot(0:50, t(result_N20), type='l', 
        xlab='generations', ylab='allele freq', 
        main='allele freq trajectories, N=20',
        lwd=2, ylim=c(0,1))
abline(h=0.5, col='grey', lty=2)
# plot 2
matplot(0:50, t(result_N200), type='l', 
        xlab='generations', ylab='allele freq', 
        main='allele freq trajectories, N=200',
        lwd=2, ylim=c(0,1))
abline(h=0.5, col='grey', lty=2)


# What is the distribution of persistence time of an allele, if p0=0.05, N=100? ----

sim_genetic_drift_persistence <- function(p0=0.5, N=50) {
    persistance_time <- 0
    k <- ceiling(2*N*p0)
    population <- matrix(sample(c(rep(0, k), rep(1, 2*N-k))), nr=2)
    
    # initial allele freq
    allele.freq <- sum(population == 0) / (2*N)
    
    # Propagation
    # exit loop if fixed/extinct
    while (allele.freq > 0 & allele.freq < 1) {
        population <- matrix(sample(population, size=2*N, replace=TRUE), nr=2)
        allele.freq <- sum(population==0) / (2*N)
        persistance_time <- persistance_time + 1
    }
    
    return(persistance_time)
}

# sim_genetic_drift_persistence(p0=0.05, N=100)

# Monte-Carlo - persistence time for p0=0.05, N=100 (p0 minor allele (low freq))
persistence_time <- rep(NA, 10000)
for (i in 1:length(persistence_time)) {
    persistence_time[i] <- sim_genetic_drift_persistence(p0=0.05, N=100)
}

hist(persistence_time)

mean(persistence_time)
var(persistence_time)  # huge variance
# mean persistence time ~75 gens - but huge variance - distribution v skewed


# Effective pop size ----
# estimate Ne based on temporal changes in allele freq (big pop=less change, small pop=more change)

# eg assume we have 5000 loci (simulation repeats)
# at gen 40, t = 0, x0 = allele freq across the 5000 loci
# at gen 50, xt = allele freq across loci at this time
# 10 gens apart

# true pop size N=200, want to re-estimate it (Ne)

x0 <- rep(NA, 5000)
xt <- rep(NA, 5000)

t0 <- 40
t_end <- 50

for (i in 1:length(x0)) {
    temp_sim <- sim_genetic_drift(p0=0.5, N=200, t=50)
    x0[i] <- temp_sim$allele.freq[t0+1]
    xt[i] <- temp_sim$allele.freq[t_end+1]
}

# pairs <- rbind(x0, xt)  # just to see the pairs together (ie allele freq at x0 and xt for each simulation)

# The Fa statistic - standardised change in allele freq between x0 and xt
Fa <- (x0-xt)^2 / (x0*(1-x0))  # note can be xt-x0 or x0-xt - squared so no diff - not interesting in direction of change only magnitude
# overall Fa statistic across all loci (repeated sims)
mean(Fa)

# estimate effective pop size, Ne
# t = 10 (ie time separation between x0 and xt)
t_diff = t_end - t0
Ne <- t_diff / (2*mean(Fa))
Ne  # v close to real pop size

