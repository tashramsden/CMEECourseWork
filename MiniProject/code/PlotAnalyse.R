#### Plotting data and model fits, analyse model fit results ----

rm(list = ls())
require(ggplot2)
require(dplyr)

par(mfrow=c(1,1))

# Read data ---
data <- read.csv("../data/modified_growth_data.csv")
model_params <- read.csv("../data/model_params.csv")
all_stats <- read.csv("../data/selection_stats.csv")

model_params <- read.csv("../data/model_params_not_log.csv")
all_stats <- read.csv("../data/selection_stats_not_log.csv")

source("DefineModels.R")

make_frame <- function(times, predictions, model, id) {
    df <- data.frame(times, predictions)
    df$model <- model
    df$ID <- id
    names(df) <- c("Time", "logPopBio", "model", "ID")
    return(df)
}


# Plot all models onto datasets ----

unique(all_stats$ID[all_stats$Sample.size == 5])

# sample sizes: ID 278: sample size of 4
# ID 282: sample size 151
# ID 234 sample size 5
datasets_to_plot <- c(234, 278, 283)

# for (id in datasets_to_plot) {
for (id in unique(data$ID)) {

    subset <- subset(data, data$ID == id)
    coef_frame <- subset(model_params, model_params$ID == id)

    times <- seq(min(subset$Time), max(subset$Time), length=2*max(subset$Time))

    
    # Quadratic ----
    a <- coef_frame$Param.value[coef_frame$Param.name=="a" & coef_frame$model == "Quadratic"]
    b <- coef_frame$Param.value[coef_frame$Param.name=="b" & coef_frame$model == "Quadratic"]
    c <- coef_frame$Param.value[coef_frame$Param.name=="c" & coef_frame$model == "Quadratic"]
    pred.quad <- a + b*times + c*(times^2)
    
    df.quad <- make_frame(times, pred.quad, "Quadratic", id)
    
    
    # Cubic ----
    a <- coef_frame$Param.value[coef_frame$Param.name=="a" & coef_frame$model == "Cubic"]
    b <- coef_frame$Param.value[coef_frame$Param.name=="b" & coef_frame$model == "Cubic"]
    c <- coef_frame$Param.value[coef_frame$Param.name=="c" & coef_frame$model == "Cubic"]
    d <- coef_frame$Param.value[coef_frame$Param.name=="d" & coef_frame$model == "Cubic"]
    pred.cubic <- a + b*times + c*(times^2) + d*(times^3)
    
    df.cubic <- make_frame(times, pred.cubic, "Cubic", id)
    
    
    # store predicted values from linear models
    model_frame <- rbind(df.quad, df.cubic)
    

    ## Logistic ----
    if (!is.na(coef_frame$Param.value[coef_frame$model=="Logistic"][1])) {
        
        r_max <- coef_frame$Param.value[coef_frame$Param.name=="r_max" & coef_frame$model=="Logistic"]
        N_0 <- coef_frame$Param.value[coef_frame$Param.name=="N_0" & coef_frame$model=="Logistic"]
        K <- coef_frame$Param.value[coef_frame$Param.name=="K" & coef_frame$model=="Logistic"]
        
        pred.log <- logistic_model(t = times, r_max = r_max, K = K, N_0 = N_0)
        df.log <- make_frame(times, pred.log, "Logistic", id)
        
        # add predictions from logistic model
        model_frame <- rbind(model_frame, df.log)
    }
    
    
    model_frame_log <- data_frame()
    ## Gompertz ----
    if (!is.na(coef_frame$Param.value[coef_frame$model=="Gompertz"][1])) {
        
        r_max <- coef_frame$Param.value[coef_frame$Param.name=="r_max" & coef_frame$model=="Gompertz"]
        N_0 <- coef_frame$Param.value[coef_frame$Param.name=="N_0" & coef_frame$model=="Gompertz"]
        K <- coef_frame$Param.value[coef_frame$Param.name=="K" & coef_frame$model=="Gompertz"]
        t_lag <- coef_frame$Param.value[coef_frame$Param.name=="t_lag" & coef_frame$model=="Gompertz"]
        
        pred.gomp <- gompertz_model(t = times, r_max = r_max, K = K, N_0 = N_0, t_lag = t_lag)
        df.gomp <- make_frame(times, pred.gomp, "Gompertz", id)
        
        # add predictions from gompertz model
        model_frame_log <- rbind(model_frame_log, df.gomp)
    }
    
    
    ## Baranyi ----
    if (!is.na(coef_frame$Param.value[coef_frame$model=="Baranyi"][1])) {
        
        r_max <- coef_frame$Param.value[coef_frame$Param.name=="r_max" & coef_frame$model=="Baranyi"]
        N_0 <- coef_frame$Param.value[coef_frame$Param.name=="N_0" & coef_frame$model=="Baranyi"]
        K <- coef_frame$Param.value[coef_frame$Param.name=="K" & coef_frame$model=="Baranyi"]
        t_lag <- coef_frame$Param.value[coef_frame$Param.name=="t_lag" & coef_frame$model=="Baranyi"]
        
        pred.baranyi <- baranyi_model(t = times, r_max = r_max, K = K, N_0 = N_0, t_lag = t_lag)
        df.baranyi <- make_frame(times, pred.baranyi, "Baranyi", id)
        
        # add predictions from baranyi model
        model_frame_log <- rbind(model_frame_log, df.baranyi)
    }
    
    
    # plot data with model fits ----
    p <- ggplot(subset, aes(Time, logPopBio)) +
        geom_point(color="green") +
        theme_bw() +
        labs(x = "Time (hours)",
             y = paste("log(", subset$PopBio_units, ")", sep=""),
             title = paste(subset$Species, "    temp:",subset$Temp,
                           "    med:", subset$Medium)) +
        geom_line(data = model_frame, aes(x = Time, y = log(logPopBio), col = model)) +
        geom_line(data = model_frame_log, aes(x = Time, y = logPopBio, col = model)) +
        theme(legend.position = c(0.8, 0.2), legend.text = element_text(size=8))
    
    # save plots
    ### need diff name - eg ID...models...
    # pdf(paste("../results/ID",subset$ID,".pdf", sep=""), 6, 6)
    pdf(paste("../data/growth_plots/ID",subset$ID,"_w_no_log.pdf", sep=""), 6, 6)
    print(p)
    dev.off()
    
}


