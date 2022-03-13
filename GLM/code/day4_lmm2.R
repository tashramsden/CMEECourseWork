## Linear mixed models - part 2 ----

# NOTE - see day5_repeatability.R for more explanation of repeatability (mentioned here but not in detail)

rm(list=ls())
# setwd("/home/tash/Documents/CMEECourseWork/GLM_week16/code")

require(lme4)
# this is a package that we can use for lmms. MCMCglmm does the same, but this
# one is ok for easier stuff.
require(lmtest)

d <- read.table("../data/DataForMMs.txt", header=T)
str(d)

# data on unicorns - now have bodymass, size, hornlength, 
# but also were able to quantify the amount of glitz

# captured 100 unicorns, all of them more than once, all variables measured at every occasion
# scored reproductive fitness - unicorns can give birth every month, litter sizes 
# vary between 1-11
# was not always possible to scroe repro fitness, if females elusive
# also determined family groups
# and behavioural obs: counted amounts of copulations 

# hypotheses:
# 1) There is sexual dimorphism (trimorphism!) in unicorn body mass, size, and horn
# length
# 2) Heavy unicorns, corrected for sex and glizz, have longer horns
# We also believe that horns are a signalling quality in unicorns. We are not sure if it's
# sexually selected, or maybe something very different or odd. Therefore, we think that
# 3) Unicorns with longer horns are more likely to mate multiply than unicorns with
# shorter horns and
# 4) Unicorns with longer horns have a higher fitnessGiven that glizz seems to play an important role in unicorn biology, we also postulate that
# 5) Glizz is an indicator of quality, and more glizz means a unicorn can secure more
# copulations
# 6) Therefore, unicorns with more glizz have a higher fitness
# 7) All of this really suggests that of course, we assume that the more a unicorn mates, the
# higher its fitness.

# since >1 datapoint for each indiv, need to correct for psuedoreplication
# use random effect - grouping for indiv unicorn

# also have family groups - don't know if these have effect - need to see whether this needs to be corrected for
# to do this, can use LMR test
# 10 diff families (so don't want family as fixed factor - lose many df)
# so family is random effect

d$Sex <- as.factor(d$Sex)
d$Family <- as.factor(d$Family)

max(d$Individual)
d$Individual <- as.factor(d$Individual)
names(d)
str(d)


par(mfrow=c(2,3))
hist(d$LitterSize)
hist(d$Size)
hist(d$Hornlength)
hist(d$Bodymass)
hist(d$Glizz)
hist(d$SexualActivity)
dev.off()


## hypothesis 1 ----
# There is sexual dimorphism (trimorphism!) in unicorn body mass, size, and horn
# length

par(mfrow=c(1,3))
boxplot(d$Bodymass ~ d$Sex)
boxplot(d$Size ~ d$Sex)
boxplot(d$Hornlength ~ d$Sex)
# doesn't appear to be any - need to test

## 1.1 - body mass ----
# simple linear model won't do - pseudorep
# 100 indivs - so cannot use as fixed factors!
# -> lmm w indiv as random effect to account for pseudorep

h1m1 <- lmer(Bodymass ~ Sex + (1|Individual), data=d)
summary(h1m1)
# summary stats confirm that no effect of sex on body mass
# no p vals for lmm, but can look at param ests and corresponding SE
# Sexmale: -0.1, SE 0.15 -- the SE LARGER than the estimate & t val << 2

# maybe variation within and between families clouds the picture...
# add family as a random factor:
h1m2 <- lmer(Bodymass ~ Sex + (1|Individual) + (1|Family), data=d)
summary(h1m2)
# seems that family explains nearly as much variance as individual
# but st dev also quite large

# use likelihood ratio test to see if adding this param improves model:
lrtest(h1m1, h1m2)
# adding an extra param improves the fit stat significantly
# LogLikelihood of the reduced model without family is -2647, and the 
# LogLikelihood of the model with family as random effect is -2630,
# thus 17 units higher
# Chisq test supports this, w v low p value

