## Evolutionary modelling 2 - Drift and Migration ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/evo_modelling/code")
require(doParallel)  # for parallelised Monte Carlo simulations


## Drift-migration simulator ----

sim_drift_migration <- function(N.A=100, N.B=100, p0.A=0.5, p0.B=0.5,
                                t=10, m.A=0.2, m.B=0.2) {
    
    population.A <- list()
    length(population.A) <- t + 1
    
    population.B <- list()
    length(population.B) <- t + 1
    
    names(population.A) < rep(NA, t+1)
    names(population.B) < rep(NA, t+1)
    
    for (i in 1:length(population.A)) {
        names(population.A[i] <- paste(c("Generation", i-1), collapse=""))
        names(population.B[i] <- paste(c("Generation", i-1), collapse=""))
    }
    
    # keep track of allele freqs over time as a vector
    allele.freq.A <- rep(NA, t+1)
    allele.freq.B <- rep(NA, t+1)
    
    # Initialise pops
    k.A <- ceiling(2*N.A*p0.A)
    population.A[[1]] <- matrix(sample(c(rep(0, k.A), rep(1, 2*N.A-k.A))), nr=2)
    
    k.B <- ceiling(2*N.B*p0.B)
    population.B[[1]] <- matrix(sample(c(rep(0, k.B), rep(1, 2*N.B-k.B))), nr=2)
    
    # initial allele freqs
    allele.freq.A[1] <- sum(population.A[[1]] == 0) / (2*N.A)
    allele.freq.B[1] <- sum(population.B[[1]] == 0) / (2*N.B)
    
    # propagation
    for (i in 1:t) {
        
        # gametic freqs
        # not same as allele freq - need to take migration into account
        # gamete freq for pop A is (1-m.A) of existing alle freq in this pop plus m.A of allele freq in pop B (moved from pop B to A)
        gametic.freq.A <- (1-m.A)*allele.freq.A[i] + m.A*allele.freq.B[i]
        gametic.freq.B <- (1-m.B)*allele.freq.B[i] + m.B*allele.freq.A[i]
        
        # sample alleles for next gen based on gametic freq after migration
        population.A[[i+1]] <- matrix(sample(0:1, size=2*N.A, 
                                             prob=c(gametic.freq.A, 1-gametic.freq.A),
                                             replace=TRUE), nr=2)
        population.B[[i+1]] <- matrix(sample(0:1, size=2*N.B, 
                                             prob=c(gametic.freq.B, 1-gametic.freq.B),
                                             replace=TRUE), nr=2)
        
        # allele freq at next gen
        allele.freq.A[i+1] <- sum(population.A[[i+1]] == 0) / (2*N.A)
        allele.freq.B[i+1] <- sum(population.B[[i+1]] == 0) / (2*N.B)
        
    }
    
    return(list(population.A=population.A, population.B=population.B,
                allele.freq.A=allele.freq.A, allele.freq.B=allele.freq.B))
    
}

sim_drift_migration()


# Fst over time ----

Fst_calc <- function(allele.freq.A, allele.freq.B) {
    X.ave <- (allele.freq.A + allele.freq.B) / 2
    Fst <- (allele.freq.A - allele.freq.B)^2 / (X.ave*(1 - X.ave))
    return(Fst)
}

sim_result <- sim_drift_migration(N.A=100, N.B=100, p0.A=0.1, p0.B=0.9,
                                  t=20, m.A=0.1, m.B=0.1)
# eg here -start w v diff pops - migration over time means they become more similar

Fst_over_time <- Fst_calc(sim_result$allele.freq.A, sim_result$allele.freq.B)

plot(1:21, Fst_over_time, xlab="Time", ylab="Fst")


# now w Monte Carlo - repeats
sims_Fst <- matrix(NA, 10000, 21)
for (i in 1:10000) {
    sim_result <- sim_drift_migration(N.A=100, N.B=100, p0.A=0.1, p0.B=0.9,
                                      t=20, m.A=0.1, m.B=0.1)
    # eg here -start w v diff pops - migration over time means they become more similar
    Fst_over_time <- Fst_calc(sim_result$allele.freq.A, sim_result$allele.freq.B)
    sims_Fst[i,] <- Fst_over_time
}

