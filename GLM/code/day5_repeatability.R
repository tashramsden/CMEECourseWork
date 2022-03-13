## Linear mixed models - repeatability and using MCMCglmm----

rm(list=ls())
# setwd("/home/tash/Documents/CMEECourseWork/GLM_week16/code")

require(MCMCglmm)

# repeatability
# if within-indiv repeatability in eg wing length == indiv birds have consistent wing length
# differ less between multiple measures of same infiv than they differ from diff indivs
# can also call this differences between indivs
# r or intraclass correlation coefficient

# can be used to describe biological things, eg whether trait varies through indiv life
# or assess quality of measurement, eg observer repeatability

# see handout for calculations in full/discussion
# = between-group var / (tot var = between + within)

d<-read.table("../data/DataForMMs.txt", header=T)
str(d)
d$Sex <- as.factor(d$Sex)
d$Family <- as.factor(d$Family)

# see how many repeated measures for body mass
table(table(d$Individual))
# 100 indivs w 20 repeated measures each

# sample size sufficient to partition within & between group variances

# bayesian Markov chain Monte Carlo (MCMC)
m <- MCMCglmm(Bodymass ~ 1, random=~Individual, data=d, nitt=1000, burnin=0)
# actually NEVER have burn in = 0, and num iterations much bigger
# (by default MCMC runs for 13000 iters and burn in = 3000 - discarded)

# joint posterior distributions show the potential param ests..
# variance components stored in element VCV (VarianceCoVariance),
# fixed params in Sol (remember w Sol is for solutions)

plot(m$Sol)
# since no fixed effects, this gives mean = 0.15

plot(m$VCV)
# get plot for indiv and for residuals (units)
# variances - not <0
# indiv posteriors narrow down to == 0.4 ish
# residuals ~ 0.74

# now w default burn in and num iters
m1 <- MCMCglmm(Bodymass ~ 1, random=~Individual, data=d)
plot(m1$Sol)
plot(m1$VCV)
# ests better and density plots smoother

# marcov chain supposed to sample indepdendently between 2 subsequent iters
# need to make sure this true - calculate autocorrelation between successive 
# samples for each variable:

autocorr(m1$Sol)
# w lag 0 - autocorr is 1 (expected as compare posterior w itself)
# check others - ok if close to 0 (0.01-0.1)

autocorr(m1$VCV)
# also look ok 
# if not ok - run model for longer!

# now can look at summary
summary(m1)
# (thinning interval = 10 means only every 10th posterior estimate stored) - can specify w thin=...

# DIC = deviance information criterion - smaller by >3 = preferred model 

# G-structure = random effects structure
# posterior = 0.47 (credibility interval (CI) 0.34-0.61)
# credibility interval ~ Bayesian version of confidence interval

# R-structure = residuals & CI

# fixed effects 
# didn't estimate any here - so just get intercept = mean & CIs
# this mean stat sig as CIs do not span 0


## calculating repeatability:

# get posterior means and CIs:
posterior.mode(m1$VCV[,"Individual"])
HPDinterval(m1$VCV[,"Individual"])

posterior.mode(m1$VCV[,"units"])
HPDinterval(m1$VCV[,"units"])

# ## (for better understanding: look at one of the variables)
# head(m1$VCV[,"Individual"])
# str(m1$VCV[,"Individual"])
# m1$VCV[,"Individual"]
# # got param est every 10th iter
# # posterior.mode gives mode of all this, HPD interval gives posterior 
# # distribution (PD) - by default set to 95%

# can calculate total phenotypic variance by using posterior densities:
VT1 = (m1$VCV[,"Individual"] + m1$VCV[,"units"])
posterior.mode(VT1)

# gets v similar result to using mean squares:
var(d$Bodymass)

# but the Bayesian estimate gives a measure of precision too:
HPDinterval(VT1)

# repeatability (& 95CI!)
R1 <- m1$VCV[,"Individual"] / (m1$VCV[,"Individual"] + m1$VCV[,"units"])
posterior.mode(R1)

HPDinterval(R1)

# repeatability of body mass in unicorns is about 38% (95CI between 32% and 46%)
