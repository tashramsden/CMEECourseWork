## Bivariate models - variance-covariance analysis ----

rm(list=ls())
# setwd("/home/tash/Documents/CMEECourseWork/GLM_week16/code")

require(MCMCglmm)

d <- read.table("../data/SparrowSize.txt", header=TRUE)
str(d)
d$Sex.1 <- as.factor(d$Sex.1)
d$CaptureDate <- as.factor(d$CaptureDate)
d$CaptureTime <- as.factor(d$CaptureTime)

names(d)
head(d)

# want to explore variance in tarsus and wing among and within
# indivs and cohorts in sparrows

# predict: both traits repeatable - so var between indivs should be larger than var within
# therefore expect that BirdID explains lots of variance

# also expect cohort explains some variance - indivs from same cohort exposed
# to same conditions when growing - when adult size determined

# have some NAs in data - remove these:
# and know that sex is importnat in size variables, will want to correct for this:

# will use range of linear models, inc. bivariate models

dat <- d[ which( d$Tarsus!="NA" & d$Wing!="NA" & d$Sex!="NA" &
                     d$Cohort!="NA") , ]
d1 <- data.frame(d$Tarsus, d$Wing, d$Sex)
pairs(d1, pch=19, cex=0.7)

cor.test(dat$Wing, dat$Tarsus)

var(dat$Wing)
var(dat$Tarsus)
mean(dat$Wing)
mean(dat$Tarsus)

# first build maximal model w/o covariance (for now!)
# cohort and BirdID = random effects
# sex = fixed effect

mMaxNoCov <- MCMCglmm(cbind(Tarsus, Wing) ~ trait-1 + trait:Sex,
                      random = ~idh(trait):BirdID + idh(trait):Cohort, 
                      rcov = ~idh(trait):units,
                      family = c("gaussian","gaussian"),
                      data=dat, verbose=FALSE)
plot(mMaxNoCov)

# can see that the 2 intercepts make sense - in right ballpark

# seems to be sig sex effect on tarsus and definitely on wing (density plots do not overlap 0 (or marginally for tarsus:sex))

# birdID plots for both traits look sensible (maybe a bit thin - could run for longer)

# plot for cohrot terrible - worse for tarsus still bad for wing

# residuals (units) look ok 

# so, run this model for longer - maybe keep in mind whether cohort is good thing to have in here ta all..
# set num iters to 100000 (takes longer to run)

mMaxNoCov <- MCMCglmm(cbind(Tarsus, Wing) ~ trait-1 + trait:Sex,
                      random = ~idh(trait):BirdID + idh(trait):Cohort, 
                      rcov = ~idh(trait):units,
                      family = c("gaussian","gaussian"),
                      data=dat, nitt=100000, verbose=FALSE)
plot(mMaxNoCov)

# looks better - but cohort still rubish - maybe it's a useless variable
# check the summary:

summary(mMaxNoCov)

# focus on cohort
# variance explained by cohort nearly 0 for tarsus, but present in wing
# so explains some var in wing therefore SHOULD stay in model
# also we cannot have covariance in cohort (variance of wing is 0 - if no 
# variance in one variable then cannot be covariance between them!)

# so full model:
# use us(trait): for BirdID
# but idh for cohort
# means estimate covariance for birdID not for cohort

mFull <- MCMCglmm(cbind(Tarsus, Wing) ~ trait-1 + trait:Sex,
                  random = ~us(trait):BirdID + idh(trait):Cohort, 
                  rcov = ~us(trait):units,
                  family = c("gaussian","gaussian"),
                  data=dat, nitt=100000, verbose=TRUE)
# verbose = TRUE means will see print of progress
plot(mFull)
# plots look good

# check autocorrelation (make sure on right track)
# first for fixed effects (remember: Sol is for solutions)
autocorr(mFull$Sol)
# and for random effects (VCV = VarianceCoVariance)
autocorr(mFull$VCV)

# all look good (want v low, uncorrelated values for lag 10 and higher)


# now look at summary and interpret results:

summary(mFull)

# interpretation:

# starting w FIXED EFFECTS (at bottom of summary - "location effects") 
# so we included trait-1 (means estimate intercepts for each variable separately)
# and wanted to see effect of sex on each var too

# intercepts make sense - similar to overall means of tarsus and wing
# are stat sig diff from 0 (no surprise)
# sex effect in tarsus is 0.16 - so males are a little bit larger than females
# males also have longer wings than females
# both effects do not span 0 -> are stat sig diff from 0 (95CI more improtant than p value)


# RANDOM EFFECTS (see "G structure" section) - BirdID and Cohort

# BirdID:
# get 4 param ests for BirdID - one each for variance of tarsus and wing,
# 2 for covariance
# covariance is stat sig diff from 0 (95CI not span 0) ~ 0.65
# for variances not so easy to tell if sig (cannot be 0 - therefore CI won't span 0)
# but for both wing and tarsus the lower 95CI is far from 0 and narrow range -> 
# so confident that these variances are significant
# for both traits - quite some variance explained by BirdID

# Cohort:
# only has 2 param ests as we did not estimate covariance
# clear that variance in tarsus explained by cohort is 0
# a little bit more variance in wing explained by cohort - but also close to 0

# maybe run model w/o cohort - see if fit improves (do that further below - after rest of interpretation of this model)


# RESIDUALS ("R-structure")
# some residual variance left in both traits - especially tarsus, but not much
# also sig +ve residual covariance between wing and tarsus (95CI not overlap 0) - so that's ok


## IMPORTANT NOTE ON CI:
# can sometimes use the overlap of the 95CIs with zero for assessing 
# statistical significance (fixed parameter estimates, covariances),
# and sometimes we can't (variances) - variances cannot < 0


# reduced model w/o cohort:
m2 <- MCMCglmm(cbind(Tarsus, Wing) ~ trait-1 + trait:Sex,
               random = ~us(trait):BirdID,
               rcov = ~us(trait):units, 
               family = c("gaussian","gaussian"),
               data=dat, nitt=100000, verbose=FALSE)

mFull$DIC
m2$DIC

# so is a good idea to leave cohort in 
# lower DIC = better
# so keep full model as final model

# now know quite strong covariance BETWEEN birds (BirdID covariance)
# makes sense as it means birds w longer wings have longer tarsi too

# is however some covariance (+ve) with residuals 
# means that WITHIN birds (repeated measures), if have longer tarsi have longer wings too:

# may come from 2 sources
# first: maybe not all measured birds fully grown - so within birds might 
# be some variation (although not a lot) that covaries
# second: could be that this stems from diff observers (maybe one observer who 
# always measures too long would measure wing and tarsus of same bird 
# longer than another observer)

