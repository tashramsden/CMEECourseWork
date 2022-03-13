## Practical 1 - unsupervised ----

rm(list=ls())
library(raster)
library(corrplot)
library(vegan)
library(cluster)
library(splits)


## Exercises 2.4: PCA, PCoA and NMDS ----

## Q1 ----
# download global temp and precipitation data
r <- getData("worldclim",var="bio",res=10)
e <- extent(150,170,-60,-40)
data <- data.frame(na.omit(extract(r, e)))
names(data) <- c("temp.mean","temp.diurnal.range", "isothermality",
                 "temp.season","max.temp","min.temp","temp.ann.range","temp.wettest",
                 "temp.driest","temp.mean.warmest","temp.mean.coldest","precip",
                 "precip.wettest.month","precip.driest","precip.season",
                 "precip.wettest.quarter","precip.driest.quarter",
                 "precip.warmest","precip.coldest")

## a) preform scaled PCA
pca <- prcomp(data, scale=TRUE)

## b) produce biplot and scree plot

# biplots
biplot(pca)
biplot(pca, choices=2:3)

pca
summary(pca)

# scree plot
plot(pca) 

## c) How many important axes of variation are there in global temp and
# precipitation on the basis of this data? Describe these.

# seems like 3 is probably enough - these explain the majority of variance
# lots of temp variables seem to be loading with PC2 and precipitation w PC1
# PC3 captures most of rest
# if plot the other PCs - not such strong loading w variables

## d) calculate correlation matrix for these data and use to confirm conceptual links between PCA and PCoA

cor_data <- cor(data)
corrplot(cor_data)

## e) perform an NDMS - more/less informative than PCA or PCoA?

dist <- vegdist(data)
nmds <- metaMDS(dist)

# shepard plot
stressplot(nmds)

plot(nmds)
orditorp(nmds, display="sites")
# contour plot showing eg 
ordisurf(nmds, data[,1])  # temp.mean
ordisurf(nmds, data[,"precip"])  # precip


## Q2 ----

# classic eco dataset: Barro Colorado Island 50-hectare plot

# load data
data(BCI)

## perform PCoA using euclidean distance matrix
dist <- dist(BCI)

# run PCoA
pcoa <- cmdscale(dist, eig=TRUE)
# plot eigenvalues of each axis - how much variation they explain in the space
barplot(pcoa$eig)

# perform ndms
nmds <- metaMDS(dist)
plot(nmds)
# Shepard diagram - describe model fit, want straight 1:1 line
stressplot(nmds)
## Euclidean distance matrix here makes NO SENSE! - ecological data about diff spp - not physcial dist


## repeat above with Bray-Curtis distance matrix - from vegdist
dist <- vegdist(BCI)

# run PCoA
pcoa <- cmdscale(dist, eig=TRUE)
# plot eigenvalues of each axis - how much variation they explain in the space
barplot(pcoa$eig)

# perform ndms
nmds <- metaMDS(dist)
# Shepard diagram - describe model fit, want straight 1:1 line
stressplot(nmds)

plot(nmds)
orditorp(nmds, display="sites")

# seems much more informative


## Q3 ----

# dataset of plant abundances across temp gradient
# task: figure out what is driving the distances in community composition within this data 
# one person thinks 2 kinds of ommunities here (hot vs cold envs)
# other thinks spp responding to a gradient of temp

# Load the data in
comm <- as.matrix(read.table("../data/hot-sites.txt"))
site.data <- read.table("site-data.txt")
# Build datasets of distances for quantile regression
dist.data <- with(site.data, data.frame(
    dist=as.numeric(your.distance.matrix),
    temp=as.numeric(dist(temp)),
    groups=as.numeric(dist(outer(groups, groups, `==`), method="binary"))
))
# Color plots of data according to a categorical variable
some.plot.function(some.data, col=ifelse(groups=="hot", "red", "blue"))

#### DON'T HAVE THE DATA - COME BACK TO THIS -----




# Exercises 3.4 - Clustering: hierarchical, k-means, model-based ----

## Q1 ----

# 100 yrs of electoral data from US - recording the proportion of
# the vote in each state that the Republican party received

