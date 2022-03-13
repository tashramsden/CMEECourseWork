## Linear mixed models - part 1 ----

rm(list=ls())
# setwd("/home/tash/Documents/CMEECourseWork/GLM_week16/code")

require(lme4)
require(lmtest)

d<-read.table("../data/ObserverRepeatability.txt", header=T)
str(d)

# sparrows data, now w observer info 
# - evaluate how much variance explained by diffs in observers

d$GroupN <- as.factor(d$GroupN)
d$StudentID <- as.factor(d$StudentID)
d$HandedNess <- as.factor(d$HandedNess)
d$Leg <- as.factor(d$Leg)
str(d)

# spread of data
hist(d$BillWidth)
hist(d$Tarsus)

# oops! someone has made a typo/error/joke! - remove outlier!
d<-subset(d, d$Tarsus<=40)
d<-subset(d, d$Tarsus>=10)
hist(d$Tarsus)

summary(d$Tarsus)
var(d$Tarsus)

summary(d$BillWidth)
var(d$BillWidth)

# now have a good idea of what the total variance is
# (also clear that not v reliable observers - all trying to measure same thing...!)

# suspect indiv observers more consistent in measuring tarsus and bill than
# between observers

# don't think groups will explain much variance

#############################
# Methods: We are interested in how much variation we introduce as observers when we
# measure morphological features. As traits we use the length of a stuffed sparrow's (Passer
# domesticus) tarsus, and the width of its bill. Every year during the Stats With Sparrows
# course at Imperial College, master students measure these traits repeatedly, using a
# calliper. Both traits are measured in mm to the nearest 0.1 mm. We have now ammased
# data from eight groups, totalling to 266 observations of 113 students.
# 
# To test how much variance is explained by observer and group, we run two mixed-effects
# linear models, one for tarsus length, and one for bill length as response variables. Both
# models will have a similar structure, and the procedure to determine the final model is the
# same for both traits. We model student identity, and group identity, as random effects on
# the intercept. We added no fixed effects, and thus fixed the intercept to 1. We use
# likelihood-ratio tests to test for the statistical significance of each random effect, by testing
# a model including the effect to test against one where this random effect is removed.
#############################

# Tarsus

mT1 <- lmer(Tarsus ~ 1 + (1|StudentID), data = d)
mT2 <- lmer(Tarsus ~ 1 + (1|StudentID) + (1|GroupN), data = d)
lrtest(mT1, mT2)

# LRT (likelihood ratio test) is stat sig for tarsus - so the more complex model explains the data better
# so studentID and group are important to include as random effects

# summary(mT1)
summary(mT2)

# variation explained by Student ID:
3.30 / (3.30 + 2.24 + 0.37) # ~ 60%

# variation explained by group: 
0.37 / (0.37 + 2.24 + 3.30) # ~ 6%

# estimate of tarsus (taking into account above) = 18.2 (SE 0.27)


# Bill width

mBW1 <- lmer(BillWidth ~ 1 + (1|StudentID), data = d)
mBW2 <- lmer(BillWidth ~ 1 + (1|StudentID) + (1|GroupN), data = d)
lrtest(mBW1, mBW2)

# LRT test for bill width not significant so the more complex model (mBW2)
# does not explain the data better - reject

summary(mBW1)

# amount of variance due to studentID
0.6256 / (0.6256 + 0.2311)
# = 0.73 = ~73% 

##########################
# Results (for bill width):

# We tested whether student identity and group identity explained variance in a dataset of
# 342 measurements of a stuffed sparrow's bill width. The likelihood ratio test revealed that
# group identity did not explain statistically significant amounts of variance (chi square =
# 1.21, df = 1, p=0.27), and was thus removed from the final model. Accounting for student
# identity, the final model revealed that the measurement of bill width was on average 6.75mm
# (0.07SE, Table 1). Student identity explained 73% of all variance in the dataset (Table 1).

# Table 1:

# Variable               Estimate         Precision
# Fixed effects             b                SE
# Intercept                6.75             0.07
# 
# Random effects         Variance       Standard Deviation
# Individual               0.63             0.79
# Residual                 0.23             0.48

##########################

# note - big st devs for variance 
