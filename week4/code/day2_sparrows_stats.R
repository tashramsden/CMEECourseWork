## SwS 6a - Error and statistical power ----

 # key thing w CI is whether it encompasses 0 - if it does - not stat sig

# even if something sig different, is it relevant? eg males sig bigger than
# females, but by 0.1mm - does this matter?

## Primary vs secondary stats
# the effect size - primary statistic - biologically meaningful,
# eg Cohen's d for differences
# secondary stats (eg t, F, p) - these to back up primary stat - is it sig etc

# MAKE SURE to include primary stats - eg if found stat sig between 2 means
# - SAY WHAT THE MEANS ARE
# BIOLOGY should be centre stage! (stats to back up)

# sample sizes - what size do I need - conduct a power analysis
# take effect size, alpha (limit to p-value, typically 0.05), power (and then calculate N)
# do power analysis before planning project!!!


## SwS 6b - Degrees of freedom ----

## describing data
# 1 data point - no estimate of mean - data = mean
# 2 points - estimate of mean is one data point - one less point than the data
# 3 data points - the mean estimate is 2 fewer than 3 -> df = 2
# etc!

## describing differences between 2 groups
# 2 data points - delta (diff) is calculable - no error -df =0
# 4 points - estimate 2 means (and find diff of these) - 4-4=2 df
# 6 points - 2 means - 6-2=4df

## describing relationships
# 1 point - no relationship
# 2 points - can describe relationship - no error - it's a line
# 3 - can describe line w estimate of slope and intercept - 3-2=1df
# 6 - eg if one line to describe - 6-2=4df
#   - if describing w 2 lines - 4 estimates (2slope, 2intercept) 6-4=2df

# quantifies how many parameters you can estimate from the data
# always fewer than the sample size (cannot estaimte more than the data)
# must be at least 1 left over
# df = N - #parameters estimated

# parameters = primary stat
# one sample ttest - 1 mean, 
# 2 sample ttest - 2 means
# correlation - 1 cor coef
# linear model w 1 continuous predictor: 2-1 intercept and 1 slope
# etc!!!

#### Hand-out work

## Power analysis
rm(list=ls())
require(WebPower)
?WebPower

# diff between male and female horns 30cm (females longer) from 5 dragons, st dev 1.2

# Cohen's d = diff between 2 means divided by st dev (gives ratio of effect size to st dev)
0.3/1.2
# so d is 0.25 (effect size)
# means we want to detect an effect size that is 1/4 of st dev
# visualise in st dev density plot (w mean 1, st dev 1.3, horns cannot be shorter than 0 so cut off)

y<-rnorm(51, mean=1, sd=1.3)
x<-seq(from=0, to=5, by=0.1)
length(x)
plot(hist(y, breaks=10))

mean(y)
sd(y)

segments(x0=(mean(y)), y0=(0), x1=(mean(y)), y1=40, lty=1, col="blue")
# and now 0.25 sd left of the mean (because females are larger)
segments(x0=(mean(y)+0.25*sd(y)), y0=(0), x1=(mean(y)+0.25*sd(y)), y1=40, lty
         =1, col="red")

# becomes obvious that it's a quite small effect size given the variability of data

# do we need larger sample size?

?wp.t

# need 2 sample sizes (what we want to work out) -assume the same (easiest)
# effect size is 0.25, alpha is 0.05, 
# power - want stat power to be .080 or higher (convention) ~ 20% chance of false negative
# type = go w two sample as we have 2 samples male and female (not comparing one sample to fixed mean)

wp.t(d=0.25, power=0.8, type="two.sample", alternative="two.sided")
# results says would need to sample 252 dragons in each group to get a clear answer
# if sample <504 individuals, unlikely to get satisfactory answer

# can produce power curve - demonstrate effect of sample size on power
res.1<-wp.t(n1=seq(20,300,20), n2=seq(20,300,20), d=0.25, 
            type="two.sample.2n", alternative="two.sided")
res.1
plot(res.1, xvar="n1", yvar="power")  # NOTE: n1 is ONE group

# only hope for getting away w smaller sample size is if st dev is smaller 
# than 1.2, or if effect size is actually larger than 0.3m 
# but cannot know this without more sampling - and to be stat sure - 
# need to sample > 500!!

## exercise

# growth of 2 groups of bacterial colonies
# n each group = 300
# effect size = 0.11
# p = 0.044
# want to work out power of this analysis
wp.t(n1=300, n2=300, d=0.11, alpha=0.044, type="two.sample")
# power = 0.25 (not v powerful...)


## SwS 7 - Linear Algebra ----

rm(list=ls())
x<-seq(from = -5, to = 5, by = 1)
x
x[[1]]
x[[2]]
x[[9]]
x[[length(x)]]
i<-1
x[[i]]
i<- seq(0,10,1)
i
x[[i[[2]]]]