# load data
votes <- na.omit(cluster::votes.repub)
# logistic transformation to normalise - percentages not normally distributed
logit <- function(x) {
    log(x / (1-x))
}
transformed <- logit(votes/100)

## a) perform a hierarchical cluster analysis

# euclidean distance now good since data has been normalised
distance <- dist(transformed) 
upgma <- hclust(distance, method="average")
plot(upgma)
comp.link <- hclust(distance)
plot(comp.link)

# try diff cuts - interesting!
cut.by.groups <- cutree(upgma, k=3)
cut.by.height <- cutree(upgma, h=6)

## b) use ddwtGap with the argument genRndm="uni" to see how many statistically significant clusters
# there are according to this metric

gap.stat <- ddwtGap(transformed, genRndm="uni")
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
gap.stat$mnGhatWG
# says there are 5 statistically sig clusters

# eg
cut.by.groups <- cutree(upgma, k=5)
# ie Kentucky and Maryland in one group,
# Delaware on its own
# California
# Vermont
# all the rest

## c) Do you think the output of ddwtGap is correct? Why (not)? 

# i think depends on question!


## Q2 ----

# load data about board games...!
data <- read.csv("../data/board-game-mechanics.csv", rownames=1)

## DON'T HAVE THE DATA - COME BACK LATER ----


## Q3 ----

# iris dataset - want to get species clusters based on other vars
data(iris)
head(iris)

## a) Use ddwtGap to determine the optimal number of clusters in this dataset

gap.stat <- ddwtGap(iris[,1:4])  # ie not the 5th col - not numeric (and the factor we might want to be guessing by clustering)
# iris[,1:4] == iris[,-5]
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
gap.stat$mnGhatWG
# 3 clusters
unique(iris$Species)  # 3 species


## b) Run a k-means analysis with at least ten restarts, using the number of clusters you identified above.

# centers=3 (expected num clusters)
k.means <- kmeans(iris[,-5], centers=3, nstart=10)


## c) Build a contingency table of your k-means clustering versus the 
# reality of the species definitions.

table(k.means$cluster, iris$Species)
# good clustering on the whole
# puts each species into its own cluster generally- 3rd species some get mixed up w versicolor

## d) repeat using a model-based clustering approach

model <- Mclust(iris[,-5])
summary(model)
model
plot(model, what="BIC")
# lines=  diff models
# once increase the num components above 5 - makes no diff to BIC 
# 5 is the min num components to explain the data


## Q4 ----

# data from Wright et al. (2004; The worldwide leaf economics
# spectrum. Nature, 428(6985) 821) - not share on github

leaf <- read.csv("../data/glopnet-biomass.csv")
head(leaf)
str(leaf)

## a) Fit a standard linear model (e.g., something like lm(biomass ∼ some.variables, data=data))
# to see what plant traits explain biomass in this experiment. What does you model tell you? Why is
# it not working very well?

lm <- lm(biomass ~ log.Nmass, data=leaf)  # tried various
summary(lm)
# lots of the vars covary
plot(leaf$log.Nmass, leaf$biomass)

## PCA
# head(leaf[3:15])
pca <- prcomp(leaf[,3:15], scale=TRUE)
biplot(pca)
biplot(pca, choices=2:3)
biplot(pca, choices=5:6)

summary(pca)
plot(pca)
# first 3 PCs seem to do the job

## hierarchical
distance <- dist(leaf[,3:15]) 
upgma <- hclust(distance, method="average")
plot(upgma)
comp.link <- hclust(distance)
plot(comp.link)

## k-means
# run algorithm 10 random times
# centers = num clusters 
k.means <- kmeans(leaf[,3:15], centers=3, nstart=10)
# contingency table to see if algorithm correctly defines groups
# ie table of clusters found vs ACTUAL groups in the data
table(k.means$cluster, leaf$species)
# this not v informative - in the dataset we don't actually have any groups


## c) Use whichever method you think performs best to fit a new linear model of 
# the data. Does this perform better or worse than the original model? Why?

lm <- lm(biomass ~ pca$x[,1] + pca$x[,2] + pca$x[,3], data=leaf)
summary(lm)

