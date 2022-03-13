## Evolutionary modelling 3 - Gene Drive ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/evo_modelling/code")

require(doParallel)  # for parallelised Monte Carlo simulations


## Gene drive simulator ----

# Wild type = WT = 1
# Transgene = TG = 0

sim_gene_drive <- function(q0=0.05, d=0.6, t=10, N0=500, R0=2, M=500) {
    # q0 = init TG freq, d=transmission rate TG allele, N0=init pop size,
    # M and R0 = params for Beverton-Holt model
    
    # check initial params
    if (q0<=0 || q0>0.5) {
        stop("Please make sure that 0<q0<0.5!")
    }
    if (d<=0.5 || d>=1) {
        stop("please make sure that 0.5<d<1!")
    }
    
    # INNER FUNCTIONS
    # Beverton-Holt model
    bh <- function(N, R0, M) { 
        return(ceiling(R0*N / (1+N/M)))
    }
    # calculates genotype counts (00, 01, 11)
    count_genotype <- function(x) {
        temp <- apply(x, 2, sum)
        return(c(sum(temp==0), sum(temp==1), sum(temp==2)))
    }
    
    # Initialisation
    population <- list()
    length(population) <- t + 1
    names(population) < rep(NA, t+1)
    for (i in 1:length(population)) {
        names(population[i] <- paste(c("Generation", i-1), collapse=""))
    }
    
    # keep track of pop size and freq of TG over time as vectors
    population.size <- rep(NA, t+1)
    TG.freq <- rep(NA, t+1)
    
    # initial pop size and TG freq
    population.size[1] <- N0
    TG.freq[1] <- q0
    
    # release q0 transgenic mosquitos which carry 01 heterozygote
    # so at gen 0 there are (N0-k) WT mosquitos w 00 homozygotes
    k <- ceiling(2*N0*q0)
    population[[1]] <- cbind(matrix(c(0, 0), nr=2, nc=N0-k), 
                             matrix(c(0, 1), nr=2, nc=k))
    
    # calculate genotype counts 
    genotype <- count_genotype(population[[1]])


    # Propagation
    for (i in 1:t) {
        
        # calculate new pop size (only genotype[1] and genotype[2] sill survive to adulthood)
        population.size[i+1] <- bh(N=(genotype[1]+genotype[2]), R0, M)
        
        # early exit condition 1 - if pop size drops to 1
        if (population.size[i+1] <= 1) {
            print(paste(c("The population crashed after generation ", i-1), collapse=""))
            return(list(population=population[1:i], population.size=population.size[1:i],
                        TG.freq=TG.freq[1:i]))
        }
        
        # early exit condition 2 - if no more TG allele
        if (genotype[2] + genotype[3] == 0) {
            print(paste(c("The TG allele went extinct at generation ", i-1), collapse=""))
            return(list(population=population[1:i], population.size=population.size[1:i],
                        TG.freq=TG.freq[1:i]))
        }
        
        # calculate TG gametic freq
        TG.gametic.freq <- d * genotype[2] / (genotype[1] + genotype[2])
        
        # sample next gen
        population[[i+1]] <- matrix(sample(0:1, size=2*population.size[i+1],
                                           prob=c(1-TG.gametic.freq, TG.gametic.freq),
                                           replace=TRUE), nr=2)
        
        # calculate new genotype counts and TG freq
        genotype <- count_genotype(population[[i+1]])
        TG.freq[i+1] <- (0.5*genotype[2] + genotype[3]) / population.size[i+1]
        
    }
    
    return(list(population=population, population.size=population.size, TG.freq=TG.freq))
}


## Problem 1 ----

# given N0=500, M=500, R0=2
# our first construct has transmission rate d=0.6
# releasing freq q0=5%

# what is expected TG freq after t=50 gens?
# can you detect any pop decline?

# sim_gene_drive(N0=500, M=500, R0=2, d=0.6, q0=0.05, t=50)

# Monte Carlo:
result_q <- rep(NA, 1000)  # final TG freq
result_N <- rep(NA, 1000)  # final pop size

for (i in 1:1000) {
    temp <- sim_gene_drive(N0=500, M=500, R0=2, d=0.6, q0=0.05, t=50)
    result_q[i] <- temp$TG.freq[51]
    result_N[i] <- temp$population.size[51]
}

mean(result_q)
sd(result_q)
mean(result_N)
sd(result_N)

hist(result_q, xlab="final TG freq after 50 gens")
hist(result_N, xlab="final pop size after 50 gens")

?makeCluster
## Same problem but using doParallel package:
cl <- makeCluster(40)
registerDoParallel(cl)
result <- foreach(i=1:5000, .combine="rbind") %dopar% {
    temp <- sim_gene_drive(N0=500, M=500, R0=2, d=0.6, q0=0.05, t=50)
    return(c(temp$TG.freq[51], temp$population.size[51]))
}
stopCluster(cl)
result_q <- result[,1]
result_N <- result[,2]

mean(result_q)
sd(result_q)
mean(result_N)
sd(result_N)

hist(result_q, xlab="final TG freq after 50 gens")
hist(result_N, xlab="final pop size after 50 gens")

# good that TG freq is higher than releasing freq (q0) -> TG spreading!
# but little impact on pop size - mean of 480 at end compared to start/carrying capacity 500


## Problem 2 - Releasing strategy ----

