#### Practical 2 - Genetic drift, mutation and divergence ----
## Molecular clocks

rm(list=ls())
require(dplyr)

## Data ----

# western_banded_gecko.csv
# bent-toed_gecko.csv
# leopard_gecko.csv

# interested in divergence time of these 3 species of gecko
# have 20k bp sequences from 10 individuals form each spp (data for 30 diploid
# indivs)

# want to:
# obtain divergence time between bent-toed and western banded geckos,
# assuming that:
# these 3 spp have a most recent common ancestor 30 million years ago
# the topology of the spp tree is that... (see prac pdf)

# want to work out which spp on which branch (which diverged first)

# calculate genetic divergence for each pair of spp
# genetic divergence: proportion of sites which are fixed for diff alleles 
# between pops/spp

## SEE PRAC 1 PDF FOR INFO/DIAGRAMS!

wb_gecko <- read.csv("../data/western_banded_gecko.csv", header = FALSE, 
                     stringsAsFactors = FALSE, colClasses = c("character"))
dim(wb_gecko)

bt_gecko <- read.csv("../data/bent-toed_gecko.csv", header = FALSE, 
                 stringsAsFactors = FALSE, colClasses = c("character"))
dim(bt_gecko)

leo_gecko <- read.csv("../data/leopard_gecko.csv", header = FALSE, 
                       stringsAsFactors = FALSE, colClasses = c("character"))
dim(leo_gecko)


## Divergence rates between species ----

# div_rate_AB <- sites_divergent / sites_total
# sites divergent:
#  - fixed within spp
#  - divergent between spp
# sites total:
#  - fixed within spp


## WB-BT ----
# calculate divergence between sequences of western banded and bent-toed

sites_divergent_between_species <- c()
fixed_sites_within_spp<-c()

for (i in 1:ncol(wb_gecko)) {
    ## first check if the site in both spp has only one allele (fixed in both spp)
    if ((length(unique(wb_gecko[,i]))==1) & (length(unique(bt_gecko[,i]))==1)) {
        fixed_sites_within_spp <- c(fixed_sites_within_spp, i)
        ## then check if these alleles in these fixed sites are diff in the 2 spp
        if (unique(wb_gecko[,i]) != (unique(bt_gecko[,i]))) {
            sites_divergent_between_species <- c(sites_divergent_between_species,i)
        }
    }
}

sites_divergent <- length(sites_divergent_between_species)
sites_total <- length(fixed_sites_within_spp)

# calculate overall genetic divergence between the 2 spp
div_rate_wb_bt <- sites_divergent / sites_total
print(sites_divergent)  # 73 divergent sites between WB-BT
print(div_rate_wb_bt)  # 0.003672032


## WB-LEO ----
# calculate divergence between sequences of western banded and leopard

sites_divergent_between_species <- c()
fixed_sites_within_spp<-c()

for (i in 1:ncol(wb_gecko)) {
    ## first check if the site in both spp has only one allele (fixed in both spp)
    if ((length(unique(wb_gecko[,i]))==1) & (length(unique(leo_gecko[,i]))==1)) {
        fixed_sites_within_spp <- c(fixed_sites_within_spp, i)
        ## then check if these alleles in these fixed sites are diff in the 2 spp
        if (unique(wb_gecko[,i]) != (unique(leo_gecko[,i]))) {
            sites_divergent_between_species <- c(sites_divergent_between_species,i)
        }
    }
}

sites_divergent <- length(sites_divergent_between_species)
sites_total <- length(fixed_sites_within_spp)

# calculate overall genetic divergence between the 2 spp
div_rate_wb_leo <- sites_divergent / sites_total
print(sites_divergent)  # 176 divergent sites between WB-LEO
print(div_rate_wb_leo)  # 0.008846444


## BT-LEO ----
# calculate divergence between sequences of bent-toed and leopard

sites_divergent_between_species <- c()
fixed_sites_within_spp<-c()

for (i in 1:ncol(bt_gecko)) {
    ## first check if the site in both spp has only one allele (fixed in both spp)
    if ((length(unique(bt_gecko[,i]))==1) & (length(unique(leo_gecko[,i]))==1)) {
        fixed_sites_within_spp <- c(fixed_sites_within_spp, i)
        ## then check if these alleles in these fixed sites are diff in the 2 spp
        if (unique(bt_gecko[,i]) != (unique(leo_gecko[,i]))) {
            sites_divergent_between_species <- c(sites_divergent_between_species,i)
        }
    }
}

sites_divergent <- length(sites_divergent_between_species)
sites_total <- length(fixed_sites_within_spp)

# calculate overall genetic divergence between the 2 spp
div_rate_bt_leo <- sites_divergent / sites_total
print(sites_divergent)  # 181 divergent sites between WB-LEO
print(div_rate_bt_leo)  # 0.009099593


## summary ----
gecko_pairs <- c("WB-BT", "WB-LEO", "BT-LEO")
divergence <- c(div_rate_wb_bt, div_rate_wb_leo, div_rate_bt_leo)
summary <- data.frame(gecko_pairs, divergence)
print(summary)


## conclusions from divergence data ----

# leopard gecko shows most divergence to other 2 spp - diverged earliest
# western-banded and bent-toed geckos have diverged from each other more recently

# spp tree most likely: LEO:(WB:BT)

# we know that leopard geckos diverged 30mya - now find divergence time of wb-bt


## Divergence time between western-banded and bent-toed geckos ----

# first calculate mutation rate based on:
# mut rate = div between leop and wb or bt / 2 * time since leop diverged from wb or bt (30mya)
# see notes for full equations

div_time_leo <- 3e7  # 30 million years ago

## these give slightly diff estimates of mu
# mu <- div_rate_wb_leo / (2*div_time_leo)
# mu <- div_rate_bt_leo / (2*div_time_leo)
## instead, take ave of div rates for leo and the other 2
ave_div_rate_to_leo <- (div_rate_wb_leo + div_rate_bt_leo) / 2
mu <- ave_div_rate_to_leo / (2 * div_time_leo)

print(paste("Mutaion rate:",mu))  # seems fairly realistic

# based on mutation rate (have to assume it's constant for diff spp...!)
# can work out divergence time between western-banded and bent-toed geckos

div_time_wb_bt <- div_rate_wb_bt / (2 * mu)
print(div_time_wb_bt)

# ~12 million years ago, western-banded and bent-toed geckos diverged

## Conclusions ----

print("Leopard geckos diverged from bent-toed and western-banded geckos around 30mya.")
print("Bent-toed and western-banded geckos diverged more recently, around 12mya.")
