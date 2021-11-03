## Stats with sparrows


## SwS 10 - R squared, covariance, correlation ----

# covariance - how 2 variables change together
# product of sums of squares for x and y
# depends on units etc can be v big/small 

# covariance vs correlation
# correlation = cov/product of st dev for x and y
# STANDARDISED version of covariance
# will be between -1 and 1 - (easier to interpret/more meaningful/generally 
# applicable/comparable between studies than covar!)

# r squared
# coefficient of determination
# proportion of variance in y explained by x

# square of cor coef for 1 expl var
# >1 expl var: r^2 = 1 - SSresiduals / SStotal (SS=sums of squares=variance)

# cor coef describes relationship between x and y, between -1 and 1
# r squared describes how strong x and y correlated, between 0 and 1


## Hand-out work ----

# First, remember that the	variance is	really	just the sum of	the	deviations	from	the	mean.	
# That	means, for a given	dataset, we	take the mean,	and	then	subtract that	from	each	
# datapoint. That deviation then	is	squared,	and	we	add	all	up.	We	then	divide	by	the	sample	
# size	(minus	one).	We	can	visualize that	neatly:
rm(list = ls())
# create three data sets y with different variances (1, 10, 100)
# rnorm() requires sample size (20), mean and sd
y1<-rnorm(10, mean=0, sd=sqrt(1))
var(y1)

y2 <- -rnorm(10, mean=0, sd=sqrt(10))
var(y2)

y3<-rnorm(10, mean=0, sd=sqrt(100))
var(y3)

# create x for plotting
x <- rep(0, 10)
par(mfrow = c(1, 3))
plot(x, y1, xlim=c(-0.1,0.1), ylim=c(-12,12), pch=19, cex=0.8, col="red")
abline(v=0)
abline(h=0)

plot(x, y2, xlim=c(-0.1,0.1), ylim=c(-12,12), pch=19, cex=0.8, col="blue")
abline(v=0)
abline(h=0)

plot(x, y3, xlim=c(-0.1,0.1), ylim=c(-12,12), pch=19, cex=0.8, col="darkgreen")
abline(v=0)
abline(h=0)

# clear that y3 has larger variance - all have same mean

# now plot w the squares
?polygon()
par(mfrow = c(1, 3))

plot(x, y1, xlim=c(-12,12), ylim=c(-12,12) ,pch=19, cex=0.8, col="red")
abline(v=0)
abline(h=0)
polygon(x=c(0,0,y1[1],y1[1]),y=c(0,y1[1],y1[1],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[2],y1[2]),y=c(0,y1[2],y1[2],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[3],y1[3]),y=c(0,y1[3],y1[3],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[4],y1[4]),y=c(0,y1[4],y1[4],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[4],y1[4]),y=c(0,y1[4],y1[4],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[5],y1[5]),y=c(0,y1[5],y1[5],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[6],y1[6]),y=c(0,y1[6],y1[6],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[7],y1[7]),y=c(0,y1[7],y1[7],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[8],y1[8]),y=c(0,y1[8],y1[8],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[9],y1[9]),y=c(0,y1[9],y1[9],0), col=rgb(1, 0, 0,0.2))
polygon(x=c(0,0,y1[10],y1[10]),y=c(0,y1[10],y1[10],0), col=rgb(1, 0, 0,0.2))

# for loops for y2 and y3
plot(x, y2, xlim=c(-12,12), ylim=c(-12,12), pch=19, cex=0.8, col="blue")
abline(v=0)
abline(h=0)
for (i in 1:length(y2)) {
    polygon(x=c(0,0,y2[i],y2[i]),y=c(0,y2[i],y2[i],0), col=rgb(0, 0, 1,0.2))
}
plot(x, y3, xlim=c(-12,12), ylim=c(-12,12), pch=19, cex=0.8, col="darkgreen")
abline(v=0)
abline(h=0)
for (i in 1:length(y3)) {
    polygon(x=c(0,0,y3[i],y3[i]),y=c(0,y3[i],y3[i],0), col=rgb(0, 1, 0,0.2))
}
# evident that green squares MUCH bigger than red, and the sum of them will be much larger


