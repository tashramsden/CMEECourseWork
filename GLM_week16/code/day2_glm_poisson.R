#### GLM - POISSON DISTRIBUTION - COUNTS ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/GLM_week16/code")


require(ggplot2)
require(MASS)
require(ggpubr)
require(interactions)


## Fisheries data ----

fish <- read.csv("../data/fisheries.csv", stringsAsFactors = T)
str(fish)

# abund data from diff sites 1977-2002
# density, mean depth in km, period: 1 (1979-1989), 2 (1997-2002)
# lengths of x and y areas sampled
# total area sampled - sweptarea

# investigate whether total abund changes w mean depth of water column

ggplot(fish, aes(x = MeanDepth, y = TotAbund)) +
    geom_point() +
    labs(x = "Mean Depth (km)", y = "Total Abundance") +
    theme_classic()

# basic model
# ln(TotAbund) = B0 + B1*MeanDepth
M1 <- glm(TotAbund ~ MeanDepth, data = fish, family = "poisson")
summary(M1)

# infer that as mean depth increases, total abund decreases
# ln(TotAbund) = 6.64 - 0.63*MeanDepth

# pseudo R^2:
1 - (15770/27779)
# = 0.43

# model validation

# 1. diagnostics
par(mfrow=c(2,2))
plot(M1)
# from 4th plot - looks like lots of outliers - explore this
# cook's distance > 1 generally considered outlier
sum(cooks.distance(M1) > 1)
# 29 outliers
# if only one - might investigate/drop it - but don't want to lose >20 obs...

# dispersion param = 
15770/144
# 109!!! - want this to be ~1

# -> we have v overdispersed data
# the conditional variance is 109 times higher than the conditional mean

# potential reasons:
# outliers - we have identified
# transformation of covariates - not needed because we only have 1 continuous expl var
# missing covariates/interactions - maybe - we've only included 1
# zero-inflation - no - no zeros
# inherent dependency - potentially - could explore the random effect of year

# could add year as fixed factor
# but 13 levels - would lose lots of df
# lets have a look at period:
scatterplot<-ggplot(fish, aes(x=MeanDepth, y=TotAbund, color=factor(Period)))+
    geom_point()+
    labs(x= "Mean Depth (km)", y="Total Abundance")+
    theme_classic()+
    scale_color_discrete(name="Period", labels=c("1979-1989", "1997-2002"))
boxplot<- ggplot(fish, aes(x=factor(Period, labels=c("1979-1989", "1997-2002")), y=TotAbund))+
    geom_boxplot()+
    theme_classic()+
    labs(x="Period", y="Total Abundance")
ggarrange(scatterplot, boxplot, labels=c("A","B"), ncol=1, nrow=2)

# looks like could be a diff relationship between meandepth and totabund w diff periods#
# ie affect of mean depth on tot abund is diff in both periods:
# let's include period as fixed factor w interaction w meandepth

M2 <- glm(TotAbund ~ MeanDepth * factor(Period), data = fish, family = "poisson")
summary(M2)
anova(M2, test="Chisq")

# period does have a significant impact on the affect of mean depth on tot abund
# 2 linear equations:

# Period 1: ln(TotAbund) = 6.83 - 0.66*MeanDepth
# Period 2: ln(TotAbund) = (6.83 - 0.67) + (-0.66+0.12)*MeanDepth
#                        = 6.16 - 0.54*MeanDepth

# dispersion param
14293/142
# 100.65
# reduced but still V overdispersed!

# from here could 1. fit quasi-poisson model or 2. fit negative binomial model

# fitting a negative binomial model
M3 <- glm.nb(TotAbund ~ MeanDepth * factor(Period), data = fish,
             init.theta = 1.982326313, link = log)
summary(M3)
anova(M3, test="Chisq")

# model output from negative binomial v diff
# now suggests no sig diff between slopes for each period, but is sig diff between intercepts

