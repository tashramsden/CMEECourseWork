#### Stats w sparrows ----
#### 25/10/21

rm(list=ls())

require(dplyr)
require(ggplot2)

setwd("../../week4/code")

## SwS 01 ----

d <- read.table("../data/SparrowSize.txt", header=TRUE)
str(d)
head(d)
summary(d)

table(d$Year)  # from 2000 to 2010

length(d$Tarsus)
mean(d$Tarsus, na.rm=T)

# mean from a smaller sample
subset <- sample_n(d, 4)
mean(subset$Tarsus)

## Demonstrate how sample size affects mean
x <- 0:length(d$Tarsus)
x
y <- mean(d$Tarsus, na.rm=T) + 0*x
y
plot(x, y, col="red", cex=0.3, xlab = "Sample size", ylab = "Mean of Tarsus",
     ylim=c(18, 19.3))
for (n in 1:length(d$Tarsus)) {
    new_subset <- sample_n(d, n)
    points(n, mean(new_subset$Tarsus, na.rm=T), cex=0.3)
}


## same but for var
y <- var(d$Tarsus, na.rm=T) + 0*x
y
plot(x, y, col="red", cex=0.3, xlab = "Sample size", ylab = "Var of Tarsus",
     ylim=c(0, 1.5))
for (n in 1:length(d$Tarsus)) {
    new_subset <- sample_n(d, n)
    points(n, var(new_subset$Tarsus, na.rm=T), cex=0.3)
}


table(d$BirdID)  # want to summarise this:
table(table(d$BirdID))  # 2 birds have been caught 12 times!
# could also do this w dplyr
BirdIDCount <- d %>% count(BirdID, BirdID, sort=TRUE)
BirdIDCount %>% count(n)

# repeats per bird per year
birds_per_year <- d %>% group_by(Year) %>% count(BirdID) 
head(Repeats)
tail(Repeats)

plot(birds_per_year$n ~ as.factor(birds_per_year$Year), col=birds_per_year$BirdID)

ggplot(birds_per_year, aes(x = Year, fill = BirdID)) +
    geom_bar()

# individuals per year for each sex
sex_per_year <- d %>% group_by(Year) %>% count(Sex.1)
head(sex_per_year)

ggplot(sex_per_year, aes(x = Year, y = n, col = Sex.1)) +
    geom_line()


## SwS 02 - Centrality and Spread ----

## Measures of centrality = mean, median, mode

names(d)

hist(d$Tarsus)  # looks roughly normally distributed

mean(d$Tarsus, na.rm = T)
median(d$Tarsus, na.rm = T)
mode(d$Tarsus)  # mode returned description of the object - here numeric
# mode is most freq occuring value - difficult for numeric values

par(mfrow = c(2,2))
hist(d$Tarsus, breaks=3, col="grey")
hist(d$Tarsus, breaks=10, col="grey")
hist(d$Tarsus, breaks=30, col="grey")
hist(d$Tarsus, breaks=100, col="grey")

# mode must be somewhere between 18 and 19
# no package to calculate more precisely, do it ourselves:
# first, count how often each value occurs
head(table(d$Tarsus))
# some values measured eg 7 times, some only once

# reasonable to round the tarsus values first, too precise!
# round to 1dp
d$Tarsus.rounded <- round(d$Tarsus, digits=1)
head(d$Tarsus.rounded)
# now find whihc is highest
TarsusTally <- d %>% 
    count(Tarsus.rounded, sort=T)
TarsusTally
# this works ish
# the top number is the mode - 19.0
# but also a row for NAs - in some datasets that might show 
# up the most (but not the mode!!) - need to remove
d2 <- subset(d, d$Tarsus!="NA")
length(d$Tarsus) - length(d2$Tarsus)  # same as num of NAs in Tally - correct

TarsusTally <- d2 %>% 
    count(Tarsus.rounded, sort=T)
TarsusTally

TarsusTally[[1]][1]  # this is the first value = mode

## summary stats:
mean(d$Tarsus, na.rm = T)
median(d$Tarsus, na.rm = T)
TarsusTally[[1]][1]  # mode

# in normally dist data mean, median, mode should be similar
# (if perfectly normal, they should be identical)
# as skew of distribution increases, these 3 measures diverge


## Measures of spread = range, variance and standard deviation

