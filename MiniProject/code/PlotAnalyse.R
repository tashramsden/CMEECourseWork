#### Plotting data and model fits, analyse model fit results ----

rm(list = ls())
require(ggplot2)

par(mfrow=c(1,1))

# Read data ---
data <- read.csv("../data/modified_growth_data.csv")
model_params <- read.csv("../data/model_params2.csv")
all_stats <- read.csv("../data/selection_stats2.csv")


logistic_model <- function(t, r_max, K, N_0) {
    return(N_0 * K * exp(r_max * t)/(K + N_0 * (exp(r_max * t) - 1)))
}

gompertz_model <- function(t, r_max, K, N_0, t_lag) { # Modified gompertz growth model (Zwietering 1990)
    return(N_0 + (K - N_0) * exp(-exp(r_max * exp(1) * (t_lag - t)/((K - N_0) * log(10)) + 1)))
} 


make_frame <- function(times, predictions, model, id) {
    df <- data.frame(times, predictions)
    df$model <- model
    df$ID <- id
    names(df) <- c("Time", "logPopBio", "model", "ID")
    return(df)
}


# Plot all models onto each data set ----
for (id in unique(data$ID)) {
# for (id in 5) {
    
    subset <- subset(data, data$ID == id)
    coef_frame <- subset(model_params, model_params$ID == id)
    # coef_frame <- subset(model_params, model_params$ID == 5)
    

    times <- seq(min(subset$Time), max(subset$Time), length=2*max(subset$Time))
    
    # Straight line ----
    intercept <- coef_frame$Param.value[coef_frame$Param.name=="Intercept"]
    slope <- coef_frame$Param.value[coef_frame$Param.name=="Slope"]
    pred.lin <- slope * times + intercept
    
    df.lin <- make_frame(times, pred.lin, "Straight line", id)
    
    
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
    
    
    # predicted values from all models
    model_frame <- rbind(df.lin, df.quad, df.cubic)
    

    ## Logistic ----
    
    ####### NOT NECESSARY NOW- ALL LOG MODELS FIT!!!!
    if (!is.na(coef_frame$Param.value[coef_frame$model=="Logistic"][1])) {
        
        r_max <- coef_frame$Param.value[coef_frame$Param.name=="r_max" & coef_frame$model=="Logistic"]
        N_0 <- coef_frame$Param.value[coef_frame$Param.name=="N_0" & coef_frame$model=="Logistic"]
        K <- coef_frame$Param.value[coef_frame$Param.name=="K" & coef_frame$model=="Logistic"]
        
        
        pred.log <- logistic_model(t = times, r_max = r_max, K = K, N_0 = N_0)
        
        df.log <- make_frame(times, pred.log, "Logistic", id)
        
        
        # predicted values from all models
        model_frame <- rbind(model_frame, df.log)
    }
    
    
    ## Gompertz ----
        if (!is.na(coef_frame$Param.value[coef_frame$model=="Gompertz"][1])) {
        
        r_max <- coef_frame$Param.value[coef_frame$Param.name=="r_max" & coef_frame$model=="Gompertz"]
        N_0 <- coef_frame$Param.value[coef_frame$Param.name=="N_0" & coef_frame$model=="Gompertz"]
        K <- coef_frame$Param.value[coef_frame$Param.name=="K" & coef_frame$model=="Gompertz"]
        t_lag <- coef_frame$Param.value[coef_frame$Param.name=="t_lag" & coef_frame$model=="Gompertz"]
        
        pred.gomp <- gompertz_model(t = times, r_max = r_max, K = K, N_0 = N_0, t_lag = t_lag)
        
        df.gomp <- make_frame(times, pred.gomp, "Gompertz", id)
        
        # predicted values from all models
        model_frame <- rbind(model_frame, df.gomp)
    }
    
    
    # plot data with model fits
    p <- ggplot(subset, aes(Time, logPopBio)) +
        geom_point(color="green") +
        theme_bw() +
        labs(x = "Time (hours)",
             y = paste("log(", subset$PopBio_units, ")", sep=""),
             title = paste(subset$Species, "    temp:",subset$Temp,
                           "    med:", subset$Medium)) +
        geom_line(data = model_frame, aes(x = Time, y = logPopBio, col = model)) +
        theme(legend.position = c(0.8, 0.2), legend.text = element_text(size=8))
    
    # save plots
    ### need diff name - eg ID...models...
    pdf(paste("../data/growth_plots/ID",subset$ID,"_models_w_gomp.pdf", sep=""), 6, 6)
    print(p)
    dev.off()
    
}



