## SwS 12 - ANOVA (Analysis of Variance) and repeatability ----

# testing of difference of variances between groups
# categorical variable as explanatory var
# one expl var = one-way anova, 2 = 2-way etc

# null hypothesis: groups are equal
# assessing whether variability among groups is bigger/smaller than between groups

# AG + WG = T
# among group var/between group (BG) (eg extent of boxplot for a group)
# within group (eg diff between means of the groups)
# total variance

# different from ttest (diff between means)
# anova - diff between variance - look at ratio of AG to WG
# from this can INFER that means differ (but inference NOT actual test like lm or ttest)

## If doing by hand:

# anova table
# among-group - ASS (sum of squares) - k-1 d.f. - mean squares (MSG) = SSG/(k-1) - F stat = MSG/MST
# within group - WSS (sum of squares within groups - residuals) - n-k d.f. - mean squares (MSR) = SSR / (n - k)
# total - TSS (total SS = ASS + WSS) - n-1 d.f.

# k = n of groups (length of j)
# n = sample size (length of i)

# eg calculate ASS
# deviation of the means from the overall mean (see slides for equation..!)
# WSS
# basically 2 main calculations (ASS and WSS) - use to find mean squares and then F

# eg output w p < 0.05, interpretation:
# there are difference between the means
# we don't know where or how big the effect is
# have to perform POST-HOC tests, eg Tukey, LSD (least-sig. differences), etc

## ANOVA vs linear model
# both continuous response var
# anova - can have factorial explanatory w 2/more levels - can't have continuous expl var
# anova - provides secondary stats only vs lm provides primary
# anova need post-hoc testing for effect sizes and to see which categories differ

# anova calculated from results of linear model in r
# anova IS  a linear model, just substandard way to report it
# because we only get secondry stats (F)
# MSSs provide info about variance (somewhat primary)

# linear model summary provides primary stats
# and F-stats
# but info about variance is missing (but residual descriptives)

# why anovas popular?
# can calculate easily - less computationally intensive - and used to be done by hand

# could have 2 analyses where means same but variances v diff - would get diff anova results - meaning of anova about variances not means
# use linear models instead!!!!


# if want to know about variances AND mean estimates
# LINEAR MIXED MODELS - estimate variance components and fixed effects simultaneously  - see sig diffs between groups AND see variances between/within groups
# still get among group var, within group var, t val, etc BUT no p-values


## Hand-out work ----
rm(list=ls())
d<-read.table("../data/SparrowSize.txt", header=TRUE)

# going to explore anovas - use wing length from sparrows data
d1 <- subset(d, d$Wing!="NA")
summary(d1$Wing)
hist(d1$Wing)
# some missing values and some "outliers" - but probably form young/moulting birds

model1 <- lm(Wing ~ Sex.1, data=d1)
summary(model1)
boxplot(d1$Wing ~ d1$Sex.1, ylab="Wing length (mm)")

# from the output, the F stat comes from an ANOVA
anova(model1)  # can see here (F stat = sum of mean squares of between-group estimate / residaul mean squares)

# wing length differs between groups
# by how much? - do t-test post-hoc
t.test(d1$Wing ~ d1$Sex.1, var.equal = TRUE)

# fine for 2 groups, what if we have >2
# let's test for diffs between years
boxplot(d$Mass ~ d$Year)
m2 <- lm(Mass ~ as.factor(Year), data = d)
anova(m2)
# that's lots of years, could do summary
summary(m2) # only get diffs between each year compared to ref 2000
# could work out diff eg between 2004 and 2009 (add their values to ref and then find diff) - but faff

# Tukey's post-hoc
?TukeyHSD
# need model fitted w aov()
?aov
am2 <- aov(Mass ~ as.factor(Year), data=d)
summary(am2)
TukeyHSD(am2)  # get complete table w each combo - diff, up and low CI and 
# p-val (adjusted for multiple comparisons - stat sig. means 1 in 20 will be 
# false positive - here running 55 tests - 55/20 = 2.75 wrongly be stat sig - 
# adjusted here automatically by this percentage) 