range(d$Tarsus, na.rm = T)
range(d2$Tarsus, na.rm = T)

var(d$Tarsus, na.rm = T)
var(d2$Tarsus, na.rm = T)

# calculate variance = sum of squares (SS) over n-1
sum((d2$Tarsus - mean(d2$Tarsus))^2) / (length(d2$Tarsus) - 1)

# st dev is square root of var
sqrt(var(d2$Tarsus))
sd(d2$Tarsus)


## z scores and quantiles

# z-scores come form standardized normal dists w mean 0 and st dev 1
# if st dev 1, var also 1 -> st dev = var

# in stats, often useful to transform data to follow this rule = z transforming
# do this by dividing the deviation from the mean by the st dev
# z = (y - ymean)/sigmay
# sigmay is st ded of y

zTarsus <- (d2$Tarsus - mean(d2$Tarsus)) / sd(d2$Tarsus)
var(zTarsus)
sd(zTarsus)

par(mfrow = c(1,1))
hist(zTarsus)

# normal dist = z dist

# make data set that follows this dist
znormal <- rnorm(1e+06)
hist(znormal, breaks = 100)
summary(znormal)

# qnorm - gets value of given quantile
qnorm(c(0.025, 0.975))
# pnorm - probability at a given value
pnorm(.Last.value)

par(mfrow=c(1,2))
hist(znormal, breaks = 100)
abline(v = qnorm(c(0.25, 0.5, 0.75)), lwd = 2)
abline(v = qnorm(c(0.025, 0.975)), lwd = 2, lty = "dashed")
plot(density(znormal))
abline(v = qnorm(c(0.25, 0.5, 0.75)), col = "gray")
abline(v = qnorm(c(0.025, 0.975)), lty = "dotted", col = "black")
abline(h = 0, lwd = 3, col = "blue")
text(2, 0.3, "1.96", col = "red", adj = 0)
text(-2, 0.3, "-1.96", col = "red", adj = 1)

# 95% confidence interval (CI) - range of values that encompass the
# pops true value w 95% probability
# (will make an error 5% of the time)
# here it means that the true mean of the pop that was sampled lies
# within the CI interval 95 times out of 100 sampling events

# for the sparrows
par(mfrow=c(1,1))
boxplot(d$Tarsus ~ d$Sex.1, col = c("red", "blue"), ylab="Tarsus length (mm)")

# mean vs median vs mode
# median might be better for v skewed data/w big outliers / for categorical data

# more precise variable - more smaller bins on hist


#### SwS 03 - Data types ----

str(d)

# BirdID is numerical but it is a category
d$BirdIDFact <- as.factor(d$BirdID)
str(d$BirdIDFact)

mean(d$BirdID)  # this is biologically meaningless - but R doesn't know this!
# mean(d$BirdIDFact)  # no longer numeric so error - good! There's no such 
# thing as average BirdID

# Year - tricky variable - maybe every year is independent -> categorical
# plot year as factor
plot(d$Mass ~ as.factor(d$Year), xlab="Year", ylab="House sparrow body mass (g)")
# if don't tell R that Year is categorical
plot(d$Mass ~ d$Year, xlab="Year", ylab="House sparrow body mass(g)")
# looks v different

# when to use years as each type of variable, e.g. when thinking
# about global warming:
# blue tits rely on caterpillars to feed young, these emerge w tree burst,
# happening earlier every year - strong selection on early laying dates
# blue tit data:
rm(list=ls())
b<-read.table("../data/BTLD.txt", header=T)
str(b)
# LD.in_AprilDays is laying date from 1st Apr onward, 3 = 3rd apr, 32 = 1st May
# int but is a continuous variable (later egg laying = worse for 
# chicks - the scale of numbers has meaning)
# ClutchsizeAge7 - num offspring in clutch seven days after hatching - also continuous
mean(b$ClutchsizeAge7, na.rm = TRUE)
# IDFemale (no males -don't lay eggs!) - letter+nums - wants to be categorical
b$IDFemale <- as.factor(b$IDFemale)
# Year - we want this to be numerical 
plot(b$LD.in_AprilDays. ~ b$Year, ylab="Laying date (April days)", xlab="Year",
     pch=19, cex=0.3)
# add jitter to see better:
plot(b$LD.in_AprilDays. ~ jitter(b$Year), ylab="Laying date (April days)",
     xlab="Year", pch=19, cex=0.3)