## covariance
# now if we have second variable, x
# can calculate the covariances between x and y as the product between 
# deviations of the mean

# simulate that x and y are related (by multiplying x with y but change intensity of association)
rm(list = ls())
par(mfrow = c(1, 3))

x<-c(-10:10)
var(x)

# here the association is 1:1, positive
y1 <- x*1 + rnorm(21, mean=0, sd=sqrt(1))
cov(x, y1)
plot(x, y1, xlim=c(-10,10), ylim=c(-20, 20), col="red", pch=19, cex=0.8,
     main=paste("Cov=",round(cov(x,y1),digits=2)))

# here there is no association
y2 <- rnorm(21, mean=0, sd=sqrt(1))
cov(x, y2)
plot(x, y2, xlim=c(-10,10), ylim=c(-20, 20), col="blue", pch=19, cex=0.8, 
     main=paste("Cov=",round(cov(x,y2),digits=2)))

# here the association is negative
y3 <- x*(-1) + rnorm(21, mean=0, sd=sqrt(1))
cov(x, y3)
plot(x, y3, xlim=c(-10,10), ylim=c(-20, 20), col="darkgreen", pch=19, cex=0.8,
     main=paste("Cov=",round(cov(x,y3),digits=2)))


# introduce stronger/weaker associations
rm(list = ls())
par(mfrow = c(1, 3))

x<-c(-10:10)
var(x)

# here the association is very weak, but not 0:
y1<-x*0.1 + rnorm(21, mean=0, sd=sqrt(1))
cov(x, y1)
plot(x, y1, xlim=c(-10,10), ylim=c(-20, 20), col="red", pch=19, cex=0.8, 
     main=paste("Cov=",round(cov(x,y1),digits=2)))

# here it is 0.5
y2<-x*0.5+ rnorm(21, mean=0, sd=sqrt(1))
cov(x, y2)
plot(x, y2, xlim=c(-10,10), ylim=c(-20, 20), col="blue", pch=19, cex=0.8,
     main=paste("Cov=",round(cov(x,y2),digits=2)))

# here the association is 2
y3<- x*2 +rnorm(21, mean=0, sd=sqrt(1))
cov(x, y3)
plot(x, y3, xlim=c(-10,10), ylim=c(-20, 20), col="darkgreen", pch=19, cex=0.8,
     main=paste("Cov=",round(cov(x,y3),digits=2)))


# covariance changes the stronger vars are associated
# BUT not v useful
# depends on units

# fix this by standardizing 
# so that response var has st dev of 1
# OR (more elegant) standardize using the st devs of both vars
# this cor coef helps gauge strength of association between 2 vars that co-vary
# between -1 and 1 (0=no association, -1 and 1 strongest possible)
# without units so comparable to diff datasets

# compare cov and cor:
cov(x,y1)
cor(x, y1)
cov(x,y2)
cor(x,y2)
cov(x,y3)
cor(x,y3)

# introduce variation in y
rm(list = ls())
par(mfrow = c(3, 1))

x<-c(-10:10)
var(x)

# here the association is 1:1, with low variance in y
y1<-x*1 + rnorm(21, mean=0, sd=sqrt(1))
cov(x, y1)
plot(x, y1, xlim=c(-10,10), ylim=c(-20, 20), col="red", pch=19, cex=0.8,
     main=paste("Cov=",round(cov(x,y1),digits=2)," Cor=",round(cor(x,y1),digits=2)))

# The association remains 1:1, but higher variance in y
y2<-x*1 + rnorm(21, mean=0, sd=sqrt(10))
cov(x, y2)
plot(x, y2, xlim=c(-10,10), ylim=c(-20, 20), col="blue", pch=19, cex=0.8, 
     main=paste("Cov=",round(cov(x,y2),digits=2)," Cor=",round(cor(x,y2),digits=2)))

# even bigger variance in y
y3<- x*1 + rnorm(21, mean=0, sd=sqrt(100))
cov(x, y3)
plot(x, y3, xlim=c(-10,10), ylim=c(-20, 20), col="darkgreen", pch=19, cex=0.8,
     main=paste("Cov=",round(cov(x,y3),digits=2)," Cor=",
                round(cor(x,y3),digits=2)))