## what if there are even more levels?
# use BirdID as factorial now
# each sparrow measured >1 - is wing length same each time an indiv is caught?
# or does length vary
boxplot(d1$Wing ~ d1$BirdID, ylab="Wing length (mm)")
# LOTS of groups - anova helpful here
# first get idea of data, how many birds and how often measured?
require(dplyr)
as_tibble(d1)
glimpse(d1)

# count how many diff birds
## IMPORTANT - to see stucture of data
d1 %>% 
    group_by(BirdID) %>% 
    summarise(count = length(BirdID))
d1 %>% 
    group_by(BirdID) %>% 
    summarise(count = length(BirdID)) %>%  # stop here to see what this done
    count(count)  # finally summary
# from dataset of 1695 obs, 222 birds counted once (not v good data for getting
# within-group estimates)
# but 147 measured twice, even more measured more than that - good - repeated measures

# run anova w BirdID as factor
model3 <- lm(Wing ~ as.factor(BirdID), data=d1)
anova(model3)
# stat significantly more variation among groups (BirdID) than within (residuals)
# here a post-hoc test would have TOO many comparisons to consider
# looking at spread not centrality (variance not means)

# F-stat 8 - means amount of variance between diff birds is 8 times bigger than within birds (residual variance)
# makes sense (if measure an indiv >1 will be more simialr than measuring diff bird)


## Repeatability
# another way of saying our findings: individual birds have consistent wing length
# = bird's wing length is REPEATABLE, r, "intraclass correlation coefficient"
# can also use to assess quality of method - individual observer repeatability

# see Kate Lessell's paper "Unrepeatable repeatabilities: a common mistake" in The Auk journal

# repeatability = ratio of variance of the total variance that is explained by among-group differences
# see equation (among / total) (diff to F stat which is among/residual)
# r is directly biologically interpretable

# cannot ignore group size (see paper- this is common mistake) n0
# calculate n0:
d1 %>%
    group_by(BirdID) %>%
    summarise (count=length(BirdID))
# gives us ni, eg n1 is 1, n2 is 10 etc

d1 %>%
    group_by(BirdID) %>%
    summarise (count=length(BirdID)) %>%
    summarise (sum(count))
# 1695 birds in total - denominator of n0 equation

d1 %>%
    group_by(BirdID) %>%
    summarise (count=length(BirdID)) %>%
    summarise (sum(count^2))
# numerator - 7307

7307/1695
# 4.310914
# subtract this from denominator
1695 - 7307/1695
# 1690.689

# a is 618 (num of groups)
# n0 = 
(1 / (618-1)) * (1695 - 7307/1695)
# 2.740177
# close to 3 ~ roughly a centrality measure of how many obs per group 
# beacuse the difference between num of obs in each group are so extreme:
# have to use this value n0 rather than mean etc

# finally calculate repeatability:
anova(model3)
((13.20-1.62)/2.74)/(1.62+(13.20-1.62)/2.74)
# r = 0.7229
# so ~72% of variation in wing length explained by among-individual diffs
# individuals relatively consistent in their wing length - 
# only (100-72) 18% of variance from residuals (within birds)

# come back to exercises as revision!

# EASIER WAY TO CALCULATE REPEATABILITY -> WITH LINEAR MIXED MODELS:


## SwS 13 - Repeatability with linear mixed models ----

# repeatability - how consistent something is within a group, compared to the whole sample
# easier stat to understand than F stat from anova
# ratio of among-group variance / total variance

# observer repeatability
# eg measuring tarsus consistently is difficult
# individual behaviour - personality - do birds always behave the same 
# way? diff from others? use repeatability to test

# in ecology - lots of uses
# N0 is not sample size (difficult to compute in unbalanced dataset - as above!) - see equations!
# dependent on num of groups and sample size within a group 

