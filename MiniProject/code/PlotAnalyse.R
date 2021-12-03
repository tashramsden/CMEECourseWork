#### Plotting data and model fits, analyse model fit results ----

rm(list = ls())
require(ggplot2)
require(dplyr)

par(mfrow=c(1,1))

# Read data ---
data <- read.csv("../data/modified_growth_data.csv")
model_params <- read.csv("../data/model_params.csv")

all_stats <- read.csv("../data/selection_stats_log_space.csv")
all_stats_not_log_space <- read.csv("../data/selection_stats_not_log_space.csv")


source("DefineModels.R")

make_frame <- function(times, predictions, model, id) {
    df <- data.frame(times, predictions)
    df$model <- model
    df$ID <- id
    names(df) <- c("Time", "logPopBio", "model", "ID")  #(actually for quad, cubic and logistic, predictions will be PopBio not logPopBio - only a name!)
    return(df)
}


# Plot all models onto datasets ----

datasets_to_plot <- c(15, 40)

for (id in datasets_to_plot) {
# for (id in unique(data$ID)) {

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
        geom_point(color="black") +
        theme_bw() +
        labs(x = "Time (hours)",
             y = "log(Optical density (595nm))") +
             # y = paste("log(", subset$PopBio_units, ")", sep="")) +
             # title = paste(subset$Species, "    temp:",subset$Temp,
                           # "    med:", subset$Medium)) +
        geom_line(data = model_frame, aes(x = Time, y = log(logPopBio), col = model), size=1) +
        geom_line(data = model_frame_log, aes(x = Time, y = logPopBio, col = model), size=1) +
        theme(legend.position = c(0.8, 0.2), legend.text = element_text(size=18),
              text = element_text(size=18), legend.title = element_blank())
    
    # save plots
    pdf(paste("../results/ID",subset$ID,".pdf", sep=""), 6, 6)
    # pdf(paste("../sandbox/growth_plots/ID",subset$ID,"_final_maybe.pdf", sep=""), 6, 6)
    print(p)
    dev.off()
    
}


# Model analysis ----

# all_stats <- na.omit(all_stats)  # remove any models that failed to converge

# remove any datasets where a model fails to converge - so that all Akaike
# weights etc calculated for the same set of models (all 5)
ID_to_remove <- c(all_stats$ID[is.na(all_stats$Model.params)])
for (id in ID_to_remove) {
    # print(id)
    all_stats <- all_stats[!(all_stats$ID == id), ]
}

terrible_Rsq <- all_stats$ID[all_stats$RSq < -100]
for (id in terrible_Rsq) {
    # print(id)
    all_stats <- all_stats[!(all_stats$ID == id), ]
}

# length(unique(all_stats$ID))

# AICc ----
# calculate AICc min values, likelihoods, akaike weights
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


## BIC ----
# calculate BIC min values, likelihoods, schwarz weights
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
    # Akaike/Schwarz weight = probability that a model is best given the data and model set
    mutate(Schwarz.weight = Likelihood / sum_L)


## Count which model best ----

# Counts of "best" model according to AICc
##### includes ALL best models (ie counts models which are <2 diff from best model as best as well)
all_best_aicc_models <- data_frame()
for (id in unique(all_stats_AICc$ID)) {
    subset <- subset(all_stats_AICc, all_stats_AICc$ID == id)
    # for each dataset get best model according to AICc
    # include "best" model and any whose AICc value is < 2 greater than this "best" model
    # ie there can be >1 best model per dataset
    best_models <- subset$model[subset$AICc == subset$min_AICc | subset$delta_AICc < 2]
    all_best_aicc_models <- rbind(all_best_aicc_models, tibble(id, best_models))
}
all_best_aicc_models$measure = c("AICc")
print("Counts of best model AICc:")
plyr::count(all_best_aicc_models$best_models)