# cov stays ~same (higher x, higher y still 1:1)
# correlation decreases - more noise - less clear correlation


## calculus for mean, var, cov ----
rm(list= ls())

#### rules for the mean

## 1. the mean of a constant is the constant
mean(4)

## 2. adding a constant value to each term increases the mean (or 
# expected value) by the constant
y<-c(-3,5,8,-2)
mean(y)
mean(y+4)
mean(y)+4

## 3. multiplying each term by a constant value multiplies the mean 
# by that constant
mean(y*4)
mean(y)*4

## 4. the mean of the sum of 2 vars is the sum of the means
y1<-runif(n=4)
mean(y1)
mean(y)
mean(y1) + mean(y)
mean(y1+y)


#### rules for the variance

## 1. the variance of a constant is 0
a<-c(4,4,4,4)
var(a)

## 2. adding a constant value to the variable does not change the variance,
# it only shifts the mean
var(y)
mean(y)
var(y+4)
mean(y+4)

## 3. multiplying a random var by a constant increases the variance by the
# square of the constant
var(y)
var(y*2)
var(y*4)

## 4. the variance of the sum of 2/more random vars is equal to the sum of 
# each of their variances only when the random vars are independent
# independent means their covariance is 0
var(y)
y2<-c(-2, -10, 20, 18)
var(y2)
var(y+y2)
var(y) + var(y2)


#### rules for covariances

## 1. the covariance of 2 constants, c and k, is 0
rm(list = ls())
a<-rep(4,10)
b<-rep(6,10)
cov(a,b)

## 2. the covariance of 2 indpendent random vars is 0
rm(list = ls())
x<-runif(10)
y<-runif(10)
cov(x,y)

## 3. the covariance is a combinative (not affected by order)
cov(x, y)
cov(y, x)

## 4. the covariance of a random variable with a constant is 0
a<-rep(4,10)
cov(x,a)

## 5. adding a constant to either/both random vars does not change 
# their covariances
cov(x,y)
cov((x+5), y)
cov((x+5),(y+5))

## 6. multiplying a random var by a constant multiplies the covariance by 
# that constant
cov(x,y)
cov(x*2,y)

## 7. the covariance of a random var with a sum of random vars is just the 
# sum of the covariances with each of the random variables
z <- x*0.4+0.1*runif(10)
cov((x+y),z)
cov(x,z)+cov(y,z)


## SwS 11a - Linear models w categorical predictors ----

# lm(response ~ explanatory)

a <- read.table("../data/SparrowSize.txt", header=TRUE)
str(a)

# sex: 0 and 1
catmod1 <- lm(Mass ~ Sex, data=a)
summary(catmod1)

# yi = b0 + b1xi + epsiloni
# when xi = 0 (female) b0 will be intercept (yi = b0 + epsiloni)
# when xi = 1 (male) -- b1xi is the diff between females and males (yi = b0 + b1xi + epsiloni)
# like a ttest

# so in summary(catmod1) - intercept = mean mass for female, 
# add ~half a gram -> ave male mass (bit labelled Sex)

# mean of each group:
# females = intercept
# males = intercept + b1 (b1 diff between groups)

## intercept is the mean of reference category - R chooses this alphanumerically (can force-add 0 in front!)

catmod2 <- lm(Mass ~ Sex.1, data=a)
summary(catmod2)
# values still the same


## categorical predictors with more than 2 levels

# year as categorical predictor
# hypothesis: diff yrs have diff food supply
# prediction: mass differs between years

# have to tell R to use years as categorical

a$Year.F <- as.factor(a$Year)
str(a)

catmod3 <- lm(Mass ~ Year.F, data=a)
summary(catmod3)
# all categories compared to reference category
# sig stars against most - doesn't mean all years compleetly diff - only compared to ref
# have to do post-doc tests to compare each year

plot(a$Mass ~ a$Year.F)

## key points:
# r chooses ref level alpha numerically
# intercept = mean of ref level
# estimates = diff to ref level
# ttest: diff to ref level
# using cat vars w many levels - not so good because losing lots of degrees of freedom


