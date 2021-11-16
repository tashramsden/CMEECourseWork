#### Coalescence theory ----

rm(list = ls())


## Intro ----

# Interested in size of 2 pops of Atlantic killer whales
# one migrating North and the other migrating South
# these 2 pops share a common ancestor but their current pop size is 
# hypothesised to be different

# 10 (diploid) samples from Northern pop and 10 from Southern
# each sample has genomic sequence of 50k bp
# each allele coded as 0 or 1 for the ancestral and derived states respectively

# Tasks:

# estimate effective op size, Ne, for each pop using Watterson's estimator and 
# Tajima's estimator of theta, assuming mutation rate of 1e-8

# calculate and plot the (unfolded) site frequency spectrum for each pop


## Data ----

data_N <- as.matrix(read.csv("../data/killer_whale_North.csv", 
                             stringsAsFactors = FALSE, header = FALSE,
                             colClasses = c("numeric")))
dim(data_N)

data_S <- as.matrix(read.csv("../data/killer_whale_South.csv", 
                             stringsAsFactors = FALSE, header = FALSE,
                             colClasses = c("numeric")))
dim(data_S)




## Estimates of effective pop size, Ne ----

# Ne = theta / (4 * N * mu)
# theta is genetic diversity - can be estimated w Tajima's and Watterson's:

## 1. Tajima's ----

# tajima's estimator (pi) - pairwise diffs = sum(d_ij) / (n(n-1)/2)
# d_ij is num of diffs between sequence i and j

# practice
# for short seq A and B, d_ij should be 2
# i = 1
short_seq_A <- c(0,0,0,1,1)
# j = 2
short_seq_B <- c(0,1,0,1,0)
# method 1
sum(short_seq_A != short_seq_B)
# method 2
# dif_counter = 0
# for (l in 1:length(short_seq_A)) {
#     if (short_seq_A[l] != short_seq_B[l]) {
#         dif_counter <- dif_counter + 1
#     }
# }
# method 3
# sum(abs(short_seq_A-short_seq_B))
# method 4
# sum(abs(short_seq_A-short_seq_B)^2)
## ALL THESE 4 METHODS ABOVE DO THE SAME


# for Northern pop:
n <- nrow(data_N)  # num samples (chromosomes)
pi_N = 0  # pairwise diffs for northern pop

for (i in 1:(nrow(data_N)-1)) {
    for (j in (i+1):nrow(data_N)) {
#       diffs <- sum(abs(data_N[i,] - data_N[j,]))  # does the same
        d_ij <- sum(data_N[i,] != data_N[j,])
        pi_N <- pi_N + d_ij
    }
}  
# pi_N =  1761

# divide by the nr of comparisons done
pi_N <- pi_N / ((n*(n-1))/2)
# Tajima's estimator = 9.26842

len = ncol(data_N)
Ne_N_pi <- pi_N / (4 * 1e-8 * len)
# effective pop size of Northern pop = ~4634


# for Southern pop:
n <- nrow(data_S)  # num samples (chromosomes)
pi_S = 0

for (i in 1:(nrow(data_S)-1)) {
    for (j in (i+1):nrow(data_S)) {
        d_ij <- sum(data_S[i,] != data_S[j,])
        pi_S <- pi_S + d_ij
    }
}  
# pi_S = 292

# divide by the nr of comparisons done
pi_S <- pi_S / ((n*(n-1))/2)
# Tajima's estimator = 1.5368

len = ncol(data_S)
Ne_S_pi <- pi_S / (4 * 1e-8 * len)
# effective pop size of Southern pop is 768.4211


# effective pop size of Southern pop (768) much smaller than 
# Northern (4634) according to Tajima's estimator


## 2. Watterson's ----

# watterson's estimator = S / sum(1/k) (k between 1 and n-1)
# S = num of segregating sites
# n samples

# Northern pop
S_N = 0
for (i in (1:ncol(data_N))) {
    if (length(unique(data_N[,i])) > 1) {
        S_N <- S_N + 1
    }
}
# 33