# Model analysis ----

all_stats$ID <- as.factor(all_stats$ID)
all_stats <- na.omit(all_stats)  # remove any models that failed to converge

## AICc Akaike weights ----
all_stats_AICc <- all_stats %>% 
    select(-c(BIC, AIC, RSq)) %>% 
    group_by(ID) %>% 
    mutate(min_AICc = min(AICc)) %>% 
    ungroup() %>% 
    mutate(delta_AICc = AICc - min_AICc) %>% 
    # relative likelihood for each model
    mutate(Likelihood = exp(-0.5 * delta_AICc)) %>% 
    group_by(ID) %>% 
    # sum of relative likelihoods for all models (in each dataset)
    mutate(sum_L = sum(Likelihood)) %>% 
    ungroup() %>% 
    # Akaike weight = probability that a model is best given the data and model set
    mutate(Akaike.weight = Likelihood / sum_L)

# plot Akaike weights for each model
p <- ggplot(all_stats_AICc, aes(x = model, y = Akaike.weight, fill=model)) +
    geom_boxplot() +
    labs(x = NULL, y = bquote("Akaike weight  ("~AIC[c]~")")) +
    theme_bw() +
    theme(legend.position = "none")

pdf("../results/AICc_Akaike_weights.pdf", 6, 6)
print(p)
dev.off()

# AICc Akaike weight averages for each model
AICc_weights <- all_stats_AICc %>% 
    group_by(model) %>% 
    summarise(ave_weight = mean(Akaike.weight, na.rm=T))
tibble(AICc_weights)


## AICc ----
##### includes ALL best models (ie counts models which are <2 diff from best model as best as well)
all_best_aicc_models <- data_frame()
for (id in unique(all_stats_AICc$ID)) {
    subset <- subset(all_stats_AICc, all_stats_AICc$ID == id)
    # for each dataset get best model according to AICc
    # include "best" model and any whose AICc value is < 2 greater than this "best" model
    # ie there can be >1 best model per dataset
    best_AICc_models <- subset$model[subset$AICc == subset$min_AICc | subset$delta_AICc < 2]
    all_best_aicc_models <- rbind(all_best_aicc_models, tibble(id, best_AICc_models))
}
plyr::count(all_best_aicc_models$best_AICc_models)
ggplot(all_best_aicc_models, aes(best_AICc_models, fill=best_AICc_models)) +
    geom_bar() +
    labs(x = NULL, y = "Count") +
    theme_bw() +
    theme(legend.position = "none")