## SwS 11b - multiple linear models ----

# can have >1 explanatory vars
# can mix continuous and factorial explanatory vars
# complexity increases
# BUT careful - need to be easily explained, presented

# yi = b0 + b1xio + b2xi1 + b3xi2 + epsiloni

## eg w 2 predictor vars
# yi = b0 + b1xio + b2xi1 + epsiloni
# b0 = intercept
# b1 = estimates effect of continuous var x0 (tarsus)
# b2 = estimates effect of 2-level factor x1 (sex)

# w no effect
# females (xi2 = 0) -> yi = b0 + b1xi0 + epsiloni 
# males (xi2 = 1) -> y = b0 + b1xi0 + b2 + epsiloni - males have diff intercept = b0 + b2
# slope same 

# males heavier than females, still no effect of tarsus
# estimate sig diff to females (mean is diff)

# effect of tarsus not sex
# sig effect of slope


## interaction of terms
# what if effect of sex and tarsus (would have diff intercepts and slopes)
# yi = b0 + b1xi0 + b2xi1 + b3xi0xi1 + epsiloni
# costs LOTS of degrees of freedom - and MUST have a biological explanation!!!!
# b3 term has xi0 (sex) and xi1 (tarsus) interacting
# no new variables - just interacting existing one
# females: linear function still same (intercept and slope) ( because xi0 = 0)
# males: -> b0 + b2 + (b1 = b3)xi0 + epsiloni  - both slope and intercept diff from females

# b0 - intercept of ref group
# b1 - slope of ref group
# b2 - diff of intercept of group 1 to ref
# b3 - diff of slope of group 1 to ref

# don't interpret estimates from lm summary by themselves for interactions!!

# t value for intercepts - whether diff from 0


## KEY - making models - THINK about which variables biologically meaningful!!!! ----
## model + vs *
# if slope is ~ same for all vars - add them
# if there is BIO JUSTIFICATION for slope being diff for diff vars - then would 
# be interaction - if not justification - no interaction!!
# generally not penalised for too simple model - WILL be penalised if too 
# complex for no reason/cannot be interpreted!!!


## SwS 11c ----

# multiple continuous predictors, interactions between continuous predictors, 
# interactions between categorical predictors

# interactions between continuous predictors
# main effects cannot be interpreted in isolation 
# difficult to interpret, visualise
# only do if meaning behind and relevant to hypothesis

## what to use when:
## Always think of hypothesis, depends on q
## do you want to:
# predict
# explain
# explore
# account for variables

# models 
# interpretation for continuous vs cat vars differs - know which using
# know your data
# do not over-fit


## Hand-out work ----
rm(list=ls())

## Daphnia growth
# rate of growth in water containing 4 diff detergents and using
# individuals of 3 diff clones

## load and examine data
daphnia <- read.delim("../data/daphnia.txt")
summary(daphnia)
head(daphnia)
str(daphnia)

## check for outliers
# from summary data- categories have sufficient sample sizes - homegeneous dataset
par(mfrow = c(1, 2))
plot(Growth.rate ~ as.factor(Detergent), data=daphnia)
plot(Growth.rate ~ as.factor(Daphnia), data = daphnia)
# outliers in boxplots would be circles - none here

## homegeneity of variances - important assumption
# looking at plot - look sort of simialr (rule of thumb: ratio between largest
# var and smalled should not be much more than 4)
require(dplyr)
daphnia %>%
    group_by(Detergent) %>%
    summarise (variance=var(Growth.rate))
# fairly similar
daphnia %>%
    group_by(Daphnia) %>%
    summarise (variance=var(Growth.rate))
# var for clone 1 more than 4 times smaller than others - borderline but we'll go with it
# keep this in mind when interpreting results!!!
# would be explicitly clear about assumptions in report -> (“the	assumption	of	normality	was violated	- the	ratio	between	the	largest	and smallest variance	was	5,	which	is	slightly	too	much	and	might	bias	the	least	square	estimators”)	and	consider	the	consequences	of	this	for	when	you	draw	your	conclusions (also	explicitly	in	your	report).