# need to mention this in legend (the jitter is NOT biologically meaningful
# - just random noise!!!)

# violin plot
require(ggplot2)
p <- ggplot(b, aes(x=Year, y=LD.in_AprilDays.)) +
    geom_violin()
p
# no!! R interpreted Year as continuous
# which is what we want....!!!
# want to INTERPRET year as continuous - BUT VISUALISE as categorical!!!
boxplot(b$LD.in_AprilDays. ~ b$Year, ylab="Laying date (April days)",
        xlab="Year")
p <- ggplot(b, aes(x=as.factor(Year), y=LD.in_AprilDays.)) +
    geom_violin()
p
# add some descriptive stats
p + stat_summary(fun.data="mean_sdl", geom="pointrange")


#### SwS 4 - Precision and Standard error

# St dev describes spread and variability of a distribution
# descriptive of data
# report: mean, st dev

# St error describes the precision of the data - 
# how precise (how likely correct) the MEAN that is calculated from a sample is
# dependent on variance 
# quantifies the precision of an estimate
# descriptive of mean (or any mean-type estimate)
# report mean +- SE
# st error depends on st dev and sample size, SE = sqrt(var/n)

rm(list=ls())

d <- read.table("../data/SparrowSize.txt", header=TRUE)
str(d)

summary(d$Tarsus)
mean(d$Tarsus, na.rm = T)
var(d$Tarsus, na.rm = T)

sd(d$Tarsus, na.rm = T)
sqrt(var(d$Tarsus, na.rm = T))

ster <- sqrt(var(d$Tarsus, na.rm = T) / (length(d$Tarsus)-85))
d1 <- subset(d, d$Tarsus!="NA")
length(d$Tarsus)
length(d1$Tarsus)

x <- 1:length(d1$Tarsus)
y <- mean(d1$Tarsus) + 0*x

nn <- c(2, 5, 10, 20, 30, 40,50,60,70,80,90,100,150,200,250,300,350,400,450,500)

plot(x, y, col="red", cex=0.1, xlab = "Sample size", ylab = "Mean of Tarsus",
     ylim=c(18, 19), xlim=c(0,500))

for (n in 1:length(nn)) {
    sub <- sample_n(d1, nn[n])
    points(nn[n], mean(sub$Tarsus), pch=19, cex=0.5)
    arrows(x0=nn[n], y0=mean(sub$Tarsus) - sqrt(var(sub$Tarsus) / (length(sub$Tarsus))),
           x1=nn[n], y1=mean(sub$Tarsus) + sqrt(var(sub$Tarsus) / (length(sub$Tarsus))),
           code=3, angle=90, length=0.1)
}
# with small sample size - mean all over the place and large variance
# more precise w more observations in sample

# to double precision, would need to increase sample size by 4

## 95% confidence interval (CI)
# encompasses the pop "true" value
# 95CI = +-1.96 se
# guesstimate 95CI ~ 2se

## Handout
rm(list=ls())
d<-read.table("../data/SparrowSize.txt", header=TRUE)
d1<-subset(d, d$Tarsus!="NA")

# st err
seTarsus<-sqrt(var(d1$Tarsus)/length(d1$Tarsus))
seTarsus

# st err for only 2001:
d12001<-subset(d1, d1$Year==2001)
seTarsus2001<-sqrt(var(d12001$Tarsus)/length(d12001$Tarsus))
seTarsus2001
# st err much bigger (5x)

# visualising change in precision
rm(list=ls())

# dragon tail lengths (m)
TailLength <- rnorm(500, mean=3.8, sd=2)
summary(TailLength)
length(TailLength)
var(TailLength)
sd(TailLength)
hist(TailLength)