# Weighted BIC ----
all_stats_BIC <- all_stats %>% 
    select(-c(AICc, AIC, RSq)) %>% 
    group_by(ID) %>% 
    mutate(min_BIC = min(BIC)) %>% 
    ungroup() %>% 
    mutate(delta_BIC = BIC - min_BIC) %>% 
    # relative likelihood for each model
    mutate(Likelihood = exp(-0.5 * delta_BIC)) %>% 
    group_by(ID) %>% 
    # sum of relative likelihoods for all models (in each dataset)
    mutate(sum_L = sum(Likelihood)) %>% 
    ungroup() %>% 
    # Akaike weight = probability that a model is best given the data and model set
    mutate(Akaike.weight = Likelihood / sum_L)

# plot weighted BIC
p <- ggplot(all_stats_BIC, aes(x = model, y = Akaike.weight, fill=model)) +
    geom_boxplot() +
    labs(x = NULL, y = "Schwarz weight (BIC)") +
    theme_bw() +
    theme(legend.position = "none")

pdf("../results/BIC_Schwarz_weights.pdf", 6, 6)
print(p)
dev.off()

# BIC Akaike weight averages for each model
BIC_weights <- all_stats_BIC %>% 
    group_by(model) %>% 
    summarise(ave_weight = mean(Akaike.weight, na.rm=T))
tibble(BIC_weights)


# BIC ----
all_best_BIC_models <- data_frame()
for (id in unique(all_stats_BIC$ID)) {
    subset <- subset(all_stats_BIC, all_stats_BIC$ID == id)
    # for each dataset get best model according to AICc
    # include "best" model and any whose AICc value is < 2 greater than this "best" model
    # ie there can be >1 best model per dataset
    best_BIC_models <- subset$model[subset$BIC == subset$min_BIC | subset$delta_BIC < 2]
    all_best_BIC_models <- rbind(all_best_BIC_models, tibble(id, best_BIC_models))
}
ggplot(all_best_BIC_models, aes(best_BIC_models, fill=best_BIC_models)) +
    geom_bar() +
    labs(x = NULL, y = "Count") +
    theme_bw() +
    theme(legend.position = "none")
plyr::count(all_best_BIC_models$best_BIC_models)


# R squared ----
p <- ggplot(all_stats, aes(x = model, y = RSq, fill = model)) +
    geom_boxplot() +
    labs(x = NULL, y = expression(R^2)) +
    scale_y_continuous(limits=c(0.9,1)) +
    theme_bw() +
    theme(legend.position = "none")

pdf("../results/R_squared.pdf", 6, 6)
print(p)
dev.off()


### Temperature ----

### species?!?!?!

# 
# spp_ids <- data %>% 
#     group_by(Species) %>% 
#     summarise(ID = unique(ID)) %>% 
#     arrange(ID)
# all_stats <- merge(all_stats, spp_ids, by="ID")
# 
# 
# sort(unique(data$Species))  # 45 different "species"
# 
# # get genus (ish) from species
# all_stats$genus <- vapply(strsplit(all_stats$Species,"[.]"), `[`, 1, FUN.VALUE=character(1))
# all_stats$genus <- vapply(strsplit(all_stats$genus, " "), `[`, 1, FUN.VALUE=character(1))
# 
# unique(all_stats$genus)  # 23 different "genus"
# 
# 
# 
# 
# AICc_stats_Gomp <- all_stats_AICc %>% 
#     filter(model == "Gompertz")
# 
# AICc_stats_Gomp$Species <- as.factor(AICc_stats_Gomp$Species)
# ggplot(AICc_stats_Gomp, aes(x = Species, y = Akaike.weight)) +
#     geom_boxplot() +
#     theme_bw()
# 
# 
# AICc_stats_Log <- all_stats_AICc %>% 
#     filter(model == "Logistic")
# 
# AICc_stats_Log$Species <- as.factor(AICc_stats_Log$Species)
# ggplot(AICc_stats_Log, aes(x = Species, y = Akaike.weight)) +
#     geom_boxplot() +
#     theme_bw()


# sort(unique(data$Temp))
# plyr::count(all_stats$Temp)  # /5 (5 models) so eg 32 degrees only 1 dataset


# for (temp in sort(unique(all_stats$Temp))) {
#     # print(temp)
#     
#     stats_subset <- subset(all_stats_AICc, all_stats_AICc$Temp == temp)
#     
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste(temp, "degrees")) +
#         theme_bw()
#     
#     pdf(paste("../data/temp_akaike_weights/Temp_", temp,"_AICc", sep=""), 6, 6)
#     print(p)
#     dev.off()
#     
#     
#     stats_subset <- subset(all_stats_BIC, all_stats_BIC$Temp == temp)
#     
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste(temp, "degrees")) +
#         theme_bw()
#     
#     pdf(paste("../data/temp_akaike_weights/Temp_", temp,"_BIC", sep=""), 6, 6)
#     print(p)
#     dev.off()
#     
#     
# }