# given same pop as above
# if releasing freq of transgene too low - may not survive/spread
# even though TG can spread super-Mendelian (drive) - still subject to drift
# releasing freq must be high enough to overcome first few gens of drift

# want to find min releasing freq to ensure TG can survive at least t=20 gens
# w 98%+ confidence

# hint: survival probability approximated by proportion of runs w non-0
# freq at end - repeat for range of q0: 0.4% <= q0 <= 2%

# Test multiple values of initial releasing strategy (q0 - freq of 
# mosquitos released) from 0.4% to 2%:
initial_freq <- seq(0.004, 0.02, 0.004)
cl <- makeCluster(8)
registerDoParallel(cl)
result <- rep(NA, length(initial_freq))
for (i in 1:length(initial_freq)) {
    temp_result <- foreach(j=1:5000, .combine="c") %dopar% {
        temp <- sim_gene_drive(q0=initial_freq[i], d=0.6, t=20, N0=500, M=500, R0=2)
        # final TG freq
        return(temp$TG.freq[length(temp$TG.freq)])
    }
    # see how many runs out of the 5000 have non-zero final TG freq = survival prob
    result[i] <- sum(temp_result>0)
}
stopCluster(cl)
plot(initial_freq, result/5000, type="l", 
     xlab="Initial TG freq", ylab="Survival prob after 20 gens")
abline(h=0.98, col="red", lty=2)  # 98%

# so if only releasing 0.5% mosquitos (5 TG mosquitos in pop of 500) w TG then
# unlikely for TG to persist
# for 98% threshold - need release rate of at least ~1.2 ish%


## Problem 3 - Construct design ----

# given same pop profile
# choose reasonable releasing freq (based on problem 2)

# lab is developing new (and potentially stronger) TG construct

# model effect of d on pop suppression

# what is min transmission rate d required if aiming to 
# reduce mosquito pop by 40% in t=30 gens?

transmission_rate <- seq(0.6, 0.85, 0.05)
cl <- makeCluster(8)
registerDoParallel(cl)

result <- foreach(i=1:length(transmission_rate), .combine="c") %dopar% {
    temp_result <- rep(NA, 5000)
    for (j in 1:length(temp_result)) {
        temp <- sim_gene_drive(q0=0.03, d=transmission_rate[i], 
                               t=20, N0=500, M=500, R0=2)
        temp_result[j] <- temp$population.size[length(temp$population.size)]
    }
    return(mean(temp_result))
}
stopCluster(cl)

plot(transmission_rate, result, type="l", ylab="final pop size after 30 gens")
abline(h=300, col="red", lty=2)

# gene-drive w higher d will suppress pop in more severe way
# if aim to reduce pop by 40% (want final pop size of 300) -> need 
# transmission rate (d) ~ 0.76 (76%)


## Problem 4 - Targeting different pop profiles ----

# a new TG w d=0.75 going to be released in 2 distinct pops of same size N0=500
# pop A has R0 = 2, M = 500
# pop B has R0 = 6, M = 100

# note: both pops have same carrying capacity (R0-1)*M, but pop B has 
# much higher intrinsic growth rate (R0)

# evaluate performance of this construct on these 2 pops in terms 
# of pop suppression (focus on first 30 gens)

# EXPECT: construct efficacy will be lower in pop w much higher growth rate

cl <- makeCluster(8)
registerDoParallel(cl)
# pop A: R0=2, M=500
result_A <- foreach(i=1:5000, .combine="rbind") %dopar% {
    temp <- sim_gene_drive(q0=0.03, d=0.75, t=30, N0=500, M=500, R0=2)
    return(temp$population.size)
}
# pop B: R0=6, M=100
result_B <- foreach(i=1:5000, .combine="rbind") %dopar% {
    temp <- sim_gene_drive(q0=0.03, d=0.75, t=30, N0=500, M=100, R0=6)
    return(temp$population.size)
}
stopCluster()

# plot pop size over time
plot(0:30, apply(result_A, 2, mean), type="l", ylim=c(300, 500),
     ylab="Population size", xlab="Generations")
lines(0:30, apply(result_B, 2, mean), lty=2, col="red")
legend("topright", legend=c("d=0.75", "R0=2", "M=500", "R0=6", "M=100"), 
       col=c(1,1,2), lty=c(NA,1,2))

# pop w higher growth rate (R0) - stronger resistance to TG - less pop reduction


## Problem 5 - Equilibrium freq ----

# theoretical derivations shown there is equilib TG freq (drive component 
# "driving" TG freq up but TG homozygotes lethal - lost from pop)

# same pop profile N0=500, M=500, R0=2

# show that, given a value of d (d = 0.6 eg), the final (equilib) TG freq in
# t=50 gens does not depend on initial freq

# comment on the equilib TG freq

cl<-makeCluster(8)
registerDoParallel(cl)
initial_freq <- seq(0.05, 0.45, 0.01)
result <- foreach(i=1:length(initial_freq), .combine="rbind") %dopar% {
    temp <- sim_gene_drive(q0=initial_freq[i], d=0.6, t=50, N0=500, R0=2, M=500)
    return(temp$TG.freq)
}
stopCluster(cl)

matplot(0:50, t(result), type="l", xlab="Generations", ylab="TG freq")
legend("topright", legend="d=0.6")

# all converge to TG freq ~ 0.2 in 50 gens regardless of init freq
# independent of initial TG freq 
# - depends only on d: an increase of 0.1 in d -> increase of 0.2 in equilib TG freq