# want line y = x + 2
a<-2
b<-1
y<-a+b*x
plot(x,y)
# add cartesian axes
segments(0,-10,0,10, lty=3)
segments(-10,0,10,0,lty=3)
# want line not just points
?abline
plot(x,y, col="white")  # plotted dots in white so not seen..!
segments(0,-10,0,10, lty=3)
segments(-10,0,10,0,lty=3)
abline(a = 2, b=1)
# can add points to plots...
points(4,0, col="red", pch=19)
points(-2,6, col="green", pch=9)
points(x,y, pch=c(1,2,3,4,5,6,7,8,9,10,11))

# plot quadratic
y<-x^2
plot(x,y)
segments(0,-30,0,30, lty=3)
segments(-30,0,30,0,lty=3)

x<-seq(from = -5, to = 5, by = 0.1)
a<- -2
y<-a+x^2
plot(x,y)
segments(0,-30,0,30, lty=3)
segments(-30,0,30,0,lty=3)

# give a slope, b
plot(x,y)
a<- -2
b<-3
y<-a+b*x^2
points(x,y, pch=19, col="red")
segments(0,-30,0,30, lty=3)
segments(-30,0,30,0,lty=3)

# add non-quadratic effect - moves whole curve
plot(x,y)
a<- -2
b1<- 10
b2<-3
y<-a+b1*x+b2*x^2
points(x,y, pch=19, col="green")
segments(0,-100,0,100, lty=3)
segments(-100,0,100,0,lty=3)


# quiz q3
x<-seq(from = -5, to = 10, by = 1)
y <- -1+2*x-0.15*x^2
plot(x,y)
points(x,y, pch=19, col="green")
segments(0,-100,0,100, lty=3)
segments(-100,0,100,0,lty=3)

segments(x0=-5, x1=10, y0=5, y1=5, col="blue")
segments(x0=-5, x1=10, y0=5.65, y1=5.65, col="red")

segments(x0=7, x1=7, y0=-15, y1=8, col="blue")
segments(x0=7.5, x1=7.5, y0=-15, y1=8, col="red")


# quiz q4
x<-seq(from = -5, to = 20, by = 1)
y <- -1+2*x-0.08*x^2
plot(x,y)
points(x,y, pch=19, col="blue")
segments(0,-100,0,100, lty=3)
segments(-100,0,100,0,lty=3)
segments(x0=12, x1=12, y0=-15, y1=15, col="red")


## SwS 8 - Linear models ----

# only fit complex model if hypothesis is specific - best to fit most minimal
# model that answers the question

# y = b0 + b1*xi + ei   ( e is actually epsilon)

# y = response variable, i is an index
# x is explanatory, w equivalent i (same as y - linked measurements)
# epsilon - don't know this until model solved (also has index - epsilon for each x and y)
# b0 and b1: b0 intercept, b1 slope (only one number vs x and y - vectors)
# aim to estimate b0 and b1

# plot - guestimate line - rough estmimate of b0 and b1
# epsilon is distance from line to each data point

# compare w straight flat line and compare epsilon using this line vs the guess line
# square all these resiuduals and sum them (for actaul line and flat line)
# estimate the goodness of fit

# model fitting - finds line that is best positioned to minnimise
# the sum of squared residuals

## linear regression
# minimises sum of squared residuals of line
# gets b0 and b1 for this 


## Hand-out work

rm(list=ls())
x<-c(1,2,3,4,8)
y<-c(4,3,5,7,9)
x
mean(x)
var(x)
y
mean(y)
var(y)

?lm
model1 <- (lm(y~x))
model1
summary(model1)
coefficients(model1)
resid(model1)
mean(resid(model1))
var(resid(model1))
length(resid(model1))

summary(model1)
plot(y~x, pch=19)

plot(y~x, pch=19, xlim=c(0,8.5), ylim=c(0,9.5))
segments(0,-30,0,30, lty=3)
segments(-30,0,30,0,lty=3)
coefficients(model1)
abline(2.62, 0.83)


# bigger dataset
# create x var from -10 to 10
# random slope, -0.2, choose intercept 7.1
x<-seq(from=-10, to=10, by=0.2)
x
y <- 7.1-0.2*x
y
# now run model, expect slope to be -0.1, intercept 7.1
summary(lm(y~x))
# estimates excellent, get odd warning message: fit essentially perfect
plot(y~x)
# the data is too perfect! - there is no uncertainty: se v small and residuals too

# simulate some uncertainty
y<- 7.1-0.2 * x + runif(length(x))
summary(lm(y~x))
plot(y~x)


## SwS 9a - Linear models - practice ----

## SwS 9b - Linear models - interpreting and reporting ----