# for (spp in sort(unique(all_stats$Species))) {
# 
#     stats_subset <- subset(all_stats_AICc, all_stats_AICc$Species == spp)
#     
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste(spp)) +
#         theme_bw()
#     
#     pdf(paste("../data/spp_akaike_weights/", spp, "_AICc", sep=""), 6, 6)
#     print(p)
#     dev.off()
#     
#     
#     stats_subset <- subset(all_stats_BIC, all_stats_BIC$Species == spp)
#     
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste(spp)) +
#         theme_bw()
#     
#     pdf(paste("../data/spp_akaike_weights/", spp, "_BIC", sep=""), 6, 6)
#     print(p)
#     dev.off()
# 
# }

# for (gen in sort(unique(all_stats$genus))) {
#     
#     print(gen)
#     
#     stats_subset <- subset(all_stats_AICc, all_stats_AICc$genus == gen)
#     
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste(gen)) +
#         theme_bw()
#     
#     pdf(paste("../data/genus_akaike_weights/", gen, "_AICc", sep=""), 6, 6)
#     print(p)
#     dev.off()
#     
#     
#     stats_subset <- subset(all_stats_BIC, all_stats_BIC$genus == gen)
#     
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste(gen)) +
#         theme_bw()
#     
#     pdf(paste("../data/genus_akaike_weights/", gen, "_BIC", sep=""), 6, 6)
#     print(p)
#     dev.off()
#     
# }

# unique(all_stats$ID[all_stats$Sample.size == 15])
# ##################################################################################################
# ## Sample size ---------
# plyr::count(all_stats$Sample.size)
# 
# sample_size_stats <- all_stats_AICc %>%
#     mutate(sample_size_group = case_when(
#         Sample.size <= 6 ~ "<=6",
#         Sample.size > 6 & Sample.size <= 10 ~ "6<=10",
#         Sample.size > 10 & Sample.size <= 15 ~ "10<=15",
#         Sample.size > 15 & Sample.size <= 20 ~ "15<=20",
#         Sample.size > 20 & Sample.size <= 25 ~ "20<=25",
#         Sample.size > 25 ~ ">25"
#     )
#     )
# sample_size_stats$sample_size_group <- as.factor(sample_size_stats$sample_size_group)
# 
# plyr::count(sample_size_stats$sample_size_group)
# 
# 
# 
# sample_size_stats <- all_stats_AICc %>%
#     mutate(sample_size_group = case_when(
#         Sample.size <= 10 ~ "<=10",
#         Sample.size > 10 & Sample.size <= 20 ~ "10<=20",
#         Sample.size > 20 ~ ">20"
#     )
#     )
# sample_size_stats$sample_size_group <- as.factor(sample_size_stats$sample_size_group)
# 
# plyr::count(sample_size_stats$sample_size_group)
# 
# 
# sample_size_stats_BIC <- all_stats_BIC %>%
#     mutate(sample_size_group = case_when(
#         Sample.size <= 10 ~ "<=10",
#         Sample.size > 10 & Sample.size <= 20 ~ "10<=20",
#         Sample.size > 20 ~ ">20"
#     )
#     )
# sample_size_stats_BIC$sample_size_group <- as.factor(sample_size_stats_BIC$sample_size_group)
# 
# 
# # Sample.size <= 6 ~ "<=6",
# # Sample.size > 6 & Sample.size <= 10 ~ "6<=10",
# # Sample.size > 10 & Sample.size <= 15 ~ "10<=15",
# # Sample.size > 15 & Sample.size <= 20 ~ "15<=20",
# # Sample.size > 20 & Sample.size <= 25 ~ "20<=25",
# # Sample.size > 25 ~ ">25",
# 
# # Sample.size <= 5 ~ "<=5",
# # Sample.size > 5 & Sample.size <= 10 ~ "5<=10",
# # Sample.size > 10 & Sample.size <= 15 ~ "10<=15",
# # Sample.size > 15 & Sample.size <= 20 ~ "15<=20",
# # Sample.size > 20 ~ ">20",
# 
# 
# for (size in sort(unique(sample_size_stats$sample_size_group))) {
# 
#     print(size)
# 
#     stats_subset <- subset(sample_size_stats, sample_size_stats$sample_size_group == size)
# 
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste("Sample size: ", size, sep="")) +
#         theme_bw()
# 
#     pdf(paste("../data/sample_size_akaike_3_groups/sample_size_", size, "_AICc", sep=""), 6, 6)
#     print(p)
#     dev.off()
# 
# 
#     stats_subset <- subset(sample_size_stats_BIC, sample_size_stats_BIC$sample_size_group == size)
# 
#     p <- ggplot(stats_subset, aes(x = model, y = Akaike.weight, fill=model)) +
#         geom_boxplot() +
#         labs(title = paste("Sample size: ", size, sep="")) +
#         theme_bw()
# 
#     pdf(paste("../data/sample_size_akaike_3_groups/sample_size_", size, "_BIC", sep=""), 6, 6)
#     print(p)
#     dev.off()
# 
# }
# ##########################################################################################################