# would rather use LINEAR MIXED MODELS- compare linear models and variance analysis
# and robust against mixed-size datasets
# nested data structure - account for repeated measures, pseudoreplication
# need to know how the data is nested

# LMMs
# yi,j = b0 + b1xi,j + alphaj + epsiloni,j
# linear model bit is the same (b0, b1 etc)
# alpha - random factor for a group j - estimate variance component for each group

# estimate variance components and fixed param estimates simultaneously
# complicated but V USEFUL
# BETTER than anova - ditch anova!!!!


# fly dataset - repeatability telling us about measurement error
require(lme4)
a <- read.table("../data/Wylde_single.mounted.txt", header=TRUE)

lmm1 <- lmer(Tarsus_Length ~ 1 + (1|ID), data=a)
# instead of 1 in middle ~1 can add any fixed effects
# 1|ID is the factor that is the random effect
summary(lmm1)
# fixed effects - still get estimate, st er and t-val (no p-val - difficult to calculate d.f. in heterogeneous data - don't do it!)
# from t-val looks like could be significant
# intercept is mean value of tarsus length

# random effects - 
# eg variance explained by ID much larger than residual variance (diff groups (individuals) more different than repeated measures of same indiv)

# can calculate repeatability from this
# have among ID variance and within ID variance
# AV + WV = total variance
# divide among variance (ID intercept) by total - will be big percentage here

# LMMs can deal with unbalanced groups - heterogeneous data
# and estimate variance components and fixed effects at the same time

## hand-out work ----

# investigate repeatability of Femur length
lmm2 <- lmer(Femur_length ~ 1 + (1|ID), data=a)
# repsonse var = femur length
# no fixed effects so 1 + ... (could put sex here or any other fixed effect 
# - but here want to get repeatability without any other influence)
# (1|ID) - specify random effects - those we want the model to use to 
# partition the variance into
# here, partition the variance into variance explained among ID and residuals
summary(lmm2)
# random effects - more varinace explained by among group variance - not much residual variance
# info about data structure - 180 individuals, each measured twice gives 
# total sample size of 360 (this dataset v balanced - could have used anova)
# fixed effects - mean femur length

# calculate repeatability:
Repeatability <- 1.257 / (1.257 + 0.0003)
Repeatability
# >99% variance is among diff individual flies (v little variance within indivs)

# complete exercises as revision!


## SwS 14a - more LMMs - beyond repeatability ----

# can account for data structure - nestedness
# yi,j = b0 + b1xi,j + alphaj + epsiloni,j
# i and j diff levels of nested data
# can have more levels of nestedness:
# yi,j,k = b0 + b1xi,j,k + alpha1j +alpha2k + epsiloni,j,k
# extended model - second random effect alpha2 account for variance among a set of groups
# vs alpha1 accounts for variance among other grouping

# data structure - can cloak patterns, can lead to wrong answers
# NEED to describe data and data structure FIRST, think about:
# summary of eg mean, variance
# repeated measures
# grouping factors
# then do stats!


# sparrow ornament (black bib under bill) increases w age
# effects within individuals (increase over time) and between

o <- read.table("../data/OrnamentAge.txt", header=TRUE)

# first do normal lm (to compare outputs w LMM)
summary(lm(Ornament ~ Age, data=o))
# ave ornament size 34mm, for every year sparrow age increases, ornament 
# increases by 1, stat sig

summary(lmer(Ornament ~ Age + (1|BirdID), data=o))
# accounted for multiple measures from same individual by fitting BirdID as 
# a random effect
# fixed effect estimate (of age) - still stat sig. and similer num to in lm (1ish)
# but also random effects - BirdID explains lots of variance too - as much as
# residual, repeatability of ~50% (this is adjusted repeatability as we have 
# a fixed effect)
# BirdID NEEDS to be included - has big effect - otherwise lots of random 
# noise - potential to affect effect of age

