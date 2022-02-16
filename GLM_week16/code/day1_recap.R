## Recap of linear models

rm(list=ls())
# setwd("Documents/CMEECourseWork/GLM_week16/code")

d<-read.table("../data/SparrowSize.txt", header=TRUE)
str(d)
names(d)
head(d)

# Centrality and spread ----

# histograms depict frequencies
hist(d$Tarsus, main="", xlab="Sparrow tarsus length (mm)", col="grey")

mean(d$Tarsus, na.rm = TRUE)
var(d$Tarsus, na.rm = TRUE)
sd(d$Tarsus, na.rm = TRUE)  # area in which 68.2% of data points would fall if repeated - prediction

# densities - probability of data occuring - better!
hist(d$Tarsus, main="", xlab="Sparrow tarsus length (mm)", col="grey",
     prob=TRUE) # this argument tells R to plot density instead of frequency, you can see that on the y-axis
lines(density(d$Tarsus,na.rm=TRUE), # density plot
      lwd = 2)
abline(v = mean(d$Tarsus, na.rm = TRUE), col = "red",lwd = 2)
abline(v = mean(d$Tarsus, na.rm = TRUE) - sd(d$Tarsus, na.rm = TRUE), 
       col = "blue", lwd = 2, lty=5)
abline(v = mean(d$Tarsus, na.rm = TRUE) + sd(d$Tarsus, na.rm = TRUE),
       col = "blue",lwd = 2, lty=5)
# prob of observing mean in a sample ~0.5
# interestingly- 2 peaks - would expect smoothing out w large dataset - so what here?
# maybe slight sexual dimorphism in tarsus length where females have shorter tarsi than males
# test this hypothesis:
t.test(d$Tarsus~d$Sex)

par(mfrow=c(2,1))
hist(d$Tarsus[d$Sex==1], main="", xlab="Male sparrow tarsus length (mm)", col
     ="grey", prob=TRUE)
lines(density(d$Tarsus[d$Sex==1],na.rm=TRUE), lwd = 2)
abline(v = mean(d$Tarsus[d$Sex==1], na.rm = TRUE), col = "red",lwd = 2)
abline(v = mean(d$Tarsus[d$Sex==1], na.rm = TRUE) - 
           sd(d$Tarsus[d$Sex==1], na.rm = TRUE), col = "blue",lwd = 2, lty=5)
abline(v = mean(d$Tarsus[d$Sex==1], na.rm = TRUE) + 
           sd(d$Tarsus[d$Sex==1], na.rm = TRUE), col = "blue",lwd = 2, lty=5)
hist(d$Tarsus[d$Sex==0], main="", xlab="Female sparrow tarsus length (mm)", 
     col="grey", prob=TRUE)
lines(density(d$Tarsus[d$Sex==0],na.rm=TRUE), lwd = 2)
abline(v = mean(d$Tarsus[d$Sex==0], na.rm = TRUE), col = "red",lwd = 2)
abline(v = mean(d$Tarsus[d$Sex==0], na.rm = TRUE) - 
           sd(d$Tarsus[d$Sex==0], na.rm = TRUE), col = "blue",lwd = 2, lty=5)
abline(v = mean(d$Tarsus[d$Sex==0], na.rm = TRUE) + 
           sd(d$Tarsus[d$Sex==0], na.rm = TRUE), col = "blue",lwd = 2, lty=5)
dev.off()

# yes, there is a difference in tarsus length
# but 2 peaks still seen in female data, not male
# maybe, when not fully molter males can be mistaken for females - juveniles both sexes look alike
# but odd that only females not males
# or maybe a measurement tool that was used on more females was off....


# Variance
# square of the sum of the residuals divided by sample size - 1
# or: square of st dev

var(d$Tarsus,na.rm=TRUE)
sd(d$Tarsus,na.rm=TRUE)
sd(d$Tarsus,na.rm=TRUE)^2
sqrt(var(d$Tarsus,na.rm=TRUE))

# variances are additive - can partition them
# some variance rules:
# 1.
# sum of 2 indep variables, take variance from this == sum of the 2 variances for the variables separately
d1<-subset(d, d$Tarsus!="NA")
d1<-subset(d1, d1$Wing!="NA")

sumz<-var(d1$Tarsus)+var(d1$Wing)
test<-var(d1$Tarsus+d1$Wing)
sumz
test
# sumz != test here - variables must be INDEPENDENT for the rule to work
# look at wing length and tarsus
plot(jitter(d1$Wing),d1$Tarsus, pch=19, cex=0.4)
# don't look v independent - longer tarsus, longer wing

