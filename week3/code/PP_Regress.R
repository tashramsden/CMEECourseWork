## Predator-Prey Regression

require(ggplot2)
require(tidyverse)

MyDF <- as.data.frame(read.csv("../data/EcolArchives-E089-51-D1.csv"))
dplyr::glimpse(MyDF)

# make some columns factors
MyDF$Type.of.feeding.interaction <- as.factor(MyDF$Type.of.feeding.interaction)
MyDF$Predator.lifestage <- as.factor(MyDF$Predator.lifestage)

# plot
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

# linear regressions
# pp_lm <- lm(Predator.mass ~ Prey.mass + Predator.lifestage + Type.of.feeding.interaction, data = MyDF)
# pp_lm$coefficients