# why standardize data?

# 1. make the intercept more biologically meaningful
# eg z-standardize tarsus vs body mass
# normal tarsus vs body mass - slope is positive - bigger tarsus - heavier bird
# but intercept not very meaningful, <10g does a bird w no tarsus weigh <10g...no
# data points all clustered around >15mm tarsus and ~30g mass

# for z-standardized data - the data now has mean of 0 (all points clustered around y axis)
# slope still shows same relationship (but now for every increase in st dev of tarsus length, increase in mass (rather than increase in mm -> g))
# but now the intercept is the mean mass - more biologically meaningful

# 2. better for comparing data
# can compare sparrows, ostriches, etc!!
# analysis not only relevant to sparrows any more, has some context - much better for a paper!

# 3. units
# if data standardized -> generally applicable, not so dependent on units

# take home:
# always consider units - and think of biological meaning
# standardize to make intercepts meaningful


# reporting

# methods
# repeat hypothesis: to test "x", I used linear model, say response and 
# explanatory vars and why
# say if standardized - and why!
# talk about how assumptions checked eg visual inspection of residual plots...etc
# what was value of significance p and used R etc

# results
# use descriptive data first - ease in! -what does data consist of?
# stats results - effect and stats - w bio meaning
# emphasis on primary stats


## Hand-out work
rm(list=ls())
d<-read.table("../data/SparrowSize.txt", header=TRUE)

plot(d$Mass~d$Tarsus, ylab="Mass (g)", xlab="Tarsus (mm)", pch=19, cex=0.4)

x<-c(1:100)
a<-0.5
b<-1.5
y<-b*x+a
plot(x,y, xlim=c(0,100), ylim=c(0,100), pch=19, cex=0.5)

# yi = b0 + b1*xi + epsiloni

# y1 etc
d$Mass[1]

# yn (last)
length(d$Mass)
d$Mass[1770]


plot(d$Mass~d$Tarsus, ylab="Mass (g)", xlab="Tarsus (mm)", pch=19, cex=0.4,
     ylim=c(-5,38), xlim=c(0,22))

# estimate b0 and b1 (slope and intercept)
# easier on zoomed in plot
plot(d$Mass~d$Tarsus, ylab="Mass (g)", xlab="Tarsus (mm)", pch=19, cex=0.4)

# approx: intercept somewhere bwteen -5, 10 and 
# slope - maybe ~10g diff for 5mm so 10/5 = 2

# equation ish
# yi = 5 + 1.6xi + epsiloni

# epsilon
# not only want to quantify the direction and steepness of association but also 
# the spread - error - noise around line
# one error term (residual) for each observation - how far point is from line (squared)
# want to minimise residuals
# method - least square 

d1<-subset(d, d$Mass!="NA")
d2<-subset(d1, d1$Tarsus!="NA")
length(d2$Tarsus)
model1<-lm(Mass~Tarsus, data=d2)
summary(model1)

# see residuals
hist(model1$residuals)
head(model1$residuals)

# slope is more like 1.2 

# df = 1642 (1644 obs) - 2 estimates - slope and intercept

# R^2 - means 23% var in mass explained by var in tarsus
# if 100% would mean no deviation from the line, eg
model2<-lm(y~x)
summary(model2)

# z transformation
d2$z.Tarsus<-scale(d2$Tarsus)
model3<-lm(Mass~z.Tarsus, data=d2)
summary(model3)
# now the intercept reflects the mean mass
plot(d2$Mass~d2$z.Tarsus, pch=19, cex=0.4)
abline(v = 0, lty = "dotted")

head(d)
str(d)
d$Sex<-as.numeric(d$Sex)
plot(d$Wing ~ d$Sex, xlab="Sex", xlim=c(-0.1,1.1), ylab="")
abline(lm(d$Wing ~ d$Sex), lwd = 2)
text(0.15, 76, "intercept")
text(0.9, 77.5, "slope", col = "red") 

# ttest (tests for stat sig diff from 0 diff between 2 means) can be used 
# to test linear models
d4<-subset(d, d$Wing!="NA")
m4<-lm(Wing~Sex, data=d4)
t4<-t.test(d4$Wing~d4$Sex, var.equal=TRUE)
summary(m4)
t4

# test assumptions - residuals are normally distributed
par(mfrow=c(2,2))
plot(model3)
# first plot - want residuals to be roughly randomly - stars in the sky -
# don't want to see a trend
# second - Q-Q plot - standardised residuals plotted against the quantiles
# they should fall into (assuming they are normally distributed) - should 
# be straight line - this one is ok

# compare w model 4
par(mfrow=c(2,2))
plot(m4)

# third plot - shows residuals in relationship to their leverage (how important
# some points are in relationship to others)