# if the variables are NOT independent - take into account covariance:

# UPDATE RULE:
# If you sum up two variables, then the variance of that summed-up variable 
# is the sum of the two variances and twice their covariance

cov(d1$Tarsus,d1$Wing)
sumz<-var(d1$Tarsus)+var(d1$Wing)+2*cov(d1$Tarsus,d1$Wing)
test<-var(d1$Tarsus+d1$Wing)
sumz
test
# now sumz == test

# this rule still true even if variables are independent (cov == 0)


# 2.
# When you multiply a variable with a constant its variance equals the variance 
# multiplied with the same constant, but squared:
# var(tarsus*10) = 10^2 * var(tarsus)

var(d1$Tarsus*10)
var(d1$Tarsus)*10^2


## Linear models ----

# unicorn dataset
# test hypothesis that heavier unicorns have longer horns

# data
uni<-read.table("../data/RUnicorns.txt", header=T)
str(uni)
head(uni)

# descriptive stats
mean(uni$Bodymass)
sd(uni$Bodymass)
var(uni$Bodymass)
hist(uni$Bodymass)

mean(uni$Hornlength)
sd(uni$Hornlength)
var(uni$Hornlength)
hist(uni$Hornlength)

# plot model
plot(uni$Bodymass ~ uni$Hornlength, pch=19, 
     xlab="Unicorn horn length", ylab="Unicorn body mass", col="blue")
mod <- lm(uni$Bodymass ~ uni$Hornlength)
abline(mod, col="red")
res <- signif(residuals(mod), 5)
pre <- predict(mod)
segments(x0 = uni$Hornlength, y0 = uni$Bodymass, 
         x1 = uni$Hornlength, y1 = pre, 
         col="black")
# ?segments

# maybe residuals bigger w large horns...check later

# seems to support hypothesis...
# but what if long-horned unicorns larger -> therefore heavier
# or pregnant and long-horned unicorns more likely pregnant
# or long-horned unicorns more glitzier and the glitz is heavy?!
# or horns seasonal
# or etc etc etc

# stats can never solve causality but can try to determine which variable explains most variation

# 1. Outliers?
# 2. Homogeneity of variances?
# 3. Normal distributed?
# 4. Zero-inflation?
# 5. Collinearity among covariates?
# 6. Plot data
# 7. Which covariates, fixed factors, and interactions?
# 8. Maximal model
# 9. Model selection
# 10. Make a decision
# 11. Model validation
# 12. Interpretation

