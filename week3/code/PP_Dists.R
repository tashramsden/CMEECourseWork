#### Body mass distributions

require(ggplot2)
require(tidyverse)

ecol_data <- read.csv("../data/EcolArchives-E089-51-D1.csv")
dplyr::glimpse(ecol_data)

# change some columns to factors - can use as grouping vars
ecol_data$Type.of.feeding.interaction <- as.factor(ecol_data$Type.of.feeding.interaction)


## Pred_Subplots.pdf

## print(levels(ecol_data$Type.of.feeding.interaction))
## ecol_data[ecol_data$Type.of.feeding.interaction == "insectivorous",]
# pdf("../results/Pred_Subplots.pdf", 6, 9)
# par(mfcol=c(5,1)) #initialize multi-paneled plot
# for (method in levels(ecol_data$Type.of.feeding.interaction)) {
#     subset = ecol_data[ecol_data$Type.of.feeding.interaction == method,]
#     print(method)
#     hist(log10(subset$Predator.mass),
#     xlab = "log10(Predator Mass (g))", ylab = "Count", 
#     main=str_to_title(method), col=rgb(1, 0, 0, 0.9), 
#     xlim=c(-4, 6), breaks=seq(-4, 6, 0.25))
# }
# graphics.off();

# same as above but using ggplot!!! - much nicer!
p1 <- ggplot(ecol_data, aes(x = (Predator.mass))) +
    scale_x_log10("Predator Mass (g)", minor_breaks=NULL) +
    scale_y_continuous("Count", minor_breaks=NULL) +
    geom_histogram(fill = "tomato3", colour="grey", size=0.1) + 
    theme_bw() +
    theme(legend.position = "none") +
    facet_grid(Type.of.feeding.interaction ~., scales="free")
p1
# save plot
pdf("../results/Pred_Subplots.pdf", 6, 9)
print(p1)
dev.off();


## Prey_Subplots.pdf

# pdf("../results/Prey_Subplots.pdf", 6, 9)
# par(mfcol=c(5,1)) #initialize multi-paneled plot
# for (method in levels(ecol_data$Type.of.feeding.interaction)) {
#     subset = ecol_data[ecol_data$Type.of.feeding.interaction == method,]
#     hist(log10(subset$Prey.mass),
#     xlab = "log10(Prey Mass (g))", ylab = "Count", 
#     main=str_to_title(method), col=rgb(0, 0.8, 0.2, 0.9),
#     xlim=c(-10, 4), breaks = seq(-12, 4, 0.5))
# }
# graphics.off();

# ggplot
p2 <- ggplot(ecol_data, aes(x = (Prey.mass))) +
    scale_x_log10("Prey Mass (g)", minor_breaks=NULL) +
    scale_y_continuous("Count", minor_breaks=NULL) +
    geom_histogram(fill = "palegreen4", colour="grey", size=0.1) + 
    theme_bw() +
    theme(legend.position = "none") +
    facet_grid(Type.of.feeding.interaction ~., scales="free")
p2
# save plot
pdf("../results/Prey_Subplots.pdf", 6, 9)
print(p2)
dev.off();


## SizeRatio_Subplots.pdf

# ecol_data$Pred.prey.size.ratio <- ecol_data$Prey.mass / ecol_data$Predator.mass
# head(ecol_data$Pred.prey.size.ratio)
# pdf("../results/SizeRatio_Subplots.pdf", 6, 9)
# par(mfcol=c(5,1)) #initialize multi-paneled plot
# for (method in levels(ecol_data$Type.of.feeding.interaction)) {
#     subset = ecol_data[ecol_data$Type.of.feeding.interaction == method,]
#     hist(log10(subset$Pred.prey.size.ratio),
#     xlab = "log10(Prey/Predator Size Ratio)", ylab = "Count", 
#     main=str_to_title(method), col=rgb(0.2, 0.2, 0.8, 0.9),
#     xlim=c(-8, 2), breaks = seq(-10, 4, 0.5))
# }
# graphics.off();

# ggplot
p3 <- ggplot(ecol_data, aes(x = (Prey.mass/Predator.mass))) +
    scale_x_log10("Prey/Predator Size Ratio", minor_breaks=NULL) +
    scale_y_continuous("Count", minor_breaks=NULL) +
    geom_histogram(fill = "royalblue3", colour="grey", size=0.1) + 
    theme_bw() +
    theme(legend.position = "none") +
    facet_grid(Type.of.feeding.interaction ~., scales="free")
p3
# save plot
pdf("../results/SizeRatio_Subplots.pdf", 6, 9)
print(p3)
dev.off();


## PP_Results.csv

# pred_means <- vector()
# pred_medians <- vector()
# 
# for (method in levels(ecol_data$Type.of.feeding.interaction)) {
#     subset = ecol_data[ecol_data$Type.of.feeding.interaction == method,]
# 
#     pred_mean <- log10(mean(subset$Predator.mass))
#     pred_means <- c(pred_means, pred_mean)
# 
#     pred_median <- log10(median(subset$Predator.mass))
#     pred_medians <- c(pred_medians, pred_median)
# 
# }
# print(means)
# print(pred_medians)
# 
# stats_output = matrix()
# stats_output$pred_means <- pred_means
# stats_output$pred_medians <- pred_medians
# 
# print(stats_output)

stats <- ecol_data %>% 
    group_by(Type.of.feeding.interaction) %>% 
    summarise(pred_mean = mean(log(Predator.mass)),
              pred_median = median(log(Predator.mass)),
              prey_mean = mean(log(Prey.mass)),
              prey_median = median(log(Prey.mass)),
              ratio_mean = mean(log(Prey.mass/Predator.mass)),
              ratio_median = median(log(Prey.mass/Predator.mass)))
colnames(stats) <- c("Feeding.Type", "Predator.Mean", "Predator.Median",
                     "Prey.Mean", "Prey.Median", "Ratio.Mean", "Ratio.Median")

stats

write.csv(stats, "../results/PP_Results.csv", row.names=FALSE)