# Counts of "best" model according to BIC
all_best_BIC_models <- data_frame()
for (id in unique(all_stats_BIC$ID)) {
    subset <- subset(all_stats_BIC, all_stats_BIC$ID == id)
    # for each dataset get best model according to BIC
    # include "best" model and any whose BIC value is < 2 greater than this "best" model
    # ie there can be >1 best model per dataset
    best_models <- subset$model[subset$BIC == subset$min_BIC | subset$delta_BIC < 2]
    all_best_BIC_models <- rbind(all_best_BIC_models, tibble(id, best_models))
}
all_best_BIC_models$measure = c("BIC")
print("Counts of best model BIC:")
plyr::count(all_best_BIC_models$best_models)

all_best_models_counts <- rbind(all_best_aicc_models, all_best_BIC_models)

# plot counts AICc and BIC
p <- ggplot(all_best_models_counts, aes(best_models, fill=measure)) +
    geom_bar(position = "dodge") +
    labs(x = NULL, y = "Count") +
    # geom_text(aes(x = "Quadratic", y = 150,
                  # label = "a."), size = 12, col="grey5", family="Times") +
    theme_bw() +
    theme(legend.text = element_text(size=20), legend.position = c(0.8, 0.8),
          text = element_text(size=20), legend.title = element_blank())

pdf("../results/AICc_BIC_counts.pdf", 8, 6)
print(p)
dev.off()


## Weight criteria ----

# Akaike weight
p <- ggplot(all_stats_AICc, aes(x = model, y = Akaike.weight, fill=model)) +
    geom_boxplot() +
    labs(x = NULL, y = bquote("Akaike weight  ("~AIC[c]~")")) +
    theme_bw() +
    theme(legend.position = "none", text = element_text(size=20))
# show(p)

pdf("../results/AICc_Akaike_weights.pdf", 8, 6)
print(p)
dev.off()

print("Akaike weight values:")
AICc_weights <- all_stats_AICc %>%
    group_by(model) %>%
    summarise(ave_weight = mean(Akaike.weight, na.rm=T),
              st_dev = sd(Akaike.weight, na.rm = T),
              median = median(Akaike.weight, na.rm=T),
              iqr = IQR(Akaike.weight, na.rm=T))
print(tibble(AICc_weights))

# Schwarz weight - in supplementary (same trend as Akaike weight)
p <- ggplot(all_stats_BIC, aes(x = model, y = Schwarz.weight, fill=model)) +
    geom_boxplot() +
    labs(x = NULL, y = "Schwarz weight (BIC)") +
    theme_bw() +
    theme(legend.position = "none", text = element_text(size=20))

pdf("../results/supplementary/BIC_Schwarz_weights.pdf", 8, 6)
print(p)
dev.off()

print("Schwarz weight values:")
BIC_weights <- all_stats_BIC %>%
    group_by(model) %>%
    summarise(ave_weight = mean(Schwarz.weight, na.rm=T),
              st_dev = sd(Schwarz.weight, na.rm=T))
              # median = median(Schwarz.weight, na.rm=T))
print(tibble(BIC_weights))


# R squared ----

p <- ggplot(all_stats, aes(x = model, y = RSq, fill = model)) +
    geom_boxplot() +
    labs(x = NULL, y = expression(R^2)) +
    scale_y_continuous(limits=c(0.9,1)) +
    theme_bw() +
    theme(legend.position = "none", text = element_text(size=20))

pdf("../results/R_squared.pdf", 8, 6)
print(p)
dev.off()

print("R squared:")
RSq_summary <- all_stats %>%
    group_by(model) %>%
    summarise(median = median(RSq, na.rm=T),
              iqr = IQR(RSq, na.rm=T))
print(tibble(RSq_summary))





######### NOT LOG SPACE ----
# aicc for not log space
ID_to_remove <- c(all_stats_not_log_space$ID[is.na(all_stats_not_log_space$Model.params)])
for (id in ID_to_remove) {
    # print(id)
    all_stats_not_log_space <- all_stats_not_log_space[!(all_stats_not_log_space$ID == id), ]
}
for (id in terrible_Rsq) {  # remove same datasets as above
    # print(id)
    all_stats_not_log_space <- all_stats_not_log_space[!(all_stats_not_log_space$ID == id), ]
}

# calculate AICc min values, likelihoods, akaike weights
all_stats_AICc_nl <- all_stats_not_log_space %>%
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