# SO when running body mass, need to include family and indiv!
# but be aware - st dev  of random effects is BIG - suggests that diff between both/the ratio (indiv/group)
# is uncertain - don't build big hypothesis based on these exact nums!

########################################### -
# Methods: To test the hypotheses that body mass of unicorns is sexually trimorphic, we buld
# a linear mixed model with body mass as response variable. We modelled sex as three-level
# fixed factor (with female as reference). Each unicorn was measured 20 times, and to
# account for this pseudoreplication, we added individual identity as a random effect on the
# intercept. Family group explained a large amount of variation and was added as a random
# effect on the intercept to account for the nested structure of the data.
# 
# Results: We found no sexual trimorphism in body mass, as the mean values for body mass
# did not differ from each other. The mean for females was 0.14±0.27SE (in z-score SD units),
# and male and sex_notsure did not statistically differ from this. The random factor individual
# explained 28% of the variation, and the family group structure explaied 26% of the total
# variation in body mass. We kept family group in the final model because a likelihood-ratio
# test testing this against a model without family revealed that the reduced model explained
# variance statisctically significantly less well (chi-square=33.06, df=1 p<0.001).
# 
# Table 1:
#     
#     Variable             Estimate       Precision
# Fixed effects               b            SE       t value
# Intercept (female)         0.14          0.22        0.66
# Sex (male)                 0.00          0.25        0.00
# Sex (not sure)             0.09          0.37        0.25
# 
# Random effects           Variance      Standard Deviation
# Individual                 0.26          0.51
# Family                     0.24          0.49
# Residual                   0.72          0.85
# 
# Table 1: Linear mixed-effects model with body mass of unicorns as response
# variable.
########################################### -

# could also calculate within-indiv repeatability of body mass
# here, for clarity, not add family group - solely interested in whether indivs 
# keep their body mass steady over time

mR <- lmer(Bodymass ~ 1 + (1|Individual), data=d)
summary(mR)

repeatability <- (0.46 / (0.46+0.72))
repeatability
# = 0.39 -> 39% 
# so means body mass is ish repeatable - ie consistent ish in indivs throughout their lives

# anything above 50% would be high for behaviour
# most morphological traits would expect 70-90%
# anything below 20% would be low for most but the most variable behaviours


## 1.2 - size ----

h1m3 <- lmer(Size ~ Sex + (1|Individual), data=d)
summary(h1m3)

h1m4 <- lmer(Size ~ Sex + (1|Family), data=d)
summary(h1m4)
# singularity in tests - likelihood ratio tests not appropriate...

# get singularity because couldn't converge due to there being no variation between indivs

# clearly sex has no effect on size


## 1.3 - horn length ----

h1m5 <- lmer(Hornlength ~ Sex + (1|Individual), data=d)
summary(h1m5)

h1m6 <- lmer(Hornlength ~ Sex + (1|Individual) + (1|Family), data=d)
summary(h1m6)
# again no convergence - hornlength not differ between unicorns...?


## hypothesis 2 ----
# Heavy unicorns, corrected for sex and glizz, have longer horns.

# ok so we know that we do NOT need to correct for sex - found out above
# that body mass is not sig diff for diff sexes
# but what about glitz?
# and is there any relationship between body mass and horn length?

par(mfrow=c(1,1))
plot(Bodymass ~ Hornlength, data=d, pch=19, cex=0.5)

# looks quite strange really
# high variance in body mass of v short horned and v long horned 
# unicorns compared to ave horned ones

h2m1 <- lmer(Bodymass ~ Hornlength + Glizz + (1|Individual) + (1|Family), data=d)
summary(h2m1)
# no effect of glitz

h2m2<-lmer(Bodymass ~ Hornlength + (1|Individual) + (1|Family), data=d)
summary(h2m2)
# slight positive association between horn length and body mass - but the plot v strange
# look at residuals:
plot(h2m2)
# looks ok
# clearly difference in variance is captured by grouping -> therefore model resids look ok

