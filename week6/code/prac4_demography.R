#### Population subdivision and demographic inferences ----

rm(list = ls())
require(vegan)

# quick plot to show how Fst (measure of pop structure) decreases as migration 
# between pops increases
# migration rate
Nm <- seq(0, 10,0.2)
# FST
FST <- 1/(1+4*Nm)
plot(Nm, FST, type="l")


## Intro and data ----

# want to infer history of a pop of sea turtles
# DNA from 40 (diploid) indivs from 4 diff locations (A,B,C,D)
# (10 indivs from each location)

# for each sample: 2000 SNPs 
# data on haplotypes (80 rows) stored in turtles.csv

# data on genotypes (40 rows) in turtle.genotypes.csv
# genotypes encoded as 0/1/2 for homozygous ancestral, heterozygous and 
# homozygous derived respectively

# in all files, indivs ordered by location (first 10 will be pop A etc)


# Aims: 

# test whether there is pop subdivision/structure in this sample and if so to 
# what extent

# assess whether there has been isolation by distance in this spp, knowing that
# the geographical distance of each pop from a putative origin is:
# A (5km), B (10km), C (12km), D (50km)


turtles <- as.matrix(read.csv("../data/turtle.csv", stringsAsFactors = F, 
                              header = FALSE, colClasses = c("numeric")))
dim(turtles)


## Population structure: calculating FST ----

# calculate average FST across all SNPs for each pair of subpops
# see whether this is larger than 0 and whether it is different when comparing 
# diff subpops

# populations:
popA <- turtles[1:20,]
popB <- turtles[21:40,]
popC <- turtles[41:60,]
popD <- turtles[61:80,]


# # small example w one snp - practice:
# first_snp_popA <- popA[,3]
# first_snp_popA
# first_snp_popB <- popB[,3]
# fA1 <- sum(first_snp_popA) / length(first_snp_popA)
# fA2 <- sum(first_snp_popB) / length(first_snp_popB)
# 
# # HT is expected proportion of heterozygous indivs in TOTAL pop 
# HT <- 2 * ((fA1 + fA2) / 2) * (1 - ((fA1 + fA2) / 2))
# # HS is expected prop of heterozygous indivs in subpops
# HS <- fA1 * (1 - fA1) + fA2 * (1 - fA2)
# 
# FST_1st_snp <- (HT - HS) / HT
# # FST is 0 here (HT = HS) - no subpop FOR THIS ONE SNP - now do same for all snps


## FST for pops A and B

## method A
FST_AB <- c()
# iterate through all snps in both pops
for (i in 1:ncol(popA)) {
    snp_popA <- popA[,i]
    snp_popB <- popB[,i]
    # calculate allele freq of derived allele in both pops
    fA1 <- sum(snp_popA) / length(snp_popA)
    fA2 <- sum(snp_popB) / length(snp_popB)
    # HT is expected proportion of heterozygous indivs in TOTAL pop 
    HT <- 2 * ((fA1 + fA2) / 2) * (1 - ((fA1 + fA2) / 2))
    # HS is expected prop of heterozygous indivs in subpops
    HS <- fA1 * (1 - fA1) + fA2 * (1 - fA2)
    
    FST_snp <- (HT - HS) / HT
    FST_AB <- c(FST_AB, FST_snp)
}
FST_AB
mean(FST_AB, na.rm=T)


## method B
## does same as above - quicker in R
fA1 <- as.numeric(apply(X=popA, MAR=2, FUN=sum)/nrow(popA))
fA2 <- as.numeric(apply(X=popB, MAR=2, FUN=sum)/nrow(popB))
FST <- rep(NA, length(fA1))
for (i in 1:length(FST)) {
    HT <- 2 * ((fA1[i] + fA2[i]) / 2) * (1 - ((fA1[i] + fA2[i]) / 2))
    # HS is expected prop of heterozygous indivs in subpops
    HS <- fA1[i] * (1 - fA1[i]) + fA2[i] * (1 - fA2[i])
    FST[i] <- (HT - HS) / HT
}
FST
mean(FST, na.rm=T)


## function to calculate FST between 2 pops
calculate_FST <- function(pop1, pop2) {
    
    fA1 <- as.numeric(apply(X=pop1, MAR=2, FUN=sum)/nrow(pop1))
    fA2 <- as.numeric(apply(X=pop2, MAR=2, FUN=sum)/nrow(pop2))
    FST <- rep(NA, length(fA1))
    
    for (i in 1:length(FST)) {
        # HT is expected proportion of heterozygous indivs in TOTAL pop 
        HT <- 2 * ((fA1[i] + fA2[i]) / 2) * (1 - ((fA1[i] + fA2[i]) / 2))
        # HS is expected prop of heterozygous indivs in subpops
        HS <- fA1[i] * (1 - fA1[i]) + fA2[i] * (1 - fA2[i])
        FST[i] <- (HT - HS) / HT 
    }
    
    FST_ave <- mean(FST, na.rm=TRUE)
    return(FST_ave)
}