# # temp_akaike_AICc <- 
# 
# AICc_stats_Gomp <- all_stats_AICc %>% 
#     filter(model == "Gompertz")
# 
# AICc_stats_Gomp$Temp <- as.factor(AICc_stats_Gomp$Temp)
# ggplot(AICc_stats_Gomp, aes(x = Temp, y = Akaike.weight)) +
#     geom_boxplot() +
#     theme_bw()
# 
# 
# AICc_stats_Log <- all_stats_AICc %>% 
#     filter(model == "Logistic")
# 
# AICc_stats_Log$Temp <- as.factor(AICc_stats_Log$Temp)
# ggplot(AICc_stats_Log, aes(x = Temp, y = Akaike.weight)) +
#     geom_boxplot() +
#     theme_bw()
# 
# 
# 
# AICc_weights <- all_stats_AICc %>% 
#     group_by(model) %>% 
#     summarise(ave_weight = mean(Akaike.weight, na.rm=T))
# tibble(AICc_weights)















# sse
lowest_sse <- c()
for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    # print(paste("For ID", id))
    smallest_sse <- dataset$model[dataset$SSE == min(dataset$SSE)]
    lowest_sse <- c(lowest_sse, smallest_sse)
    
    
}
unique(lowest_sse)
lowest_sse <- as.factor(lowest_sse)
table(lowest_sse)
low_sse_model <- table(lowest_sse)
barplot(low_sse_model)

















# R squared
ggplot(all_stats, aes(x = ID, y = RSq, col = model)) +
    geom_point() +
    theme_bw()

ggplot(all_stats, aes(x = model, y = RSq)) +
    geom_boxplot() +
    theme_bw()





## AICc?!
ggplot(all_stats, aes(x = ID, y = AICc, col = model)) +
    geom_point() +
    theme_bw()

lowest_aicc <- c()
for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    # print(paste("For ID", id))
    smallest_aicc <- dataset$model[dataset$AICc == min(dataset$AICc)]
    lowest_aicc <- c(lowest_aicc, smallest_aicc)
    
    
}
# print(lowest_aic)
unique(lowest_aicc)

lowest_aicc <- as.factor(lowest_aicc)
table(lowest_aicc)

low_aicc_model <- table(lowest_aicc)
barplot(low_aicc_model)



# bic
ggplot(all_stats, aes(x = ID, y = BIC, col = model)) +
    geom_point() +
    theme_bw()

lowest_bic <- c()
for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    # print(paste("For ID", id))
    smallest_bic <- dataset$model[dataset$BIC == min(dataset$BIC)]
    lowest_bic <- c(lowest_bic, smallest_bic)
    
    
}

unique(lowest_bic)

lowest_bic <- as.factor(lowest_bic)
table(lowest_bic)


# sse
ggplot(all_stats, aes(x = ID, y = SSE, col= model)) + 
    geom_point() +
    theme_bw()

lowest_sse <- c()
for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    # print(paste("For ID", id))
    smallest_sse <- dataset$model[dataset$SSE == min(dataset$SSE)]
    lowest_sse <- c(lowest_sse, smallest_sse)
    
    
}

unique(lowest_sse)

lowest_sse <- as.factor(lowest_sse)
table(lowest_sse)












# doesn't include values within 2 of best as best too
# best_models <- all_stats %>% 
#     group_by(ID) %>% 
#     mutate(best_AICc = model[AICc == min_AICc]) %>% 
#     # mutate(best_AICc = c(model[AICc == min_AICc | delta_AICc < 2]))
#     mutate(best_BIC = model[BIC == min(BIC)]) %>%
#     # mutate(best_RSq = model[RSq == max(RSq)]) %>% 
#     summarise(best_AICc = unique(best_AICc),
#               best_BIC = unique(best_BIC))
#               # best_RSq = unique(best_RSq))
# 
# best_models$best_AICc <- as.factor(best_models$best_AICc)
# table(best_models$best_AICc)
# 
# plyr::count(best_models$best_AICc)
# 
# ggplot(best_models, aes(best_AICc, fill=best_AICc)) +
#     geom_bar() +
#     labs(x = NULL, y = "Count") +
#     theme_bw() +
#     theme(legend.position = "none")