## Selection values ----


lowest_aic_model <- c()
lowest_aic_value <- c()

for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    smallest_aic <- dataset$model[dataset$AIC == min(dataset$AIC)]
    low_aic <- dataset$AIC[dataset$AIC == min(dataset$AIC)]
    lowest_aic_model <- c(lowest_aic_model, smallest_aic)
    lowest_aic_value <- c(lowest_aic_value, low_aic)
    
} 

lowest_aic_model <- as.factor(lowest_aic_model)
table(lowest_aic_model)

low_aic_model <- table(lowest_aic_model)
barplot(low_aic_model)

# ggplot(all_stats, aes(x = ID, y = (AIC/lowest_aic_value), col = model)) +
#     geom_point() +
#     scale_y_continuous(limits =c(-50, 50)) +
#     theme_bw()

# lowest_aic <- data_frame(lowest_aic_value)
# lowest_aic$ID <- c(1:285)
# 
# all_stats <- full_join(all_stats, lowest_aic, by="ID")
# 
# 
# delta_aic <- c()
# for (i in 1:nrow(all_stats)) {
#     dataset <- all_stats[i,]
#     aic_diff <- dataset$AIC - dataset$lowest_aic_value
#     delta_aic <- c(delta_aic, aic_diff)
# }
# 
# delta_aic <- data_frame(delta_aic)
# 
# all_stats <- cbind(all_stats, delta_aic)
# 
# all_stats$ID <- as.factor(all_stats$ID)
# 
# 
# ggplot(all_stats, aes(x = ID, y = delta_aic, col = model)) +
#     ylim(c(0, 50)) +
#     geom_point() +
#     geom_hline(yintercept=2, col="red") +
#     geom_hline(yintercept=3, col="red") +
#     theme_bw()

# aic
ggplot(all_stats, aes(x = ID, y = AIC, col = model)) +
    geom_point() +
    theme_bw()

# aic_table <- data.frame(all_stats$ID, all_stats$AIC, min(all_stats$AIC) - all_stats$AIC, all_stats$model)


lowest_aic <- c()
max_aic <- c()
for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    # print(paste("For ID", id))
    smallest_aic <- dataset$model[dataset$AIC == min(dataset$AIC)]
    lowest_aic <- c(lowest_aic, smallest_aic)
    
    high_aic <- dataset$model[dataset$AIC == max(dataset$AIC)]
    max_aic <- c(max_aic, high_aic)
    
    
} 
# print(lowest_aic)
unique(lowest_aic)

lowest_aic <- as.factor(lowest_aic)
table(lowest_aic)

aic_bar <- table(lowest_aic)
barplot(aic_bar)


unique(max_aic)
max_aic <- as.factor(max_aic)
table(max_aic)


for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    # print(paste("For ID", id))
    
    min_aic <- min(dataset$AIC)
    
    if (dataset$AIC[!min_aic] - min_aic > 2) {
        print("good")
    }
    
    smallest_aic <- dataset$model[dataset$AIC == min(dataset$AIC)]
    lowest_aic <- c(lowest_aic, smallest_aic)
    
    
} 

# print(dataset$AIC[!min(dataset$AIC)])
# diffs <- dataset$AIC - min_aic
# for (diff in diffs) {
#     if diff > 0 & diff 
# }





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