# at this point - might want to run reduced model (w/o interaction) before moving onto model validation
M4 <- glm.nb(TotAbund ~ MeanDepth + factor(Period), data = fish)
summary(M4)
anova(M4, test="Chisq")

# model diagnostics
par(mfrow=c(2,2))
plot(M4)
# now see that outliers aren't outliers (BEST NOT TO REMOVE DATA BECAUSE DOESN'T FIT INITAL MODEL!!!)

# dispersion param
158.23/143
# = 1.11 
# MUCH BETTER!!!!
# have improved dispersion by adding a fixed factor and changing family of glm
# since only have 146 data points, 1.11 acceptable

# interpretation:
# Period 1: ln(TotAbund) = 6.96 - 0.73*MeanDepth
# Period 2: ln(TotAbund) = (6.96 - 0.39) - 0.73*MeanDepth
#                        = 6.57 - 0.73*MeanDepth

# "for every kilometer increase in mean depth total abundance decreased by
# a factor of e^-0.73 or 0.48-fold"

# eg for period 1
# for 1km: TotAbund = 1053.63*0.48 = 505.74
# for 2km: TotAbund = 505.74*0.48 =  242.76
# for 3km: TotAbund = 242.76*0.48 =  116.52
# multiplicative not additive change

# pseudo R^2
1 - 158.23/334.13
# 0.53

# plot the model
# need to make predictions and plot these
# range(fish$MeanDepth)
period1 <- data.frame(MeanDepth = seq(from=min(fish$MeanDepth), 
                                      to=max(fish$MeanDepth),
                                      length=100),
                      Period="1")

period2 <- data.frame(MeanDepth = seq(from=min(fish$MeanDepth), 
                                      to=max(fish$MeanDepth),
                                      length=100),
                      Period="2")

period1_predictions <- predict(M4, newdata = period1, type = "link", 
                               se.fit = TRUE) # the type="link" here predicted the fit and se on the log-linear scale. 
period2_predictions <- predict(M4, newdata = period2, type = "link",
                               se.fit = TRUE)
period1$pred<- period1_predictions$fit
period1$se<- period1_predictions$se.fit
period1$upperCI<- period1$pred+(period1$se*1.96)
period1$lowerCI<- period1$pred-(period1$se*1.96)
period2$pred<- period2_predictions$fit
period2$se<- period2_predictions$se.fit
period2$upperCI<- period2$pred+(period2$se*1.96)
period2$lowerCI<- period2$pred-(period2$se*1.96)
complete<- rbind(period1, period2)

# plotting
ggplot(complete, aes(x=MeanDepth, y=exp(pred)))+ 
    geom_line(aes(color=factor(Period)))+
    geom_ribbon(aes(ymin=exp(lowerCI), ymax=exp(upperCI), 
                    fill=factor(Period), alpha=0.3), show.legend = FALSE)+ 
    geom_point(fish, mapping = aes(x=MeanDepth, y=TotAbund, 
                                   color=factor(Period)))+
    labs(y="Total Abundance", x="Mean Depth (km)")+
    theme_classic()+
    scale_color_discrete(name="Period", labels=c("1979-1989", "1997-2002"))


# simpler way of plotting:
# require(interactions)
interact_plot(M4, pred=MeanDepth, modx = Period, plot.points = T, data = fish)


## Bee mites ----

mites <- read.csv("../data/bee_mites.csv")
# bee mites data contains results from in vitro exp of effect of 4 commercially 
# available acaricides on mites
# each mite group exposed to the tested pesticide and num dead mites counted for 
# 24hrs
# question: regardless of acaricide, how does increasing conc impact the num 
# of dead mites

mites_m1 <- glm(Dead_mites ~ Concentration, data = mites, family = "poisson")
summary(mites_m1)
anova(mites_m1, test="Chisq")

# interpretation:
# ln(num dead mites) = 0.53 + 0.57*Conc
# or
# num dead mites = e^(0.53 + 0.57*Conc)
#                = e^(0.53)*e^(0.57*Conc)