hist(uni$Bodymass)
hist(uni$Hornlength)
hist(uni$Height)
# overall okish - not v normal but fine
# no zero-inflation
# collinearity:
cor.test(uni$Hornlength, uni$Height)
# seem to be independent
boxplot(uni$Bodymass ~ uni$Gender)
# females heavier, but also larger variance - pregnancy?...
par(mfrow=c(2,1))
boxplot(uni$Bodymass ~ uni$Pregnant)
plot(uni$Hornlength[uni$Pregnant==0], uni$Bodymass[uni$Pregnant==0], pch=19, 
     xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(uni$Hornlength[uni$Pregnant==1], uni$Bodymass[uni$Pregnant==1], pch=19,
       col="red")
# clearly things to account for to better understand bodymass variation...
par(mfrow=c(1,1))
boxplot(uni$Bodymass~uni$Pregnant)

plot(uni$Hornlength[uni$Gender=="Female"], uni$Bodymass[uni$Gender=="Female"],
     pch=19, xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(uni$Hornlength[uni$Gender=="Male"], uni$Bodymass[uni$Gender=="Male"],
       pch=19, col="red")
points(uni$Hornlength[uni$Gender=="Undecided"], uni$Bodymass[uni$Gender=="Undecided"],
       pch=19, col="green")
# looks like there is a sex effect in body mass and horn length
# males heavier and longer horns than females and undecided unicorns

boxplot(uni$Bodymass~uni$Glizz)
plot(uni$Hornlength[uni$Glizz==0], uni$Bodymass[uni$Glizz==0], pch=19, 
     xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(uni$Hornlength[uni$Glizz==1],uni$Bodymass[uni$Glizz==1], 
       pch=19, col="red")
# unicorns w glitz are heavier and have longer horns than those w/o

# SO: - in the model we want gender, pregnancy and glitz 
# - height is difficult - we'll run it but don't think important so can throw it out
# full model:
FullModel <- lm(uni$Bodymass ~ uni$Hornlength + uni$Gender + uni$Pregnant + uni$Glizz)
summary(FullModel)

# seems like pregnancy and glitz are important predictors for body mass
# not horn length and gender?!
# only female unicorns can get pregnant - means that pregnancy factor not useful 
# for any other unicorns - and only 2 unicorns are pregnant - 
# try model with those values excluded:

u1 <- subset(uni, uni$Pregnant==0)
FullModel <- lm(u1$Bodymass ~ u1$Hornlength + u1$Gender + u1$Glizz)
summary(FullModel)

# according to this model - don't need gender to explain body mass

ReducedModel <- lm(u1$Bodymass ~ u1$Hornlength + u1$Glizz)
summary(ReducedModel)

plot(u1$Hornlength[u1$Glizz==0], u1$Bodymass[u1$Glizz==0], 
     pch=19, xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(u1$Hornlength[u1$Glizz==1], u1$Bodymass[u1$Glizz==1], pch=19, col="red")
abline(ReducedModel)
# get warning here - abline only plotted for first 2 of 3 regression coefs
# only plotted for horn length - but that est already takes glitz into account
# important!! - usually only plots first variable of multiple vars in model

# maybe would be better plotting w/o glitz:
ModForPlot <- lm(u1$Bodymass ~ u1$Hornlength)
summary(ModForPlot)
plot(u1$Hornlength[u1$Glizz==0], u1$Bodymass[u1$Glizz==0],
     pch=19, xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(u1$Hornlength[u1$Glizz==1], u1$Bodymass[u1$Glizz==1], pch=19, col="red")
abline(ModForPlot)
# does look better - but does not reflect the biological effects
# looking at summary stats - can see diff in param ests eg horn length 0.4 higher for plotting model

# INTERPRETATION:
# some variation in body mass explained by pregnancy 
# excluded this because we're not interested in unicorn repro now
# some variation in body mass explained by decorative glitz - quite a lot
# (ModForPlot) ~46% variation explained by horn length
# (ReducedMod) ~61% explained by horn length and glitz
# so glitz does explain a good chunk of the variation
# because of additive variation rule: 61 - 46 = 15% variation in body 
# mass explained by glitz ONLY: IF hornlength and glitz INDEPENDENT, 
# check this:
boxplot(u1$Hornlength ~ u1$Glizz)
t.test(u1$Hornlength ~ u1$Glizz)
# seems that unicorns w longer horns more likely to have glitz
# variances do differ between the groups - not the cleanest relationship
# but is stat sig

# so these variables are NOT independent
# cannot use simple additive rule 

# but we can say unicorns w longer horns are heavier
# and unicorns w glitz are heavier
# also some collinearity between horn length and glitz (unicorns w longer horns have more glitz)


# check model for violations of assumptions: ----
# already know horn length and glitz not independent - but we ~can interpret and are cautious about exact nums
plot(ReducedModel)
# 14 quite the odd one out, so are 6 and 12 - have a look:
View(u1)
# doesn't seem to be anything unusual w Betty Striker Boot Rogue, Ian the Daggar, and Ambrose Buoy Christopher
# so don't exclude them - assume due to natural variation

# have a smallish sample size so will be some variability
# should be cautious w inferences
# not use exact nums for prediction

# report:
# sample size and thus statistical power is a bit on the low side,
# and thus the estimates should be considered with caution, although, 
# on the whole, they are ok
# still can interpret these results as good enough to conclude that both
# glizz and horn length are positively associated with body mass
# and report association between horn length and glitz
# provide plot with glitz as coloured dots and the regression line from the reduced model (not the more beuatiful plotting one!)

plot(u1$Hornlength[u1$Glizz==0],u1$Bodymass[u1$Glizz==0], pch=19, 
     xlab="Horn length", ylab="Body mass", xlim=c(3,8), ylim=c(6,15))
points(u1$Hornlength[u1$Glizz==1],u1$Bodymass[u1$Glizz==1], pch=19, col="red")
abline(ReducedModel)

# would have legend
# and where regression line comes from - from model we'd present in table

# in discussion outline that glitz introduces quite a bit of variation - 
# probably representing this as presence/absence not great - might be a continuous trait
# might be useful to estimate mass of glitz/measure it in another ocntinuous way
# etc


## Interpretation of interactions ----
# 2-level fixed factor and a continuous variable

rm(list=ls())
dat<-read.table("../data/data.txt", header=TRUE)

# fictional data - spp richness of arthropods in grasslands
# some grasslands v high diversity, some v low
# half sampled grasslands farmed w conventional measures, other half "organic"
# question: determine effect of fertilizer on spp richness
# hypothesis: increasing amounts of fertilizer lead to lower spp diversity 
# varying amounts of fertilizer have been applied to both types of grasslands

head(dat)
str(dat)

# know organic grassland likely has more spp - add as fixed factor to model

# also, assume amount of fertilizer affects conventional grassland vs organic differently
# specifically, we expect that fertilizers might affect organic grassland less 
# (at least in the first year, which is what is measured here) than 
# conventional ones. *I just made this up* 
# therefore, add an interaction to the model

fullmodel <- lm(species_richness ~ fertilizer * method, data=dat)
summary(fullmodel)

# interaction v stat sig
# what does it mean?

## SEE day1_HO1 in course_material - (p21) - (rather than typing it all out again)

# method recoded as 0/1 - think about equation - plug in ests

plot(dat$species_richness[dat$method=="conventional"] ~ dat$fertilizer[dat$method=="conventional"],
     pch=16, xlim=c(0,50),ylim=c(0,70), col="grey", 
     ylab="Species richness", xlab="Fertilizer(units)")
points(dat$fertilizer[dat$method=="organic"], dat$species_richness[dat$method=="organic"], 
       pch=16, col="black")

# interactions are tricky!! - DO LOOK at interpretation in HO1
# easier if write out equation and try plugging in!
# and keep error size in mind
plot(fullmodel) # check plots - fine


## Interpretation of interactions - 3-level fixed factor w continuous variable

rm(list=ls())
d<-read.table("../data/Three-way-Unicorn.txt", header=TRUE)
str(d)
# want to explore whether relationship between horn length and 
# body mass is different between genders

# hypothesis: only unicorns that are fat can grow long horns
# (horn length now response and body mass explanatory)
# and know there are some sex-specific effects - add as a 3-level factor

mean(d$Bodymass)
sd(d$Bodymass)
var(d$Bodymass)
par(mfrow=c(1,2))
hist(d$Bodymass, main="")

mean(d$HornLength)
sd(d$HornLength)
var(d$HornLength)
hist(d$HornLength, main="")

par(mfrow=c(1,1))
plot(d$HornLength[d$Gender=="male"] ~ d$Bodymass[d$Gender=="male"], 
     xlim=c(70,100),ylim=c(0,18), pch=19,
     xlab="Bodymass (kg)", ylab="Hornlength (cm)")
points(d$Bodymass[d$Gender=="female"], d$HornLength[d$Gender=="female"], 
       col="red", pch=19)
points(d$Bodymass[d$Gender=="not_sure"], d$HornLength[d$Gender=="not_sure"], 
       col="green", pch=19)

# looks like might have diff means
# and a diff slope in males than in females&undecided

mod <- lm(HornLength ~ Gender * Bodymass, data=d)
summary(mod)

# interaction between male and body mass sig -> slope for this vs females is stat sig diff from 0
# ie the slopes are different from each other

# females:
# horn length =  -42.31 + 0.63*Bodymass
# since body mass ranges between 70-100 - makes sense
# clearly female slope is positive - expected
# increase of 1kg - horn length increases by 0.63cm

# males: 
# horn length = -42.31 + 114.50 + 0.63*Bodymass - 1.32*Bodymass
#             = 72.19 + (0.63 - 1.32)*Bodymass
#             = 72.19 - 0.69*Bodymass
# so negative slope - also expected 
# the SE of interaction (0.12) and even twice this (0.24) is much smaller than 
# the slope - so clearly slope is stat sig diff from 0 - and negative
# increase of 1kg - horn length decreases by 0.69cm

# IMPORTANT RULE
# do not interpret a main effect in the presence of an interaction!!!
# but use this rule sensibly
# eg here, for females we did interpret the main effect (bodymass) - use brain!

# undecided unicorns:
# horn length = -42.31 + 12.81 + 0.63*Bodymass - 0.18*Bodymass
#             = -29.5 + 0.45*Bodymass
# makes sense too - positive slope - not stat sig diff from the female slope
# (reason for this: if take diff of both slopes (0.63-0.45=0.18) this less than twice SE (0.2))
# but this slope is stat sig diff from 0 (0.45 much bigger than twice SE 0.2)
