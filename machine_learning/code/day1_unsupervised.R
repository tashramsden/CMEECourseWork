## Machine learning - day1 - unsupervised ----
# PCA, PCoA, NMDS
# Clustering: hirarchical, k-means, model-based

rm(list=ls())
library(mvtnorm)
library(splits)
library(mclust)
library(vegan)


## PCA ----

set.seed(123)

# create data - drawn form multivariate normal distribution
# (ie draw 5 variables - 3 strongly correlated w each other, other 2 vary indep)
covariance <- matrix(c(5,3,0,-3,0, 3,5,0,-3,0, 0,0,5,0,0,
                       -3,-3,0,6,0, 0,0,0,0,3), nrow=5)
data <- rmvnorm(1000, sigma=covariance)
names(data) <- c("a", "b", "c", "d", "e")

pca <- prcomp(data)
biplot(pca)
biplot(pca, choices=2:3)

pca
# can see how column 3 (varaible c) loads w PC2
plot(pca$x[,2] ~ data[,3], xlab="'c' variable", ylab="PC2")

summary(pca)
plot(pca)  # scree plot

## BEST : conduct PCA on z-transformed variables (scaled data) (have stdev 1)
pca <- prcomp(data, scale=TRUE)
biplot(pca)
biplot(pca, choices=2:3)

pca
plot(pca$x[,2] ~ data[,3], xlab="'c' variable", ylab="PC2")

summary(pca)
plot(pca)


## PCoA ----

# Draw species' parameters
intercepts <- rnorm(20, mean=20)
env1 <- rnorm(20)
env2 <- rnorm(20)
# Create environment
env <- expand.grid(env1=seq(-3,3,.5), env2=seq(-3,3,.5))
biomass <- matrix(ncol=20, nrow=nrow(env))
for(i in seq_len(nrow(biomass))) {
    biomass[i,] <- intercepts + env1*env[i,1] + env2*env[i,2]
}

# create distance matrix
dist <- dist(biomass)  # Euclidean dist - for this probs not best
dist <- vegdist(biomass)  # from vegan package

# run PCoA
pcoa <- cmdscale(dist, eig=TRUE)
# plot eigenvalues of each axis - how much variation they explain in the space
barplot(pcoa$eig)  # ie first 2 axes explain overwhelming majority

# can plot the various axes (points) of the PCoA
plot(pcoa$points[,1:2], xlab="PCoA1", ylab="PCoA2")
plot(pcoa$points[,1:2], type="n", xlab="PCoA1", ylab="PCoA2")
text(pcoa$points[,1:2]+.25, labels=env[,1], col="red")
text(pcoa$points[,1:2]-.25, labels=env[,2], col="black")


## NDMS ----

nmds <- metaMDS(dist)
plot(nmds)  # straightforward - shows how similar points are - closer=more similar

# Shepard diagram - describe model fit, want straight 1:1 line
stressplot(nmds)

# can plot environmental responses
plot(nmds)
orditorp(nmds, display="sites")
ordisurf(nmds, env[,1]) # eg shows how data correlated w first col variable

# see for more on NMDS: https://jonlefcheck.net/2012/10/24/nmds-tutorial-in-r/


## Hierarchical clustering ----

# simulate data
data <- data.frame(rbind(
    cbind(rnorm(50),rnorm(50)),
    cbind(rnorm(50,5), rnorm(50,5)),
    cbind(rnorm(50,-5), rnorm(50,-5))
))
data$groups <- rep(c("red","blue","black"), each=50)
names(data)[1:2] <- c("x","y")
with(data, plot(y ~ x, pch=20, col=groups))

# generate distance matrix
# just use dist here = Euclidean distance, fine here as we have normally distributed data
distance <- dist(data[,c("x","y")]) 
upgma <- hclust(distance, method="average")
plot(upgma)
comp.link <- hclust(distance)
plot(comp.link)

# cut the data into groups - # splits each row of data into groups
# can cut the tree at diff points to get certain num groups
cut.by.groups <- cutree(upgma, k=2)
# or cut tree at certain height
cut.by.height <- cutree(upgma, h=8)


# ## How many groups?

# install.packages("paran")
# install.packages("ape")
# install.packages("splits", repos="http://R-Forge.R-project.org")
# library(splits)

# DD-weighted gap statistic - ie determine number of clusters using weighted-gap stat
gap.stat <- ddwtGap(data[,c("x","y")])
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
gap.stat$mnGhatWG
## tells that there are 3 groups in the data - yay


## K-means clustering ----

set.seed(123)

# generate data
data <- data.frame(rbind(
    cbind(rnorm(50),rnorm(50)),
    cbind(rnorm(50,2.5),rnorm(50,2.5)),
    cbind(rnorm(50,-2.5),rnorm(50,-2.5)),
    cbind(rnorm(50,5), rnorm(50,5)),
    cbind(rnorm(50,-5), rnorm(50,-5))
))
data$groups <- rep(c("red","blue","grey80","grey60","grey20"), each=50)
names(data)[1:2] <- c("x","y")
with(data, plot(y ~ x, pch=20, col=groups))

# run algorithm 10 random times
# centers = num clusters 
k.means <- kmeans(data[,-3], centers=5, nstart=10)
# contingency table to see if algorithm correctly defines groups
# ie table of clusters found vs ACTUAL groups in the data
table(k.means$cluster, data$groups)
# on the whole great - split data into 5 groups - well assigned - and only w 10 runs!


gap.stat <- ddwtGap(data[,c("x","y")])
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
gap.stat$mnGhatWG
# (depending on seed) get 4/5 groups here - good


## Model-based clustering ----

model <- Mclust(data[,-3])
# also gives 5 clusters 
summary(model)
model
plot(model, what="BIC")
# lines=  diff models
# once increase the num components above 5 - makes no diff to BIC 
# 5 is the min num components to explain the data



