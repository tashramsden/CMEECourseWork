#### GLM - BINARY AND BINOMIAL DISTRIBUTIONS ----

rm(list=ls())
# setwd("Documents/CMEECourseWork/GLM_week16/code")

require(ggplot2)
require(ggpubr)

#### Binary models ----

## Varoa spp in honeycomb cells ----

worker <- read.csv("../data/workerbees.csv", stringsAsFactors = T)
str(worker)

# data on worker bee (Apis mellifera) brood honeycomb cell size and prevalence 
# of parasitic mite (Varoa destructor)

scatterplot<-ggplot(worker, aes(x=CellSize, y=Parasites))+
    geom_point()+
    labs(x= "Cell Size (cm)", y="Probability of Parasite")+
    theme_classic()
boxplot<- ggplot(worker, aes(x=factor(Parasites), y=CellSize))+
    geom_boxplot()+
    theme_classic()+
    labs(x="Presence/Absence of Parasites", y="Cell Size (cm)")
ggarrange(scatterplot, boxplot, labels=c("A","B"), ncol=1, nrow=2)

M1 <- glm(Parasites ~ CellSize, data=worker, family="binomial")
summary(M1)
anova(M1, test="Chisq")

# interpretation:
# logit(ProbParasites) = -11.25 + 22.18*CellSize

# increasing cell size of honeycomb increases prob of being infected w v. destructor

# take inverse logit of 22.18:
plogis(coef(M1))
# = 1
# so for every cm increase in cell size, prob of being infected increases
# by factor of 1, or 100%

# "flip" point, value of x where prob flips from being less likely to more likely to be infected
# since B0 -ve, B1 +ve, flip = B0/B1:
11.25 / 22.18
# = 0.51 cm
# so honeycomb cell size of > 0.51 cm more likely to be infected by V. destructor

# plot
new_data <- data.frame(CellSize=seq(from=min(worker$CellSize),
                                    to=max(worker$CellSize),
                                    length=100))
predictions<- predict(M1, newdata = new_data, type = "link", se.fit = TRUE) 
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

ggplot(new_data, aes(x=CellSize, y=plogis(pred)))+ 
    geom_line(col="black")+
    geom_point(worker, mapping = aes(x=CellSize, y=Parasites), col="blue")+
    geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2),
                show.legend = FALSE)+ 
    labs(y="Probability of Infection", x="Cell Size (cm)")+
    theme_classic()

# pseudo R^2
1 - (1104.9 / 1259.6)
# = 0.12


## Chytrid infection status in the Pyrenees ----
chytrid <- read.csv("../data/chytrid.csv", stringsAsFactors = T)
str(chytrid)

# InfectionStatus (0=negative, 1=positive) of amphibians sampled from
# range of lakes and ponds in Pyrenees from 2003 to 2018
# also annual rainfall and temp climate vars:
# AnnualaverageRf= rainfaill in mm; AnnualaverageTmax, AnnualaverageTmin, AnnualaverageTavg and Springavgtemp in degrees celsius

# examine relationship between ave spring temp on chytrid infection status

scatterplot<-ggplot(chytrid, aes(x=Springavgtemp, y=InfectionStatus))+
    geom_point()+
    labs(x="Average Spring Temperature (Degrees Celsius)", 
         y="Probability of Infection")+
    theme_classic()
boxplot<- ggplot(chytrid, aes(x=factor(InfectionStatus), y=Springavgtemp))+
    geom_boxplot()+
    theme_classic()+
    labs(x="Presence/Absence of Infection", 
         y="Average Spring Temperature (Degrees Celsius)")
ggarrange(scatterplot, boxplot, labels=c("A","B"), ncol=1, nrow=2)

# separation not v apparent but ecological research has indicated that increasing
# spring temp increases prob of chytrid fungus infection in amphibians

M2 <- glm(InfectionStatus ~ Springavgtemp, data = chytrid, family = "binomial")
summary(M2)
anova(M2, test="Chisq")

# interpretation
# logit(ProbInfection) = -0.06 + 0.05*AveSpringTemp

# flipping point = B0/B1
0.06 / 0.05
# = 1.2 degrees C

# amphibians experiencing spring temp > 1.2 degrees C more likely to be
# infected w chytrid

# pseudo R^2
1 - (9270.7 / 9310.0)
# = 0.004
# so model able to explain 0.4% variation in presence/absence of chytrid fungus

# plot
new_data <- data.frame(Springavgtemp=seq(from=min(chytrid$Springavgtemp),
                                         to=max(chytrid$Springavgtemp),
                                         length=100))
predictions<- predict(M2, newdata = new_data, type = "link", se.fit = TRUE) # the type="link" here predicted the fit and se on the log-linear scale. 
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

ggplot(new_data, aes(x=Springavgtemp, y=plogis(pred)))+ 
    geom_line(col="black")+
    geom_point(chytrid, mapping = aes(x=Springavgtemp, y=InfectionStatus),
               col="blue")+
    geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2),
                show.legend = FALSE)+ 
    labs(y="Probability of Infection", x="Average Spring Temperature (Degrees Celsius)")+
    theme_classic()


#### Binomial models ----

## Chytrid binomial ----

## going to analyse chytrid data above again but as binomial outcome:
# num positives / num negatives

chytrid_binomial<- read.csv("../data/chytrid_binomial.csv", stringsAsFactors = T)
str(chytrid_binomial)
# this data is condensed version of chytrid.csv
# 2 new columns: 
# Positves = num +ve samples per year, site, habitat and larval stage
# Total = total num samples 

