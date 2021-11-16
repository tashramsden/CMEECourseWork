#### Practical 1 - Allele and genotype frequencies ----

rm(list=ls())

require(dplyr)
require(ggplot2)


## Data ----

# ../data/bears.csv contains 40 DNA sequences of 10k bp from 20 brown bears

# each row corresponds to an individual chromosome
# each column to a genomic position in the 10k bp locus

# each indiv has 2 chromosomes (diploid) 
# so indiv 1 will have data on row 1 AND 2 etc

# want to make inferences about how variable the genome of brown bears is and 
# whether it is an inbred population or not

bears <- as.matrix(read.csv("../data/bears.csv", header = FALSE, stringsAsFactors = FALSE,
                  colClasses = c("character"),# makes sure that T not interpreted as TRUE
                  col.names = c(1:10000)))


## Tasks ----

# 1. ----
#    Identify which positions are SNPs (polymorphic, meaning that they have
#    more than one allele) 

# find the polymorphic sites
polymorphic_sites <- c()
for (i in 1:ncol(bears)) {
    nucleotide_site <- bears[,i]
    num_alleles <- n_distinct(nucleotide_site)  # count num of alleles in each column (nucleotide site)
    if (num_alleles > 1) {
        # print(i)
        polymorphic_sites <- c(polymorphic_sites, i)
    }
}

# subset the data to only include polymorphic sites
polym_bears <- bears[,polymorphic_sites]

print(paste("Number of SNPs is", length(polym_bears)))


# 2. ----
#    Calculate, print and visualise allele frequencies for each SNP

num_chromosomes = nrow(polym_bears)
fill_empty <- rep(NA, ncol(polym_bears)) 

site <- c(substring(colnames(polym_bears), 2))  # get rid of the X in front of the numbers
minor_allele <- fill_empty  # pre-allocate the allele vectors
other_allele <- fill_empty
maf <- fill_empty
homozy_alt_freq <- fill_empty
hetero_freq <- fill_empty
homozy_minor_freq <- fill_empty
heterozygosity <- fill_empty
homozygosity <- fill_empty
chi <- fill_empty
p_value <- fill_empty
not_HWE <- fill_empty
F_value <- fill_empty

polym_data <- data.frame(site, minor_allele, other_allele, maf,
                         homozy_alt_freq, hetero_freq, homozy_minor_freq,
                         heterozygosity, homozygosity,
                         chi, p_value, not_HWE, F_value)

for (i in 1:ncol(polym_bears)) {
    
    # get alleles for each polymorphic site
    alleles <- sort(unique(polym_bears[,i]))
    
    # get the 2 frequencies
    freq1 <- length(which(polym_bears[,i]==alleles[1]))/nrow(polym_bears)
    freq2 <- length(which(polym_bears[,i]==alleles[2]))/nrow(polym_bears)
    
    # get minor allele (less freq) by indexing w which freq is smaller
    minor_allele <- alleles[which.min(c(freq1, freq2))]
    minor_allele_freq <- c(freq1, freq2)[which.min(c(freq1, freq2))]

    other_allele <- alleles[which.max(c(freq1, freq2))]
    
    polym_data$minor_allele[i] <- minor_allele
    polym_data$other_allele[i] <- other_allele
    polym_data$maf[i] <- minor_allele_freq
    
}

hist(polym_data$maf)
plot(polym_data$maf, type="h")

ggplot(polym_data, aes(site, maf)) + 
    geom_point() +
    theme_bw()
# of all 100 polymorphic sites, most have 1 allele that is almost fixed/v freq compared to the other
# ~ 20ish sites more split frequencies ~50-70%


# 3. ----
#    Calculate and print genotype frequencies for each SNP

# ploidy <- 2
# bear_id <- rep(1:20, each=ploidy)
# polym_bears <- as.data.frame(polym_bears) %>%
#     mutate(bear.id = bear_id)


nsamples <- nrow(polym_bears)/2
for (i in 1:ncol(polym_bears)) {

    ### genotypes are major/major major/minor minor/minor in counts below
    # so first position will hold num of genotypes homozygous for alternative allele
    # middle = heterozygous
    # last = homozygous for minor allele
    genotype_counts <- c(0, 0, 0)

    minor_allele <- polym_data$minor_allele[i]
    # print(minor_allele)
    
    for (j in 1:nsamples) {
        
        ### indexes of haplotypes for individual j (haplotype indices)
        # this gets hold of pairs of chromosomes
        haplotype_index <- c( (j*2)-1, (j*2) )
        ### count the minor allele instances
        genotype <- length(which(polym_bears[haplotype_index, i]==minor_allele))
        ## so if genotype=0 that means neither allele is the minor allele - so 
        # homozygous alternative, want to add one to the first position of 
        # genotype counts
        genotype_index=genotype+1
        ### increase the counter for the corresponding genotype
        genotype_counts[genotype_index] <- genotype_counts[genotype_index] + 1
    }
    
    polym_data$homozy_alt_freq[i] <- genotype_counts[1]/nsamples
    polym_data$hetero_freq[i] <- genotype_counts[2]/nsamples
    polym_data$homozy_minor_freq[i] <- genotype_counts[3]/nsamples
    
# 4. ----
#    Calculate (observed) homozygosity and heterozygosity for each SNP
    
    polym_data$heterozygosity[i] <- polym_data$hetero_freq[i]
    polym_data$homozygosity[i] <- polym_data$homozy_alt_freq[i] + 
        polym_data$homozy_minor_freq[i]

# 5. ----
#    Calculate expected genotype counts for each SNP and test for HWE
    
    ### from the frequency, I can calculate the expected genotype counts under HWE p^2,2pq,q^2
    # genotype_counts_expected <- c( (1-freq_minor_allele)^2, 2*freq_minor_allele*(1-freq_minor_allele), freq_minor_allele^2) * nsamples
    
    # p^2 is expected homozygous alternative freq
    p_sq <- (1-polym_data$maf[i])^2
    # 2pq is expected het freq
    two_pq <- 2*polym_data$maf[i]*(1-polym_data$maf[i])
    # q^2 is expected homozygous minor freq
    q_sq <- polym_data$maf[i]^2
    
    # expected numbers of each genotype frequency for a pop of 20
    genotype_counts_expected <-c(p_sq, two_pq, q_sq) * nsamples
    
    # test for HWE: calculate chi^2 statistic
    chi <- sum( (genotype_counts_expected - genotype_counts)^2 / genotype_counts_expected )

    # p value
    pv <- 1 - pchisq(chi, df=1)

    polym_data$chi[i] <- chi
    polym_data$p_value[i] <- pv
    
    # retain SNPs with p value < 0.05
    if (pv < 0.05) {
        polym_data$not_HWE[i] <- TRUE
    } 
    
    
# 6. ----
#    Calculate, print and visualise inbreeding coefficient for each SNP 
#    deviating from HWE    
    
    inbreeding <- (two_pq - polym_data$hetero_freq[i]) / two_pq 
    polym_data$F_value[i] <- inbreeding 
    
}

hist(polym_data$F_value)
plot(polym_data$F_value, type="h")

# save dataframe of results
write.csv(polym_data, "../results/bear_polymorphisms.csv", row.names=FALSE)