## BIC ----
# calculate BIC min values, likelihoods, schwarz weights
all_stats_BIC_nl <- all_stats_not_log_space %>%
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
    # Akaike/Schwarz weight = probability that a model is best given the data and model set
    mutate(Schwarz.weight = Likelihood / sum_L)


## Count which model best ----

# Counts of "best" model according to AICc
##### includes ALL best models (ie counts models which are <2 diff from best model as best as well)
all_best_aicc_models_nl <- data_frame()
for (id in unique(all_stats_AICc_nl$ID)) {
    subset <- subset(all_stats_AICc_nl, all_stats_AICc_nl$ID == id)
    # for each dataset get best model according to AICc
    # include "best" model and any whose AICc value is < 2 greater than this "best" model
    # ie there can be >1 best model per dataset
    best_models <- subset$model[subset$AICc == subset$min_AICc | subset$delta_AICc < 2]
    all_best_aicc_models_nl <- rbind(all_best_aicc_models_nl, tibble(id, best_models))
}
print("Counts of best model AICc in not-log space:")
plyr::count(all_best_aicc_models_nl$best_models)
all_best_aicc_models_nl$measure = c("AICc")

# Counts of "best" model according to BIC
all_best_BIC_models_nl <- data_frame()
for (id in unique(all_stats_BIC_nl$ID)) {
    subset <- subset(all_stats_BIC_nl, all_stats_BIC_nl$ID == id)
    # for each dataset get best model according to BIC
    # include "best" model and any whose BIC value is < 2 greater than this "best" model
    # ie there can be >1 best model per dataset
    best_models <- subset$model[subset$BIC == subset$min_BIC | subset$delta_BIC < 2]
    all_best_BIC_models_nl <- rbind(all_best_BIC_models_nl, tibble(id, best_models))
}
print("Counts of best model BIC in not-log space:")
plyr::count(all_best_BIC_models_nl$best_models)
all_best_BIC_models_nl$measure = c("BIC")

all_best_models_counts_nl <- rbind(all_best_aicc_models_nl, all_best_BIC_models_nl)

# plot counts AICc and BIC
p <- ggplot(all_best_models_counts_nl, aes(best_models, fill=measure)) +
    geom_bar(position = "dodge") +
    labs(x = NULL, y = "Count") +
    theme_bw() +
    theme(legend.text = element_text(size=20), legend.position = c(0.9, 0.8),
          text = element_text(size=20), legend.title = element_blank())

pdf("../results/supplementary/AICc_BIC_counts_not_log_space.pdf", 8, 6)
print(p)
dev.off()


# Akaike weight ----
p <- ggplot(all_stats_AICc_nl, aes(x = model, y = Akaike.weight, fill=model)) +
    geom_boxplot() +
    labs(x = NULL, y = bquote("Akaike weight  ("~AIC[c]~")")) +
    theme_bw() +
    theme(legend.position = "none", text = element_text(size=20))
# show(p)

pdf("../results/AICc_Akaike_weights_not_log_space.pdf", 8, 6)
print(p)
dev.off()

print("Akaike weight values when not in log space:")
AICc_weights <- all_stats_AICc_nl %>%
    group_by(model) %>%
    summarise(ave_weight = mean(Akaike.weight, na.rm=T),
              st_dev = sd(Akaike.weight, na.rm = T))
# median = median(Akaike.weight, na.rm=T))
# iqr = IQR(Akaike.weight, na.rm=T))
print(tibble(AICc_weights))


# Schwarz weight ----
p <- ggplot(all_stats_BIC_nl, aes(x = model, y = Schwarz.weight, fill=model)) +
    geom_boxplot() +
    labs(x = NULL, y = "Schwarz weight (BIC)") +
    theme_bw() +
    theme(legend.position = "none", text = element_text(size=20))

pdf("../results/supplementary/BIC_Schwarz_weights_not_log_space.pdf", 8, 6)
print(p)
dev.off()

print("Schwarz weight values in not log space:")
BIC_weights <- all_stats_BIC_nl %>%
    group_by(model) %>%
    summarise(ave_weight = mean(Schwarz.weight, na.rm=T),
              st_dev = sd(Schwarz.weight, na.rm=T))
# median = median(Schwarz.weight, na.rm=T))
print(tibble(BIC_weights))