# ## Plot raw data
# for (id in unique(data$ID)) {
# # for (id in 1:3) {
# 
#     subset <- subset(data, data$ID == id)
#     p <- ggplot(subset, aes(Time, PopBio)) +
#         geom_point(color="blue") +
#         theme_bw() +
#         labs(x = "Time (hours)",
#              y = paste("Bacterial population/biomass",subset$PopBio_units),
#              title = paste(subset$Species, "    temp:",subset$Temp,
#                            "    med:", subset$Medium))
# 
#     # show(p)
# 
#     ########### where to save?!
#     pdf(paste("../data/growth_plots/ID",subset$ID,".pdf", sep=""), 6, 6)
#     print(p)
#     dev.off()
# 
# }
# 
# 
## Plot log data
# for (id in unique(data$ID)) {
#     # for (id in 1:3) {
# 
#     subset <- subset(data, data$ID == id)
#     p <- ggplot(subset, aes(Time, logPopBio)) +
#         geom_point(color="green") +
#         theme_bw() +
#         labs(x = "Time (hours)",
#              y = paste("log(",subset$PopBio_units, ")", sep=""),
#              title = paste(subset$Species, "    temp:",subset$Temp,
#                            "    med:", subset$Medium))
# 
#     # show(p)
# 
#     ########### where to save?!
#     pdf(paste("../data/growth_plots/ID",subset$ID,"_log.pdf", sep=""), 6, 6)
#     print(p)
#     dev.off()
# 
# }






# JUST LOGISTIC

rm(list = ls())

data <- read.csv("../data/modified_growth_data.csv")

data2$ID <- as.factor(data2$ID)



logistic_model <- function(t, r_max, K, N_0) {
    return(N_0 * K * exp(r_max * t)/(K + N_0 * (exp(r_max * t) - 1)))
}

param_select_logistic <- function(subset, r_max_start, N_0_start, K_start) {
    success_fit <- tryCatch(
        {
            growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0), 
                                data=subset,
                                list(r_max=r_max_start, N_0 = N_0_start, K = K_start))
            
            # return(growth.log)
            aic <- AIC(growth.log)
            
            starts_aic <- data_frame(r_max_start, N_0_start, K_start, aic)
            names(starts_aic) <- c("r_max_start", "N_0_start", "K_start", "AIC")
            
            return(starts_aic)
            
        },
        error=function(cond){
            message(paste("Logistic fit did not converge:\n"))
            return(NULL)
        }
    )
    return(success_fit)
}


# first <- data_frame(1,2,3,4)
# names(first) <- c("1", "2", "3", "4")
# seco <- data_frame(3,4,5,6)
# names(seco) <- c("1", "2", "3", "4")
# 
# all <- r_bind(first, seco)

subset <- subset(data, data$ID == 198)


growth.straight <- lm(logPopBio ~ Time, data = subset)
coef(growth.straight)

r_max_lm <- coef(growth.straight)[[2]]

N_0_est <- min(subset$logPopBio)
K_est <- max(subset$logPopBio)
r_max_est <- r_max_lm

N_0_est

# try w diff st devs!!!!!
N_0_starts <- rnorm(65, N_0_est, 0.2)
K_starts <- rnorm(65, K_est, 0.2)
r_max_starts <- rnorm(65, r_max_est, 0.2)

# hist(N_0_starts)
# hist(K_starts)
# hist(r_max_starts)

## param sampling
params_try <- data_frame()

for (i in 1:length(N_0_starts)) {
    
    N_0_start <- N_0_starts[i]
    K_start <- K_starts[i]
    r_max_start <- r_max_starts[i]
    
    ## within a trycatch
    
    starts_aic <- param_select_logistic(subset, r_max_start, N_0_start, K_start)
    
    params_try <- rbind(params_try, starts_aic)
    
    
    # growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0), 
    #                     data=subset,
    #                     list(r_max=r_max_start, N_0 = N_0_start, K = K_start))
    # 
    # summary(growth.log)
    # coef(growth.log)
    
    # aic <- AIC(growth.log)
}

lowest_aic <- min(params_try$AIC)
best_starts <- params_try[params_try$AIC == lowest_aic,]
best_starts


N_0_start <- best_starts[["N_0_start"]]
K_start <- best_starts[["K_start"]]
r_max_start <- best_starts[["r_max_start"]]

growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0),
                    data=subset,
                    list(r_max=r_max_start, N_0 = N_0_start, K = K_start))

# growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0),
#                     data=subset,
#                     list(r_max=r_max_est, N_0 = N_0_est, K = K_est))

summary(growth.log)
coef(growth.log)

times <- seq(min(subset$Time), max(subset$Time), length=max(subset$Time)*2)

pred.log <- logistic_model(t = times,
                           r_max = coef(growth.log)["r_max"],
                           K = coef(growth.log)["K"],
                           N_0 = coef(growth.log)["N_0"])


df4 <- data.frame(times, pred.log)
df4$model <- "Logistic"
names(df4) <- c("Time", "logPopBio", "model")


p <- ggplot(subset, aes(Time, logPopBio)) +
    geom_point(color="green") +
    theme_bw() +
    labs(x = "Time (hours)",
         y = paste("log(", subset$PopBio_units, ")", sep=""),
         title = paste(subset$Species, "    temp:",subset$Temp,
                       "    med:", subset$Medium)) +
    geom_line(data = df4, aes(x = Time, y = logPopBio, col = model)) +
    theme(legend.position = c(0.8, 0.2), legend.text = element_text(size=8))

show(p)





####### ALL MODELS - TESTING!!!!!

# reasonable looking 1 and 283
# 112 has lag phase...121, 133, 144

subset <- subset(data, data$ID == 283)

# scaling?! - diff for diff units of PopBio?!?!

growth.straight <- lm(logPopBio ~ Time, data = subset)
# growth.straight <- lm(logPopBio ~ Time, data = subset[subset$Time > 10 & subset$Time < 50,])
# growth.straight <- lm(logPopBio ~ Time, data = subset[subset$Time > 0 & subset$Time < 100,])

summary(growth.straight)

coef(growth.straight)

# require("minpack.lm")

# maybe need to define own and use nlsLM...??????
growth.quad <- lm(logPopBio ~ poly(Time, 2), data = subset)
# ?poly
summary(growth.quad)
coef(growth.quad)


growth.cubic <- lm(logPopBio ~ poly(Time, 3), data = subset)
summary(growth.cubic)
coef(growth.cubic)


# classical (somewhat) mechanistic model - logistic equation:
# Nt = (N0 * K * exp(r * t)) / (K + N0 * (exp(r * t) - 1))
# r = max growth rate
logistic_model <- function(t, r_max, K, N_0) {
    return(N_0 * K * exp(r_max * t)/(K + N_0 * (exp(r_max * t) - 1)))
}


# NOTE this is in log scale log(Nt) = equation
gompertz_model <- function(t, r_max, K, N_0, t_lag) { # Modified gompertz growth model (Zwietering 1990)
    return(N_0 + (K - N_0) * exp(-exp(r_max * exp(1) * (t_lag - t)/((K - N_0) * log(10)) + 1)))
}   


# starting params
N_0_start <- min(subset$logPopBio) # log
K_start <- max(subset$logPopBio)
r_max_start <- max(diff(subset$logPopBio))/2  # steepest part of curve.... better to try to find steepest aprt of curve do lm etc....
# r_max_start <- 0.1

# for gompertz
t_lag_start <- subset$Time[which.max(diff(diff(subset$logPopBio)))]  # last timepoint of lag phase - not v robust...
# t_lag_start <- 0.0001

growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0), 
                    data=subset,
                    list(r_max=r_max_start, N_0 = N_0_start, K = K_start))

summary(growth.log)
coef(growth.log)

growth.gompertz <- nlsLM(logPopBio ~ gompertz_model(t = Time, r_max, K, N_0, t_lag),
                         data = subset,
                         list(r_max=r_max_start, K = K_start, N_0 = N_0_start,
                              t_lag = t_lag_start))
# lower = c(0.00001, -2, -6, 0.00001),
# upper = c(2, -0.1, -0.01, 50))

summary(growth.gompertz)
coef(growth.gompertz)


# predictions
times <- seq(0, max(subset$Time), length=1000)

pred.lin <- predict(growth.straight, newdata = list(Time = times), data = subset)

pred.quad <- predict(growth.quad, newdata = list(Time = times), data = subset)

# pred.quad2 <- predict.lm(growth.quad, data.frame(Time = times))

pred.cubic <- predict(growth.cubic, newdata = list(Time = times), data = subset)

pred.log <- logistic_model(t = times,
                           r_max = coef(growth.log)["r_max"],
                           K = coef(growth.log)["K"],
                           N_0 = coef(growth.log)["N_0"])

pred.gompertz <- gompertz_model(t = times,
                                r_max = coef(growth.gompertz)["r_max"], 
                                K = coef(growth.gompertz)["K"], 
                                N_0 = coef(growth.gompertz)["N_0"], 
                                t_lag = coef(growth.gompertz)["t_lag"])