Fst_over_time <- apply(sims_Fst, 2, mean)
plot(0:20, Fst_over_time, xlab="Time", ylab="Fst", col="blue")


sims_Fst <- matrix(NA, 10000, 21)
for (i in 1:10000) {
    sim_result <- sim_drift_migration(N.A=100, N.B=100, p0.A=0.5, p0.B=0.5,
                                      t=20, m.A=0.1, m.B=0.1)
    # eg vs here -start w v similar pops - not v much migration - become more diff over time (still at end Fst low - ARE similar)
    Fst_over_time <- Fst_calc(sim_result$allele.freq.A, sim_result$allele.freq.B)
    sims_Fst[i,] <- Fst_over_time
}

Fst_over_time <- apply(sims_Fst, 2, mean)
plot(0:20, Fst_over_time, xlab="Time", ylab="Fst", col="red")


# Fst w diff migration rates ----
# Fst under two scenarios: with migration rate = 0.05, and migration rate = 0.1
# population sizes are the same, migration is symmetrical

# PAIRWISE FST
# LOCAL MULTI-CORE CLUSTER SETUP. 2000 LOCI
cl<-makeCluster(44)
registerDoParallel(cl)
# FIRST SCENARIO. MIGRATION RATE 0.05
result_m0.05<-foreach(i=1:2000, .combine='rbind') %dopar% {
        # SIM THE TWO POPULATIONS
        temp<-sim_drift_migration(p0.A=0.5, p0.B=0.5, N.A=1000, N.B=1000, t=50, m.A=0.05, m.B=0.05)
        # AVERAGE OF TWO ALLELE FREQ
        z<-(temp$allele.freq.A+temp$allele.freq.B)/2
        # FST, CHECK FORMULA
        FST<-(temp$allele.freq.A-temp$allele.freq.B)^2/(z*(1-z))
        return(FST)
    }
# SECOND SCENARIO. MIGRATION RATE 0.1
result_m0.1<-foreach(i=1:2000, .combine='rbind') %dopar% {
        # SIM THE TWO POPULATIONS
        temp<-sim_drift_migration(p0.A=0.5, p0.B=0.5, N.A=1000, N.B=1000, t=50, m.A=0.05, m.B=0.1)
        # AVERAGE OF TWO ALLELE FREQ
        z<-(temp$allele.freq.A+temp$allele.freq.B)/2
        # FST, CHECK FORMULA
        FST<-(temp$allele.freq.A-temp$allele.freq.B)^2/(z*(1-z))
        return(FST)
    }
stopCluster(cl)
dim(result_m0.05)
dim(result_m0.1)

# PLOT THE MEAN FST ACROSS 1000 RUNS (LOCI)
plot(0:50, apply(result_m0.05, 2, mean), xlab='generations', ylab='FST')
points(0:50, apply(result_m0.1, 2, mean), xlab='generations', ylab='FST', col='red', pch=3)
legend('bottomright', legend=c('N=1000, m=0.05', 'N=1000, m=0.1'), col=1:2, pch=c(1,3))


## Impact of migration on Ne estimation ----
# 5000 LOCI
x0<-rep(NA, 5000)
xt<-rep(NA, length(x0))
for (i in 1:length(x0)) {
    temp<-sim_drift_migration(p0.A=0.5, p0.B=0.5, N.A=200, N.B=2000, t=50, m.A=0.1, m.B=0.1)
    x0[i]<-temp$allele.freq.A[41]
    xt[i]<-temp$allele.freq.A[51]
}
# SO WE HAVE 5000 PAIRS OF x0 AND xt

# Fa
Fa<-(x0-xt)^2/(x0*(1-x0))
# OVERALL Fa STATISTIC
mean(Fa)
# Ne ESTIMATE
10/(2*mean(Fa))  # overestimate - due to migration