# also want to add in measurement error (observers measure ornament differently)
# fit additional random effect f observer
summary(lmer(Ornament ~ Age + (1|BirdID)+(1|Observer), data=o))
# fixed effect estimate now decreased by ~almost half (age estimate)
# observer variance accounts for A LOT of the variance
# variance from BirdID and residuals decreased - gone into observer variance instead

# throughout bird life, same observer measuring same bird (diff observers 
# measuring diff birds) - without observer included in model - this variance 
# goes into BirdID (but actually coming form observer)

# still some variance from BirdID - birds still more similar to themselves than 
# to others

# next, is there an effect of year? eg maybe varies w cold year,etc
summary(lmer(Ornament ~ Age + (1|BirdID)+(1|Observer)+(1|Year), data=o))
# observer variance now split between observer and year
# observers there for set amount of time (eg phd students)
# so effect from year could be form time OR from the change in observers
# have to make a decision about which one to use!!!
# THINK ABOUT BIOLOGY!!!! - which effect driven by biology and which
# by data structure
# probably this last model driven more by data structure, maybe publish 
# previous one- makes more bio sense

# age has ~half the effect compared to the original lm
# still significance ~same (t-values)
# LMM better model


## SwS 14b - Model selection and simplifications ----

# R^2 not good judge for which model is best (tells how much variance explained by model but if add more variables - fit will increase)
# MOST IMPORTANT  - use biological justifications

# fitting models to data
# improving fit costs d.fs and therefore stat power
# max num of parameters you could fit = num of datapoints -> overfitted
# need to find compromise

# guidelines:
# before running model - think!
# what is question? (eg does climate change affatc growth - but climate change is not good explanatory - lots of effects there - be more specific)
# what is response, explanatory?
# other variables that could affect relationship? if so add them. interactions?

# build MAXIMAL model - inc all variables that are biologically relevant (+interactions that are bio meaningful)
# run this model and examine
# look at variables - remove interactions that are not significant
# look at reduced model - remove main terms only IF not biologically required
# carry on to find final model 
# - important to keep expl var in regardless of whether stat sig - this is the point of the model! 

# other methods
# decide ahead which variables important based on bio and keep them all in (good w Bayesian methods) (Julia does this)
# use model selection info criterion
# forwards-step-wise model selection (DON'T DO THIS)


# when is something a random effect and when fixed?
# rules of thumb:
# random effects are factors (grouping factors, cannot be continuous)
# are you interested in means (fixed) or variance (random)
# want to correct factorial effect but it's not in your question specifically -> random eg effect of year but not interested vs if want to see diffs between years, have a fixed factor
# more than 5 levels: random
# LMM use only w large sample size N (>50)

# model assumptions

# normal residuals - use plot(model) to see residuals
# outliers - are they wrongfully measured? biologically meaningful? 
# - if obviously type exclude, but if not leave - try running model with and without
# what if the plots look terrible? is the response really continuous? if not, non-parametic/GLMs - wrose STICK TO CONTINUOUS VARS
# consider units - check for typos/outliers
# use subsets ot see how strong it affects your conclusions
# data transformation (sometimes unavoidable)

# hypothesis testing
# can reject/accept null hypothesis (accepting null does not mean alternative hypothesis not true!!!)
# mutiple hypothesis testing - accpet error of 5% (20/100 are wrong) -can correct
# for this, eg Bonferroni (don't use blindly!)

# before model:
# visual inspection of data
# are there outliers? - boxplots - bio explanations?
# homogeneity of variances
# normally distributed data? (consider transformation as last resort)
# is data zero-inflated? - lots of zeros (v few actual data - use GLMs)
# collinearity? - use VIF to test (see yesterday)
# visually inspect relationships of interest
# consider which/if any interactions to add
# construct maximal model - consider biology
# simplify model - make sure you can defend simplification
# decide on final model
# run model validation
# interpret model - think logically, biologically - interpret GIVEN the limitations

