# # does the same as for loop above!
# freqs <- apply(data_N, 2, sum) / nrow(data_N)
# length(which((freqs>0)&(freqs<1)))

n = nrow(data_N)
watt_N <- S_N / sum(1/seq(1,n-1))
# Watterson's estimator = 9.3017

Ne_N_watt <- watt_N / (4 * 1e-8 * len)
# Ne = 4650.8486


## Southern pop

S_S = 0
for (col in (1:ncol(data_S))) {
    if (length(unique(data_S[,col])) > 1) {
        S_S <- S_S + 1
    }
}

n = nrow(data_S)
watt_S <- S_S / sum(1/seq(1,n-1))
# Watterson's estimator = 1.691

Ne_S_watt <- watt_S / (4 * 1e-8 * len)
# Ne = 845.6088

# Again, effective pop size of Southern pop (845) much smaller than 
# Northern (4650) according to Watterson's estimator


# summary ----
pop_and_estimator <- c("North (Tajima's)", "North (Watterson's)",
                       "South (Tajima's)", "South (Watterson's)")
theta <- c(pi_N, watt_N, pi_S, watt_S)  # genetic diversity
Ne <- c(Ne_N_pi, Ne_N_watt, Ne_S_pi, Ne_S_watt)  # effective pop size
summary <- data.frame(pop_and_estimator, theta, Ne)
print(summary)


## Site frequency spectrum ----

# practice!!
first_row <-  c(1,0,0,1,0)
second_row <- c(1,0,1,1,1)
third_row <-  c(1,0,1,0,1)
fourth_row <- c(1,1,1,0,1)
rows <- rbind(first_row, second_row, third_row, fourth_row)

apply(rows, 2, sum)   # allele counts
# based on above:
# see that 1 allele has freq 0
# none w freq 1
# 3 w freq 2
# 1 w frew 3
# freq:           0 1 2 3
# num of alleles: 1 0 3 1
# (from what printed, want to count how many of each num we get)
freqs <- apply(rows, 2, sum)   # allele counts

sfs <- rep(NA, nrow(rows)-1)
for (g in 1:length(sfs)) {
    sfs[g] <- sum(freqs==g)
}
sfs
##### end practice


## Northern pop
# allele freqs
derived_freqs <- apply(X=data_N, MAR=2, FUN=sum)
# compute SFS from the counts of derived allele freq
n <- nrow(data_N)
sfs_N <- rep(NA, n-1)
for (i in 1:length(sfs_N)) {
    sfs_N[i] <- sum(derived_freqs == i)
    # sfs_N[i] <- length(which(derived_freqs == i))  # same thing
}
sfs_N


## Southern pop
# allele freqs
derived_freqs <- apply(data_S, 2, sum)
# compute SFS from the counts of derived allele freq
n <- nrow(data_S)
sfs_S <- rep(NA, n-1)
for (i in 1:length(sfs_S)) {
    sfs_S[i] <- sum(derived_freqs == i)
    # sfs_S[i] <- length(which(derived_freqs == i))  # same thing
}
sfs_S


### plot
barplot(t(cbind(sfs_N, sfs_S)), beside=T, names.arg=seq(1,nrow(data_S)-1,1),
        legend=c("North", "South"))

cat("\nThe Northern population with the greater population size has a higher proportion of singletons, as expected.")

# northern - many more singletons than expected
# southern - fewer

# northern pop getting bigger
# southern pop getting smaller



# ### bonus: joint site frequency spectrum
# 
# sfs <- matrix(0, nrow=nrow(data_N)+1, ncol=nrow(data_S)+1)
# for (i in 1:ncol(data_N)) {
# 
#     freq_N <- sum(data_N[,i])
#     freq_S <- sum(data_S[,i])
# 
#     sfs[freq_N+1,freq_S+1] <- sfs[freq_N+1,freq_S+1] + 1
# 
# }
# sfs[1,1] <- NA # ignore non-SNPs
# 
# image(t(sfs))