# in future - would also want to investigate why variance so low for ave-horned unicorns

# in a paper: mention there is a +ve association, but also 
# v v small effect size (0.05) - prob not bio meaningful

plot(Bodymass ~ Hornlength, data=d, pch=19, cex=0.5)
abline(0.16, 0.054)


## hypothesis 3 ----
# We also believe that horns are a signalling quality in unicorns. We are not sure if it's
# sexually selected, or maybe something very different or odd. Therefore, we think that 3)
# Unicorns with longer horns are more likely to mate more often than unicorns with shorter
# horns, and horn length is repeatable.

plot(SexualActivity ~ Hornlength, data=d)

h3m1 <- lmer(SexualActivity ~ Hornlength + (1|Individual), data=d)
summary(h3m1)
# indiv explains no variance

h3m2 <- lmer(SexualActivity ~ Hornlength + (1|Family), data=d)
summary(h3m2)
# family explains the tiniest bit...!

lrtest(h3m1, h3m2)  # model 2 sig better than m1

#### NO! -don't now use lm just because indiv explains no variance - still have to 
# account for pseudo replication!!!!!!! ###
# h3m3 <- lm(SexualActivity ~ Hornlength, data=d)
# summary(h3m3)



# repeatability of horn length
mR <- lmer(Hornlength ~ 1 + (1|Individual), data=d)
summary(mR)
# ~no variance within indivs - horn length is v v repeatable
# i.e does not change throughout an indiv's life 
# if a indiv's horn measured again and again - same measurement

# plot model
plot(SexualActivity ~ Hornlength, data=d)
abline(1.94, 1.03)


## hypothesis 4 ----
# Unicorns with longer horns have a higher fitness

plot(LitterSize ~ Hornlength, data=d)

h4m1 <- lmer(LitterSize ~ Hornlength + (1|Individual), data=d)
summary(h4m1)

h4m2 <- lmer(LitterSize ~ Hornlength + (1|Individual) + (1|Family), data=d)
summary(h4m2)

lrtest(h4m1, h4m2)
# both indiv and family important random effects here

# sig -ve association between horn length and litter size
abline(6.18, -0.76)


## hypothesis 5 ----
# Glizz is an indicator of quality, and more glizz means a unicorn can secure more
# copulations, and glizz is repeatable.

plot(SexualActivity ~ Glizz, data=d)

h5m1 <- lmer(SexualActivity ~ Glizz + (1|Individual), data=d)
summary(h5m1)

h5m2 <- lmer(SexualActivity ~ Glizz + (1|Family), data=d)
summary(h5m2)

# singularity - indiv and family... - no variation between indivs/families

# no sig effect of glizz on num copulations

# repeatability of glizz
mR <- lmer(Glizz ~ 1 + (1|Individual), data=d)
summary(mR)
# yes glizz v repeatable 


## hypothesis 6 ----
# Therefore, unicorns with more glizz have a higher fitness

plot(LitterSize ~ Glizz, data=d)

h6m1 <- lmer(LitterSize ~ Glizz + (1|Individual), data=d)
summary(h6m1)

h6m2 <- lmer(LitterSize ~ Glizz + (1|Individual) + (1|Family), data=d)
summary(h6m2)

lrtest(h6m1, h6m2) # yes indiv and family important for litter size (seen this already)

# glizz does have sig +ve association w litter size
abline(6.22, 0.51)


## hypothesis 7 ----
# All of this really suggests that of course, we assume that the more a unicorn mates, the
# higher its fitness.

plot(LitterSize ~ SexualActivity, data=d)

h7m1 <- lmer(LitterSize ~ SexualActivity + (1|Individual) + (1|Family), data=d)
summary(h7m1)

# IS a sig association, but negative - as sexual activity increases litter size decreases
abline(7.51, -0.69)