## are the data normally distributed?
dev.off()
hist(daphnia$Growth.rate)
# Errr.	Well.	This	is	a	good	one.	WHAT	exactly	needs	to	be	normally	distributed?	And	how	close	to	normal	should	it	be?	Linear	regression	assumes	normality,	but it is	reasonably robust	against	violations.	However,	it	assumes	that	the	observations	for	each	x	are	normal.	So,	if	you	measure	something	at	x-2	10	times,	you’d	expect	the	resulting	y	to	be	normally distributed.	Zuur	et	al.	2010	nicely	shows	this.	Really,	we	are	interested	in	the	residuals.	So	we’ll	look	at	that	later	in	more	detail	and	for	now	hope	that	the	growth	rate	is	ok-ish	normally	distributed.

## are there excessively many zeros?
# from hist, no

## is there co-linearity among the covariates?
# only have categories here so doesn't apply
# check if all combinations represented - we know this data homogeneous

## visually inspect relationships
# done w boxplots above - no continuous covariates, maybe clone 1 has effect-that's about it

## consider interactions?
# no


### Model daphnia

# first make barplots of mean and se for both genotype and detergent

# get means and se
seFun <- function(x) {
    sqrt(var(x)/length(x))
}
detergentMean <- with(daphnia, tapply(Growth.rate, INDEX = Detergent,
                                      FUN = mean))
detergentSEM <- with(daphnia, tapply(Growth.rate, INDEX = Detergent,
                                     FUN = seFun))
cloneMean <- with(daphnia, tapply(Growth.rate, INDEX = Daphnia, FUN = mean))
cloneSEM <- with(daphnia, tapply(Growth.rate, INDEX = Daphnia, FUN = seFun))

# plot
par(mfrow=c(2,1),mar=c(4,4,1,1))  # plot one above other and reduce size of margins
barMids <- barplot(detergentMean, xlab = "Detergent type", 
                   ylab = "Population growth rate", ylim = c(0, 5))
arrows(barMids, detergentMean - detergentSEM, barMids, detergentMean +
           detergentSEM, code = 3, angle = 90)
barMids <- barplot(cloneMean, xlab = "Daphnia clone", 
                   ylab = "Population growth rate", ylim = c(0, 5))
arrows(barMids, cloneMean - cloneSEM, barMids, cloneMean + cloneSEM,
       code = 3, angle = 90)
# doesn't look like detergents matter but test anyway to see if any 
# explanatory power

daphniaMod <- lm(Growth.rate ~ Detergent + Daphnia, data=daphnia)
summary(daphniaMod)
# intercept is mean for brandA clone1 - this mean is sig diff from 0
# then next estimate is comparing mean of BrandB Clone1 to the ref (brandA Clone1) - not sig diff
# etc
# same difference in means as calculated for barplot
detergentMean - detergentMean[1]
cloneMean - cloneMean[1]
# to get mean of BrandA Clone2 - do intercept + estimate for Clone2
# to get mean of BrandB Clone3 - do intercept + estimate for BrandB + estimate for Clone3

## can use Tukey HSD to test all pairwise differences:
# first change model slightly (as Tukey doesn't accept lm input)
?aov  # v similar but less powerful than lm - can be useful
daphniaANOVAMod <- aov(Growth.rate ~ Detergent + Daphnia, data = daphnia)
summary(daphniaANOVAMod)
# Tukey
daphniaModHSD <- TukeyHSD(daphniaANOVAMod)
daphniaModHSD
# gives upper and lower 95CI (confidence interval)

# 2 tables: detergent (shows none are sig diff)
# daphnia  - clone1 sig diff from 2 and 3, 2 and 3 not diff to each other

par(mfrow=c(2,1),mar=c(4,4,2,2))
plot(daphniaModHSD)
# can see that clone1-clone2 and clone1-clone3 are the only ones that are sig diff from 0

## model validation
par(mfrow=c(2,2))
plot(daphniaMod)
# oh no! -no stars in the sky!
# QQ plot looks good - no outliers indeed
# but not too bad -publishable! IF openly explain the tihngs that affect how one interprets the data


## multiple regression ----