# pred.data <- data.frame(times, pred.lin, pred.quad, pred.cubic, pred.log,
# pred.gompertz)



df1 <- data.frame(times, pred.lin)
df1$model <- "Straight line"
names(df1) <- c("Time", "logPopBio", "model")

df2 <- data.frame(times, pred.quad)
df2$model <- "Quadratic"
names(df2) <- c("Time", "logPopBio", "model")

df3 <- data.frame(times, pred.cubic)
df3$model <- "Cubic"
names(df3) <- c("Time", "logPopBio", "model")

df4 <- data.frame(times, pred.log)
df4$model <- "Logistic"
names(df4) <- c("Time", "logPopBio", "model")

df5 <- data.frame(times, pred.gompertz)
df5$model <- "Gompertz"
names(df5) <- c("Time", "logPopBio", "model")


# maybe for storing this have another oclumn w ID (will be HUGE df...)
model_frame <- rbind(df1, df2, df3, df4, df5)



p <- ggplot(subset, aes(Time, logPopBio)) +
    geom_point(color="green") +
    theme_bw() +
    labs(x = "Time (hours)",
         y = paste("log(", subset$PopBio_units, ")", sep=""),
         title = paste(subset$Species, "    temp:",subset$Temp,
                       "    med:", subset$Medium)) +
    geom_line(data = model_frame, aes(x = Time, y = logPopBio, col = model)) +
    theme(legend.position = c(0.2, 0.8), legend.text = element_text(size=8))



show(p)



p <- ggplot(subset, aes(Time, logPopBio)) +
    geom_point(color="green") +
    theme_bw() +
    labs(x = "Time (hours)",
         y = paste("LOG",subset$PopBio_units),
         title = paste(subset$Species, "    temp:",subset$Temp,
                       "    med:", subset$Medium))

show(p)

p <- ggplot(subset, aes(Time, logPopBio)) +
    geom_point(color="green") +
    theme_bw() +
    labs(x = "Time (hours)",
         y = paste("Bacterial population/biomass",subset$PopBio_units),
         title = paste(subset$Species, "    temp:",subset$Temp,
                       "    med:", subset$Medium)) +
    geom_line(data = pred.data, aes(x = times, y = pred.lin, color="straight")) +
    geom_line(data = pred.data, aes(x = times, y = pred.quad, color="quadratic")) +
    geom_line(data = pred.data, aes(x = times, y = pred.cubic, color="cubic")) +
    geom_line(data = pred.data, aes(x = times, y = pred.log, color="logistic")) +
    geom_line(data = pred.data, aes(x = times, y = pred.gompertz, color="logistic")) +
    
    theme(legend.position = c(0.2, 0.8), legend.text = element_text(size=8))


show(p)


# residuals - for the linear models - RUBBISH!!!!!
par(mfrow=c(5,1), bty="n")
plot(subset$Time, resid(growth.straight), main="Straight resids")
plot(subset$Time, resid(growth.quad), main="Quadratic resids")
plot(subset$Time, resid(growth.cubic), main="Cubic resids")
plot(subset$Time, resid(growth.log), main="Logistic resids")
plot(subset$Time, resid(growth.gompertz), main="Gompertz resids")


# SSE
n <- length(subset$logPopBio)
list(lin = signif(sum(resid(growth.straight)^2)/(n-2 * 2), 3), 
     quad = signif(sum(resid(growth.quad)^2)/(n-2 * 3), 3), 
     cubic = signif(sum(resid(growth.cubic)^2)/(n-2 * 4), 3),
     log = signif(sum(resid(growth.log)^2)/(n-2 * 3), 3),
     gompertz = signif(sum(resid(growth.gompertz)^2)/(n-2 * 4), 3))  

# confint for log and gomp
confint(growth.log)
confint(growth.gompertz)

# AIC and BIC
AIC(growth.log)
AIC(growth.gompertz)
AIC(growth.cubic)  
AIC(growth.quad)
AIC(growth.straight)  # highest

BIC(growth.log)
BIC(growth.gompertz)
BIC(growth.cubic)
BIC(growth.quad)
BIC(growth.straight)


# TO DO:
# try to compare these models using AIC etc
# think about how straight line could be fitted to expo part of curve - this 
#   prob needed for starting values in more complex models as well
# define some more models and try of these data
# try to plot the simple models on all data sets
# think about log vs not PopBio
# scaling!?


# estimate max growth rate, r
max(diff(subset$logPopBio))/2  # steepest part of curve...