## FST for pops A and B
FST_AB <- calculate_FST(popA, popB)

# can do manually for all pairs, or better:
pops <- list(popA, popB, popC, popD)
FST <- rep(NA, 6)
count <- 1
for (i in 1:(length(pops)-1)) {
    for (j in (i+1):length(pops)) {
        FST[count] <- calculate_FST(pops[[i]], pops[[j]])
        count <- count + 1
    }
}
FST

## summary
sub_pops <- c("A-B", "A-C", "A-D", "B-C", "B-D", "C-D")
# FST <- c(FST_AB, FST_AC, FST_AD, FST_BC, FST_BD, FST_CD)
summary <- data.frame(sub_pops, FST)
print(summary)

# FST suggests that there is some population structure between these pops
# seems as though pop A more different from the other 3, 
# but that pops B, C and D are all quite similar/there is less pop structure (there is mixing)


## Can also calculate FST between locations from haplotype ----

# subset the snps w a frequency of > 0.05
# common to do this in pop genetics to asses pop structure without paying 
# attention to private mutations/singletons only found in 1 indiv
snps <- which(apply(FUN=sum, X=turtles, MAR=2)/(nrow(turtles))>0.05)

cat("\nFST value (average):",
    "\nA vs B: ", calculate_FST(turtles[1:20,snps], turtles[21:40,snps]),
    "\nA vs C: ", calculate_FST(turtles[1:20,snps], turtles[41:60,snps]),
    "\nA vs D: ", calculate_FST(turtles[1:20,snps], turtles[61:80,snps]),
    "\nB vs C: ", calculate_FST(turtles[21:40,snps], turtles[41:60,snps]),
    "\nB vs D: ", calculate_FST(turtles[21:40,snps], turtles[61:80,snps]),
    "\nC vs D: ", calculate_FST(turtles[41:60,snps], turtles[61:80,snps]),"\n")

### these values indicate a certain degree of population subdivision


## Isolation by distance ----
# to test fro isolation by distance, need to see if correlation between genetic 
# distance (FST) and geographical distance 

## matrix of geographic distance
# A (5km), B (10km), C (12km), D (50km)
geo_distance <- c(5, 10, 12, 50)
geo_distances_matrix <- matrix(nrow=length(geo_distance), ncol=length(geo_distance))
colnames(geo_distances_matrix) <- c("A", "B", "C", "D")
rownames(geo_distances_matrix) <- c("A", "B", "C", "D")

## a=matrix of genetic distance
FST_matrix <- matrix(nrow=length(geo_distance), ncol=length(geo_distance))
colnames(FST_matrix) <- c("A", "B", "C", "D")
rownames(FST_matrix) <- c("A", "B", "C", "D")

for (i in 1: length(geo_distance)) {
    for (j in 1:length(geo_distance)) {
        geo_distances_matrix[i, j] <- abs(geo_distance[i] - geo_distance[j])
        FST_matrix[i, j] <- calculate_FST(turtles[c((((i-1)*20)+1):(20*i)),snps], turtles[c((((j-1)*20)+1):(20*j)), snps])
    }
}

geo_distances_matrix
FST_matrix

## test for correlation between 2 matrices - mantel test (here using the mantel
# test from the vegan package - other packages have this test too)
mantel(geo_distances_matrix, FST_matrix)

# p = 0.46 - not significant 
# no evidence for isolation by distance


## PCA and trees ----
# also qualitatively evaulate pop structure using dendograms and PCA

turtles2 <- as.matrix(read.csv("../data/turtle.genotypes.csv", 
                               stringsAsFactors = F, header=F, 
                               colClasses = c("numeric")))
dim(turtles2)

# assign name for each location
locations <- rep(c("A", "B", "C", "D"), each=10)


## Tree (see whether any clusters observed)
# first build a distance matrix
distance <- dist(turtles2)
# then a tree
tree <- hclust(distance)
plot(tree, labels=locations)
# A separate to B, C and D
# admixture between B, C and D (and one indiv of pop A)
# only qualitative analysis


## PCA
# filter out low-frequency variants first
colors <- rep(c("#ef6461","#e4b363","#5F0F40","#0eb1d2"), each=10)
points <- rep(c(15:18), each=10)

index <- which(apply(FUN=sum, X=turtles2, MARGIN =2)/(nrow(turtles2)*2)>0.05)

pca <- prcomp(turtles2[,index], center=T, scale=T)

summary(pca)

## principal components 1 and 2
plot(pca$x[,1], pca$x[,2], col=colors, pch=points)
legend("bottomleft", legend=sort(unique(locations)), col=unique(colors), pch=unique(points))

## principal components 2 and 3
plot(pca$x[,2], pca$x[,3], col=colors, pch=points)
legend("topleft", legend=sort(unique(locations)), col=unique(colors), pch=unique(points))

## no clear distinction between pops based on genetics - poor clustering

## from correlation, PCA and tree - no clear evidence for isolation by distance
# instead seems to be admixture (at least between pops B, C and D)