# dataset on volume of usable timber harvested from trees of known height and girth
# want to know whether height and girth important inpredicting yield from a tree

timber <- read.delim("../data/timber.txt")
summary(timber)
str(timber)
head(timber)

## outliers
par(mfrow = c(2, 2))
boxplot(timber$volume)
boxplot(timber$girth)
boxplot(timber$height)
# 1 outlier in volume - large but not excessively
# nothing to suggest it's a measurement error or typo - could be biologically true
# leave it in - remember when looking at leverage

## homogeneity of variances - level of variance of expl vars constant across sample
var(timber$volume)
var(timber$girth)
var(timber$height)
# violation of homogeneity = hetergeneity/heteroscedasticy
# interested in volumne (y) so standardize the x's:
# transform data:
t2<-as.data.frame(subset(timber, timber$volume!="NA"))
t2$z.girth<-scale(timber$girth)
t2$z.height<-scale(timber$height)
var(t2$z.girth)
var(t2$z.height)
plot(t2)

## normally dist?
par(mfrow = c(2, 2))
hist(t2$volume)
hist(t2$girth)
hist(t2$height)

## excessively many 0s?
# no

## co-linearity among covariates?
pairs(timber)
cor(timber)
# all variables positively correlated 
# tree diameter better predictor of yield than height
# too much correlation among the predictors (height and girth)
# not good - colinearity - inflates variation (would get larger se)
# then more difficult to detect an effect - get non-sig even if might be
# dropping covariates can affect estimates of other covars if colinear
# SEs inflated w square root of Variance Inflation Factor
# can use this VIF to see what amount of colinearity is too much

# calculate VIF by running extra linear model in which the covariate of focus (here girth)
# is y, and all other covars (height) are the covars
# then:
# VIF = 1 / (1 - R^2)
summary(lm(girth ~ height, data = timber))
VIF<- 1/(1-0.27)
VIF
sqrt(VIF)
# so SEs of girth inflated by 1.17 - not a lot
# some people - get rid of all covars w VIF > 3, some say >10
# test for it and keep in mind! (disclose in report) - think biology always
pairs(timber)
cor(timber)
# can see outlier in vol but behaves like all other points - doesn't 
# influence correlation too much
# same w scaled predictors - much the same - same correlations (should be!)
pairs(t2)
cor(t2)

## visually inspect relationships
# for covars done
# pair plot shows relationships w response var (vol) - are some relationships

## interactions?
# not for now

# if girth has such high corr w vol, do we need height too?
timberMod <- lm(volume ~ girth + height, data = timber)
anova(timberMod)
# yes! height needed as well as girth
summary(timberMod)

# R^2 shows >90% var in vol comes explained by:
# vol = -4.2 + 0.08*height + 0.04*girth
# NOTE: model makes stupid predictions if tree is v small 
# - 1m sapling w diameter 10cm contains -3.72 tonnes timber...!
# not sensible to expect model to make good predictions outside of 
# range of data used to fit it

plot(timberMod)
# no starry sky!
# QQ ok
# leverage not nice - one point esp stands out - 31
# if wanting to publish - run whole thing without this point and see if 
# come to same conclusions
# if so, leave it in, if not - think about why 31 stands out so much


# without 31
timber_subset <- t2[1:30,]
summary(timber_subset)
str(timber_subset)
head(timber_subset)

par(mfrow = c(2, 2))
boxplot(timber_subset$volume)
boxplot(timber_subset$girth)
boxplot(timber_subset$height)
# no outliers now

plot(timber_subset)
pairs(timber_subset)
cor(timber_subset)
summary(lm(girth ~ height, data = timber_subset))
VIF<- 1/(1-0.2)
VIF
sqrt(VIF)  # smaller VIF

timberMod2 <- lm(volume ~ girth + height, data = timber_subset)
anova(timberMod2)
summary(timberMod2)
plot(timberMod2)
## conclusions still basically the same


#### checklist ----
# 1. outliers?
# 2. homogeneity of variances?
# 3. normally distributed data?
# 4. excessively many zeros?
# 5. co-linearity amonf the covariates?
# 6. visually inspect relationships
# 7. consider interactions?


