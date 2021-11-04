#### Body mass distributions

rm(list=ls())

require(ggplot2)
require(tidyverse)

raw_ecol_data <- read.csv("../data/EcolArchives-E089-51-D1.csv")
dplyr::glimpse(raw_ecol_data)


## make sure prey mass in g for all (some are mg)
# convert mg to grams
mg_mass <- raw_ecol_data %>% 
    dplyr::filter(raw_ecol_data$Prey.mass.unit == "mg") %>% 
    mutate(Prey.mass.g = Prey.mass / 1000)
# keep g mass the same but make new column
g_mass <- raw_ecol_data %>% 
    dplyr::filter(raw_ecol_data$Prey.mass.unit == "g") %>% 
    mutate(Prey.mass.g = Prey.mass)
# combine the 2 above to get full dataset again (w new column Prey.mass.g)
ecol_data <- full_join(mg_mass, g_mass)


## change some columns to factors - can use as grouping vars
ecol_data$Type.of.feeding.interaction <- as.factor(ecol_data$Type.of.feeding.interaction)


## Pred_Subplots.pdf
p1 <- ggplot(ecol_data, aes(x = (Predator.mass))) +
    scale_x_log10("Predator Mass (g)", minor_breaks=NULL) +
    scale_y_continuous("Count", minor_breaks=NULL) +
    geom_histogram(fill = "tomato3", colour="grey", size=0.1) + 
    theme_bw() +
    theme(legend.position = "none") +
    facet_grid(Type.of.feeding.interaction ~., scales="free")
# p1
# save plot
pdf("../results/Pred_Subplots.pdf", 6, 9)
print(p1)
dev.off()


## Prey_Subplots.pdf
p2 <- ggplot(ecol_data, aes(x = (Prey.mass.g))) +
    scale_x_log10("Prey Mass (g)", minor_breaks=NULL) +
    scale_y_continuous("Count", minor_breaks=NULL) +
    geom_histogram(fill = "palegreen4", colour="grey", size=0.1) + 
    theme_bw() +
    theme(legend.position = "none") +
    facet_grid(Type.of.feeding.interaction ~., scales="free")
# p2
# save plot
pdf("../results/Prey_Subplots.pdf", 6, 9)
print(p2)
dev.off()


## SizeRatio_Subplots.pdf
p3 <- ggplot(ecol_data, aes(x = (Prey.mass.g/Predator.mass))) +
    scale_x_log10("Prey/Predator Size Ratio", minor_breaks=NULL) +
    scale_y_continuous("Count", minor_breaks=NULL) +
    geom_histogram(fill = "royalblue3", colour="grey", size=0.1) + 
    theme_bw() +
    theme(legend.position = "none") +
    facet_grid(Type.of.feeding.interaction ~., scales="free")
# p3
# save plot
pdf("../results/SizeRatio_Subplots.pdf", 6, 9)
print(p3)
dev.off()


## PP_Results.csv
stats <- ecol_data %>% 
    group_by(Type.of.feeding.interaction) %>% 
    summarise(pred_mean = mean(log10(Predator.mass)),
              pred_median = median(log10(Predator.mass)),
              prey_mean = mean(log10(Prey.mass.g)),
              prey_median = median(log10(Prey.mass.g)),
              ratio_mean = mean(log10(Prey.mass.g/Predator.mass)),
              ratio_median = median(log10(Prey.mass.g/Predator.mass)))
colnames(stats) <- c("Feeding.Type", "Log.Predator.Mean", "Log.Predator.Median",
                     "Log.Prey.Mean", "Log.Prey.Median", "Log.Ratio.Mean", 
                     "Log.Ratio.Median")

stats
write.csv(stats, "../results/PP_Results.csv", row.names=FALSE)