# "for every gram per litre increase of acaricide concentration the number 
# of dead mites increased by a factor of e^(0.57) or 1.77-fold"

# pseudo R^2:
1-(109.25/154.79)
# = 0.29
# so model explains ~29% variation

# model validation

# dispersion
109.25 / 113
# 0.97
# v close to 1 so dispersion not an issue here

# diagnostics
par(mfrow=c(2,2))
plot(mites_m1)
# issues w homogeneity of variances across the predicted values
# reasons: could be we fitted inappropriate model family
# used poisson because have num of dead mites
# BUT actually total num mites varied so don't strictly have poisson data - constrained by the tot num mites

# tomorrow - will reanalyse this data using binomial family!

# lets plot poisson model anyway - can compare w tomorrow
new_data <- data.frame(Concentration = seq(from=min(mites$Concentration),
                                           to=max(mites$Concentration),
                                           length=100))
predictions <- predict(mites_m1, newdata = new_data, type = "link", se.fit = TRUE) 
new_data$pred <- predictions$fit
new_data$se <- predictions$se.fit
new_data$upperCI <- new_data$pred+(new_data$se*1.96)
new_data$lowerCI <- new_data$pred-(new_data$se*1.96)

# plot
ggplot(new_data, aes(x=Concentration, y=exp(pred)))+ 
    geom_line(col="black")+
    geom_ribbon(aes(ymin=exp(lowerCI), ymax=exp(upperCI), alpha=0.1),
                show.legend = FALSE, fill="grey")+ 
    geom_point(mites, mapping = aes(x=Concentration, y=Dead_mites), col="blue")+
    labs(y="Number of Dead Mites", x="Concentration (g/l)")+
    theme_classic()


## Galapagos spp richness ----
gal_rich <- read.table("../data/gala.txt", header=T)
str(gal_rich)
# species = num spp, endemics = num endemics, area = area of island km^2,
# elevation = highest elevation of island in m,
# nearest = dist from nearest island km,
# scruz = sidt from santa cruz in km, adjacent = area of adj island in km^2

# want to know how area of island affects num plant spp

ggplot(data = gal_rich, aes(x = Area, y = Species)) +
    geom_point() +
    theme_classic()

# need to log transform area
ggplot(data = gal_rich, aes(x = log(Area), y = Species)) +
    geom_point() +
    theme_classic()

M1 <- glm(Species ~ log(Area), data=gal_rich, family="poisson")
summary(M1)

# pseudo R^2:
1-(651.67/3510.73)
# = 0.81
# so model explains ~81% variation

# model validation

# dispersion
651.67/28
# 23.27
# clearly overdispersion!

# diagnostics
par(mfrow=c(2,2))
plot(M1)
# look okish but signs of some outliers...
sum(cooks.distance(M1) > 1)

# overdispersion could be explained by missing covariate 
# eblow shows w Adjacent added, did also try Nearest w same result

ggplot(gal_rich, aes(x = log(Adjacent), y =  Species)) +
    geom_point() +
    theme_classic()

M2 <- glm(Species ~ log(Area) + log(Adjacent), data=gal_rich, family="poisson")
summary(M2)

# pseudo R^2:
1-(395.54/3510.73)
# = 0.89

# model validation
# dispersion
395.54/27
# 14.6
# clearly still overdispersion! - less
# diagnostics
par(mfrow=c(2,2))
plot(M2)


# fitting a negative binomial model
M3 <- glm.nb(Species ~ log(Area) + log(Adjacent), data=gal_rich,
             init.theta = 1.982326313, link = log)
summary(M3)

# adjacent not significant anymore, remove as covariate

M4 <- glm.nb(Species ~ log(Area), data=gal_rich,
             init.theta = 1.982326313, link = log)
summary(M4)
anova(M4, test="Chisq")
# ln(Species) = 3.22 + 0.35*log(Area)