# have to feed num +ve and num -ve into glm using cbind:

M3 <- glm(cbind(Positives, Total-Positives) ~ AverageSpringTemp,
          data = chytrid_binomial, family="binomial")
summary(M3)
anova(M3, test="Chisq")

# interpretation
# logit(ProbInfection) = -0.40 + 0.09*AveSpringTemp

# pseudo R^2
1 - (4795.7 / 5055.4)
# = 0.05
# this model explains 5% variation - more than when as binary...

# model validation
# dispersion
4795.7 / 173
# = 27.7
# clearly v overdispersed

# possible reasons:
# model too simple - several variables that could be:
#                                 random effects (Year, Site),
#                                 fixed factors (Habitat, LarvalStage)
#                                 continuous covariates (AverageRf)
# one or zero outliers (maybe - see diagnostic plots below)

par(mfrow=c(2,2))
plot(M3)
sum(cooks.distance(M3)>1) # 2 outliers

# could explore adding covariates and/or random effects

# for now, just going to fit a quasi-binomial model

M4 <- glm(cbind(Positives, Total-Positives) ~ AverageSpringTemp,
          data = chytrid_binomial, family = "quasibinomial")
summary(M4)
anova(M4, test="F") # for quasi approaches we use the F test 

# estimate vals haven't changed, st error inflated

# plot this model:
new_data <- data.frame(AverageSpringTemp=seq(from=min(chytrid_binomial$AverageSpringTemp),
                                             to=max(chytrid_binomial$AverageSpringTemp),
                                             length=100))
predictions<- predict(M4, newdata = new_data, type = "link", se.fit = TRUE) # the type="link" here predicted the fit and se on the log-linear scale. 
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

ggplot(new_data, aes(x=AverageSpringTemp, y=plogis(pred)))+ 
    geom_line(col="black")+
    geom_point(chytrid_binomial, 
               mapping = aes(x=AverageSpringTemp, y=(Positives/Total)),
               col="blue")+
    geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2),
                show.legend = FALSE)+ 
    labs(y="Probability of Infection",
         x="Average Spring Temperature (Degrees Celsius)")+
    theme_classic()


## Bee mites - revisited (see yesterday) ----

mites = read.csv("../data/bee_mites.csv")
str(mites)
# previously fitted poisson model - concluded prob not right model family, binomial would be better
# used poisson because num dead mites, but actually tot num mites varies

M5 <- glm(cbind(Dead_mites, Total-Dead_mites) ~ Concentration, 
          data = mites, family = "binomial")
summary(M5)
anova(M5, test="Chisq")

# model validation

# dispersion
194.82 / 113
# = 1.72
# model is overdispersed - plenty of possible reasons

# model diagnostics
par(mfrow=c(2,2))
plot(M5)
# has corrected previous criticism of unequal variances in the “Residuals vs Fitted” and the “Scale-Location” plots
# changing the model has corrected for this

# could fit a quasi-binomial to account for overdispersion
M6 <- glm(cbind(Dead_mites, Total-Dead_mites) ~ Concentration,
          data = mites, family = "quasibinomial")

# plot
new_data <- data.frame(Concentration=seq(from=min(mites$Concentration),
                                         to=max(mites$Concentration),
                                         length=100))
predictions<- predict(M6, newdata = new_data, type = "link", se.fit = TRUE) 
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

ggplot(new_data, aes(x=Concentration, y=plogis(pred)))+ 
    geom_line(col="black")+
    geom_point(mites, mapping = aes(x=Concentration, y=(Dead_mites/Total)), col="blue")+
    geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2), show.legend = FALSE)+ 
    labs(y="Probability of Infection", x="Concentration")+
    theme_classic()
# compare to plot yesterday - see more informative - num dead mites yesterday not fair - diff tots


## Endemicity on Galapagos islands ----

endemics <- read.table("../data/gala.txt", header=T)
str(endemics)

# how does area of island affect the endemicity (the proportion/probability of endemic spp out of tot spp)

ggplot(data = endemics, aes(x = Area, y = Endemics)) +
    geom_point() +
    theme_classic()

# need to log transform area
ggplot(data = endemics, aes(x = log(Area), y = Endemics)) +
    geom_point() +
    theme_classic()

# will be binomial - num endemics / num not endemics
# tot num spp diff for diff islands

M7 <- glm(cbind(Endemics, Species-Endemics) ~ log(Area),
          data = endemics, family = "binomial")
summary(M7)
anova(M7)

# dispersion
110.33 / 28
# is overdispersed

# diagnostics
par(mfrow=c(2,2))
plot(M7)

# try quasi-binomial
M8 <- glm(cbind(Endemics, Species-Endemics) ~ log(Area),
          data = endemics, family = "quasibinomial")
summary(M8)
plot(M8)

# plot
new_data <- data.frame(Area=seq(from=min(endemics$Area),
                                to=max(endemics$Area),
                                length=100))
predictions<- predict(M8, newdata = new_data, type = "link", se.fit = TRUE)
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

ggplot(new_data, aes(x=log(Area), y=plogis(pred)))+ 
    geom_line(col="black")+
    geom_point(endemics, mapping = aes(x=log(Area), y=(Endemics/Species)), col="blue")+
    geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2), show.legend = FALSE)+ 
    labs(y="Probability of Endemicity", x="log(Area)")+
    theme_classic()


dev.off()