# Now	to	the	real	exercise.	I	want	to	randomly	draw	a	specified	number	of	observations	from	
# this	dataset,	and	calculate	the	mean,	and	standard	error,	and	plot	it.	I	actually	want	to	do	
# that	for	sample	sizes	from	one,	all	the	way	up	to	400.	To	do	that	I	have	multiple	options.	I	
# chose	here	a	classical,	traditional,	for loop,	and	plot	the	points	while	I’m	looping.	I	first	
# prepare	the	canvas	of	the	plot.	To	do	that,	I	need	to	know	the	maximum	and	minimum	
# values	that	need	to	be	displayed.	Obviously,	the	x-axis	will	run	to	400.	The	y-axis	will	run	
# from	the	minimum	to	the	maximum	mean,	and	I	will	give	it	some	space	for	the	standard	
# error	bars.	I	want	to	plot	the	grand	total	mean	- as	a	black	line	so	I	can	compare	the	other	
# means	to	it.	To	do	that	I	need	to	create	a	dataset	with	a	vector	for	x	that	runs	from 1	to	400,	
# and	a	y	vector	that	holds	500	times	the	grand	total	mean.	I	can	create	y	in	many	ways,	but	
# by	multiplying	it	with	x	I	make	sure	they	are	both	of	the	same	length.

x<-1:length(TailLength)
y<-mean(TailLength)+0*x
min(TailLength)
max(TailLength)
plot(x,y, cex=0.03, ylim=c(2,5),xlim=c(0,500), xlab="Sample size n", 
     ylab="Mean of tail length ±SE (m)", col="red")

# need	to	populate	my	graph	with	means	of	samples	of	this	data.	To	do	this,	I	run	the	for
# loop.	But	before	I	do	that	I	make	vectors	for	the	means	(mu)	and	the	standard	errors	(SE):

SE<-c(1)
SE
mu<-c(1)
mu

for (n in 1:length(TailLength)) {
    d<-sample(TailLength, n, replace=FALSE)
    mu[n]<-mean(TailLength)
    SE[n]<-sd(TailLength)/sqrt(n)
}

head(SE)
head(mu)
length(SE)
length(mu)

# plot
up<-mu+SE
down<-mu-SE
x<-1:length(SE)
segments(x, up, x1=x, y1=down, lty=1)