# pseudo R^2:
1-(32.604/130.161)
# = 0.75
# so model explains ~75% variation

# model validation

# dispersion
32.604/28
# 1.16
# MUCH better than before!

# diagnostics
par(mfrow=c(2,2))
plot(M4)
sum(cooks.distance(M4) > 1)
# look much better

# make predictions and plot!
new_data <- data.frame(Area = seq(from=min(gal_rich$Area),
                                  to=max(gal_rich$Area),
                                  length=100))
predictions <- predict(M4, newdata = new_data, type = "link", se.fit = TRUE) 
new_data$pred <- predictions$fit
new_data$se <- predictions$se.fit
new_data$upperCI <- new_data$pred+(new_data$se*1.96)
new_data$lowerCI <- new_data$pred-(new_data$se*1.96)

# plot
ggplot(new_data, aes(x=log(Area), y=exp(pred)))+ 
    geom_line(col="black")+
    geom_ribbon(aes(ymin=exp(lowerCI), ymax=exp(upperCI), alpha=0.1),
                show.legend = FALSE, fill="grey")+ 
    geom_point(gal_rich, mapping = aes(x=log(Area), y=Species), col="blue")+
    labs(y="Number of Species", x="log(Area) (km^2)")+
    theme_classic()


## Amphibian road kills in Portugal ----
road_kills <- read.table("../data/RoadKills.txt", header=T)
# How does the distance to the nearby park affect the num road kills?

str(road_kills)
# TOT.N = tot num road kills
# D.PARK = dist to nearest park in m

ggplot(road_kills, aes(x = D.PARK, y = TOT.N)) +
    geom_point() +
    theme_classic()

M1 <- glm(TOT.N ~ D.PARK, data=road_kills, family="poisson")
summary(M1)

# deviance 
390.9/50
# = 7.8

par(mfrow=c(2,2))
plot(M1)

# deviance too high - notes specify to focus only on this factor - so try negative binom dist...

M2 <- glm.nb(TOT.N ~ D.PARK, data=road_kills,
             init.theta = 1.982326313, link = log)
summary(M2)
# ln(num kills) = 4.41 - 0.00012*DistNearestPark

# num road kills = e^(4.41 - 0.00012*DistNearestPark)
#                = e^(4.41)*e^(-0.00012*DistNearestPark)

# "for every m increase in dist to nearest park the num of amphibian
# road kills decreased by factor of e^(-0.00012) or 0.99-fold"

# pseudo R^2
1 - (54.742/155.445)
# 0.65

# deviance
54.742/50 # great!

plot(M2) # look alright ish

new_data <- data.frame(D.PARK = seq(from=min(road_kills$D.PARK),
                                           to=max(road_kills$D.PARK),
                                           length=10000))
predictions <- predict(M2, newdata = new_data, type = "link", se.fit = TRUE) 
new_data$pred <- predictions$fit
new_data$se <- predictions$se.fit
new_data$upperCI <- new_data$pred+(new_data$se*1.96)
new_data$lowerCI <- new_data$pred-(new_data$se*1.96)

# plot
ggplot(new_data, aes(x=D.PARK, y=exp(pred)))+ 
    geom_line(col="black")+
    geom_ribbon(aes(ymin=exp(lowerCI), ymax=exp(upperCI), alpha=0.1),
                show.legend = FALSE, fill="grey")+ 
    geom_point(road_kills, mapping = aes(x=D.PARK, y=TOT.N), col="blue")+
    labs(y="Number of Amphibian Road Kills", x="Distance to Nearest Park (m)")+
    theme_classic()

summary(M2)
# ln(num kills) = 4.41 - 0.00012*DistNearestPark

# num road kills = e^(4.41 - 0.00012*DistNearestPark)
#                = e^(4.41)*e^(-0.00012*DistNearestPark)

# "for every m increase in dist to nearest park the num of amphibian
# road kills decreased by factor of e^(-0.00012) or 0.99-fold"

