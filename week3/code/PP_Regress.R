## Predator-Prey Regression

rm(list=ls())

require(ggplot2)
require(tidyverse)

MyDF <- as.data.frame(read.csv("../data/EcolArchives-E089-51-D1.csv"))
dplyr::glimpse(MyDF)

## plot
plot <- ggplot(MyDF, aes(x = Prey.mass, y = Predator.mass,
                         colour = Predator.lifestage)) +
    geom_point(shape = I(3)) +
    scale_x_log10("Prey Mass in grams", minor_breaks=NULL) +
    scale_y_log10("Predator Mass in grams", limits = c(1e-09, 1e+08),
                  minor_breaks=NULL) +
    facet_grid(Type.of.feeding.interaction ~. ) +
    theme_bw() +
    theme(legend.position = "bottom", aspect.ratio=0.45) +
    geom_smooth(method = "lm", fullrange = TRUE, size=0.5) +
    guides(colour = guide_legend(nrow = 1))

plot

pdf("../results/PP_Regress.pdf", 8, 10)
print(plot)
dev.off()


## linear regressions
# for each lifestage and interaction - do lm of predator and prey mass 

## test on one subset
# subset <- MyDF %>% 
#     filter(Predator.lifestage == "adult") %>% 
#     filter(Type.of.feeding.interaction == "predacious/piscivorous")
# eg_lm <- lm(Predator.mass ~ Prey.mass, data = subset)
# slope <- eg_lm$coefficients[[2]]
# slope
# intercept <- eg_lm$coefficients[[1]]
# intercept
# r_squared <- summary(eg_lm)$r.squared
# r_squared
# f_stat <- summary(eg_lm)$fstatistic[[1]]
# f_stat  
# p_value <- summary(eg_lm)$coefficients[,4][[2]]
# p_value
# stats <- c(slope, intercept, r_squared, f_stat, p_value)
# stats
# write.table(t(stats), "../results/PP_Regress_Results.csv",
#             row.names=FALSE, append=TRUE, sep=",", col.names=FALSE) 


## create csv w headers
headers <- c("feeding_interaction", "lifestage", "slope", "intercept",
             "r_squared", "f-stat", "p-value")

write.table(t(headers), "../results/PP_Regress_Results.csv",  # transpose vector otherwise wants to write as a column
            row.names=FALSE, col.names=FALSE)


## make some columns factors
MyDF$Type.of.feeding.interaction <- as.factor(MyDF$Type.of.feeding.interaction)
# NEED Predator.lifestage to not be a factor before entering loop - set later


## need this because otherwise get error for piscivorous, postlarva/juveniile 
# - not all stats values exist for this combo
save_stats <- function(subset_lm, interaction, lifestage) {
    out <- tryCatch(
        {
            slope <- subset_lm$coefficients[[2]]
            intercept <- subset_lm$coefficients[[1]]
            r_squared <- summary(subset_lm)$r.squared
            f_stat <- summary(subset_lm)$fstatistic[[1]]
            p_value <- summary(subset_lm)$coefficients[,4][[2]]
            
            stats <- c(interaction, lifestage, slope, intercept, 
                       r_squared, f_stat, p_value)
            
            write.table(t(stats), "../results/PP_Regress_Results.csv",
                        row.names=FALSE, append=TRUE, sep=",", col.names=FALSE) 
        },
        error=function(cond) {
            message(cond)
            return(NULL)
        }
    )
    return(out)
}

# loop interaction types and lifestages
for (interaction in levels(MyDF$Type.of.feeding.interaction)) {
    # print(interaction)
    sub1 <- MyDF %>%
        filter(Type.of.feeding.interaction == interaction)
    
    # set lifestage as a factor at this point so that only lifestages that 
    # exist for each type of interaction are included (misses out missing combos)
    sub1$Predator.lifestage <- as.factor(sub1$Predator.lifestage)
    # print(levels(sub1$Predator.lifestage))
    
    for (lifestage in levels(sub1$Predator.lifestage)) {
        # print(lifestage)
        sub2 <- sub1 %>% 
            filter(Predator.lifestage == lifestage)
        
        # linear regression
        subset_lm <- lm(Predator.mass ~ Prey.mass, data = sub2)
        # get stats and save to csv
        save_stats(subset_lm, interaction, lifestage)
    }
}


## testing specific weird examples
# subset <- MyDF %>% 
#     filter(Predator.lifestage == "postlarva/juvenile") %>% 
#     filter(Type.of.feeding.interaction == "piscivorous")
# eg_lm <- lm(Predator.mass ~ Prey.mass, data = subset)
# summary(eg_lm)$coefficients
# 
# 
# subset <- MyDF %>% 
#     filter(Predator.lifestage == "juvenile") %>% 
#     filter(Type.of.feeding.interaction == "planktivorous")
# eg_lm <- lm(Predator.mass ~ Prey.mass, data = subset)
# summary(eg_lm)$coefficients