# make look nicer -500 too long, 200 will do
rm(list=ls())
TailLength<-rnorm(201,mean=3.8, sd=2)
length(TailLength)
## [1] 201
x<-1:201
y<-mean(TailLength)+0*x
plot(x,y, cex=0.03, ylim=c(3,4.5),xlim=c(0,201), xlab="Sample size n", ylab="
Mean of tail length ±SE (m)", col="red")
n<-seq(from=1, to=201, by=10)
n
SE<-c(1)
mu<-c(1)
for (i in 1:length(n)) {
    d<-sample(TailLength, n[i], replace=FALSE)
    mu[i]<-mean(TailLength)
    SE[i]<-sd(TailLength)/sqrt(n[i])
}
up<-mu+SE
down<-mu-SE
length(up)
length(n)
plot(x,y, cex=0.03, ylim=c(3,4.5),xlim=c(0,201), xlab="Sample size n", ylab="
Mean of tail length ±SE (m)", col="red")
points(n,mu,cex=0.3, col="red")
segments(n, up, x1=n, y1=down, lty=1)
# clear how st error shrinks w sample size!!!


# 1. calculate st err for tarsus, mass, wing and bill length
# 2. do above but with subset of only 2001
# 3. and calculate CI

rm(list=ls())
d<-read.table("../data/SparrowSize.txt", header=TRUE)

# Tarsus
d1<-subset(d, d$Tarsus!="NA")
d12001 <- subset(d1, d1$Year==2001)
seTarsus<-sqrt(var(d1$Tarsus)/length(d1$Tarsus))
seTarsus
seTarsus2001<-sqrt(var(d12001$Tarsus)/length(d12001$Tarsus))
seTarsus2001
CITarsus <- 1.96 * seTarsus
CITarsus

# Mass
d2<-subset(d, d$Mass!="NA")
d22001 <- subset(d2, d2$Year==2001)
seMass<-sqrt(var(d2$Mass)/length(d1$Mass))
seMass
seMass2001<-sqrt(var(d22001$Mass)/length(d22001$Mass))
seMass2001
CIMass <- 1.96 * seMass
CIMass

# etc!!!!!
# (no bill measurements in 2001)


#### SwS 5 - Comparing means ----

# If sampled sparrow on Lundy in just one year and take mean -
# is this representative of overall mean

# actual (grand total) mean = mu
# xi values of subset, xi' is their mean

# mu = 18.52
# 2001
# N = 95
# mean +- se = 18.08 +- 0.1
# 95CI (mean +- 2*se) = 17.88-18.29

# grand total mean is NOT within CI of 2001 mean
# 2001 mean sig. lower than grand total

# t-test, gets CI AND quantifies p

# t(meanx1) = (meanx1 - mu) / se(meanx1)

# scenario 1: N is small
# -> se will be large-ish
# t = 0ish / largeish = smallish!

# scenario 2: N large
# se small
# t = 0ish / smallish = largeish

# if t large -- over on right of plot of tvalues vs p values
# large t = small p value

# used to be table of critical t values!
# depends on d.f. = N - #estimates

# p < 0.05 stat sig (not real reason - convention)

# hypothesis 
# sexual selection leads to larger males than females
# prediction
# sparrow males larger than females
# test
# male tarsus != female tarsus
# stat test
# male tarsus - female tarsus != 0 (difference not equal to 0)

# H0 = diff between male and fem tarsus = 0
# H1 = not 0

rm(list=ls())
d<-read.table("../data/SparrowSize.txt", header=TRUE)

t.test(d$Tarsus ~ d$Sex.1)
# are sig different
# 95CI does NOT contain 0
# female tarsus sig smaller

# if had 2 columns eg malestarsus in one femtarsus in another:
# t.test(FemaleTarsus, MaleTarsus)
#### V IMPORTANT to use these the right way round - don't use ~ or , in wrong situation

# report results:
# eg
# IF NOT sig diff
# male and female tarsi did not differ in size between male and females 
# (mean: 18.18, two sample t-test: t=1.23, df=139, p=0.22)
### JUST report one mean (they're no different!)

# Handout work

rm(list=ls())
d<-read.table("../data/SparrowSize.txt", header=TRUE)

# test for difference in female and male body mass 
boxplot(d$Mass ~ d$Sex.1, col = c("red", "blue"), ylab="Body mass (g)")

t.test1 <- t.test(d$Mass ~ d$Sex.1)
t.test1
# v high probability that males heavier than females

# Yes,	but	wait,	does	it	actually	make	biological	sense?	The	p-value	is	super	small, most	
# people	would	be	very	excited. But	I	want	to	teach	you	to	not focus	too	much	on	the	pvalues,	instead	look	at	95%CIs and	the	parameter	estimates.	The	male	mean	is	28.0g and
# the	female	mean	is	27.5g. The	difference	is	about	half	a	gram.	However,	that’s	the	mean	
# difference.	But	can	we	say	something	about	the	precision	of	this	effect?	Look	at	the	output,	
# it	gives us	a	95%CI	of	the	difference	between	males	and	females: 95%	of	the	differences	
# between	males	and	females	fall	between	-0.77g	and	-0.37g	(males	heavier).	This	gives	us	a	
# good	indication	about	how	important	this	difference	is	in	biology.
# 5%	of	the	times,	however,	the	difference	will	be	outside	of	this	interval.	That’s	a	type	1	
# error.	There	is	a	5%	chance	that	this	data	is	actually	not	representing	the	real	world,	and	
# that	the	difference	between	the	sexes	is	actually	0.
# Large	datasets	are	more	likely	to	pick	up	on	small	effect	sizes	(remember	the	square	root law).	

# Let’s	see	if	we	would	reduce	our	dataset	to	the	50	first	rows,
# could	we	still detect a difference	between	male	and	female	body	mass?
d1<-as.data.frame(head(d, 50))
length(d1$Mass)

t.test2 <- t.test(d1$Mass ~ d1$Sex.1)
t.test2
# now there is no difference
# The	lesson	here	is	that	with	large	datasets,	you	are	more	likely	to	encounter	a	statistically	
# significant	effect,	but	whether	or	not	this	effect	is	actually	meaningful,	is	not	something	you	
# can	understand	by	looking	at	the	p-value.	In	the	first	t.test,	the	p-value	was	very	significant,	
# however	the	real difference	(effect	size)	was	very small (0.3g	more	or	less	is	not	a	lot,	i

d<-read.table("../data/SparrowSize.txt", header=TRUE)

d1<-subset(d, d$Mass!="NA")
d12001 <- subset(d1, d1$Year==2001)
t.test(d1$Mass, d12001$Mass)

d1<-subset(d, d$Wing!="NA")
d12001 <- subset(d1, d1$Year==2001)
t.test(d1$Wing, d12001$Wing)



