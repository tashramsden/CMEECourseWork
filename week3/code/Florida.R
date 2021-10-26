## Is Florida getting warmer?

rm(list = ls())
require(ggplot2)

load("../data/KeyWestAnnualMeanTemperature.RData")
ls()

class(ats)
head(ats)

# par(mfrow=c(1,1))
plot(ats)


## calculate and store correlation coef between years and temp
# ?cor
obs_correlation <- cor.test(x=ats$Year, y=ats$Temp)  # has all stats
obs_correlation

# observed correlation coefficient
obs_coef <- cor(x=ats$Year, y=ats$Temp) # just the cor coef
obs_coef


## repeat w randomly shuffled temps (lots!)
repeats = 10000  # how many times to resample the temp data
# ?sample
temp_shuffle <- sample(ats$Temp)
temps_shuffled <- replicate(repeats, sample(ats$Temp))

all_coefs <- rep(NA, repeats)  # preallocate vector for coefs
for (n in 1:ncol(temps_shuffled)) {
    # print(temps_shuffled[,n])
    all_coefs[n] <- cor(x=ats$Year, y=temps_shuffled[,n])
}

all_coefs

# plot histogram of random coefs, add observed coef as line
# hist(all_coefs, xlim=c(-0.6, 0.6))
# segments(x0=obs_coef, x1=obs_coef, y0=-10, y1=3000, col="red")

coefs_df <- as.data.frame(all_coefs)  # for ggplot
coefs_hist <- ggplot(coefs_df, aes(all_coefs)) +
    geom_histogram(fill="lightblue", colour="grey", binwidth=0.03) +
    scale_x_continuous("Correlation coefficient", limits=c(-0.5, 0.6),
                       minor_breaks = NULL, expand=c(0,0)) +
    scale_y_continuous("Count", limits=c(0, 1300), minor_breaks = NULL,
                       expand=c(0,0)) +
    geom_vline(xintercept=obs_coef, colour="red", cex=1) +
    theme_bw()
coefs_hist

# save plot
pdf("../writeup/coefs_hist.pdf", 2, 2)
print(coefs_hist)
dev.off();

## what fraction of random cor-coefs are greater than the observed?
# print(length(all_coefs[all_coefs > obs_coef]))


fraction <- length(all_coefs[all_coefs > obs_coef]) / length(all_coefs)
fraction

print(paste("The p-value is:", fraction, "(",repeats, "repeats )"))

# interpret!

