#### Model fitting and comparison ----

rm(list = ls())

library(rollRegres)
library(minpack.lm)
library(dplyr)

data <- read.csv("../data/modified_growth_data.csv")

set.seed(12345)

source("DefineModels.R")
source("ParamSampling.R")
source("TryFinalFits.R")


# Headers for data frames of model parameters and model selection values
param_df_headers <- c("Param.name", "Param.value", "ID", "model")
stats_df_headers <- c("ID", "Sample.size", "Model.params", "AIC", "AICc", "BIC", "RSq", "model")


# Create data frame of model coefficients
get_params <- function(fit_model, param_names, id, model_name) {
    if (is.null(fit_model)) {
        model_params <- rep(NA, length(param_names))
    } else {
        model_params <- coef(fit_model)
    }

    df <- data_frame(param_names, model_params)
    df$ID <- id
    df$model <- model_name
    names(df) <- param_df_headers
    return(df)
}


# Create data frame of model selection values
get_stats <- function(fit_model, id, model_name, tss, n) {
    if (is.null(fit_model)) {  # if no model fit - replace selection values w NA
        missing_stats <- rep(NA, length(stats_df_headers)-3)
        stats <- c(id, n, missing_stats, model_name)
        stats <- as.data.frame(t(stats))
        names(stats) <- stats_df_headers
        return(stats)
    }
    
    aic <- AIC(fit_model)
    bic <- BIC(fit_model)
    # small sample (corrected) aic
    p <- length(coef(fit_model))   # number of fitted coefficients
    AICc <- aic + (2*p * (p + 1)) / (n - p - 1)
    
    # Residual sum of squares
    rss <- sum(residuals(fit_model)^2)
    
    # aic_self <- n + 2 + n * log((2 * pi) / n) + n * log(rss) + 2 * p
    
    # R-squared
    RSq <- 1 - (rss/tss) 
    
    stats <- data_frame(id, n, p, aic, AICc, bic, RSq, model_name) 
    names(stats) <- stats_df_headers
    return(stats)
}


all_models <- data.frame()
all_stats <- data.frame()


for (id in unique(data$ID)) {

    subset <- subset(data, data$ID == id)
    
    n <- length(subset$logPopBio)  # sample size
    # Total sum of squares - pass this to get_stats() for each model for calculating Rsq
    TSS_log <- sum((subset$logPopBio - mean(subset$logPopBio))^2)
    TSS_not_log <- sum((subset$PopBio - mean(subset$PopBio))^2)
    
    # fit quadratic ----
    growth.quad <- lm(PopBio ~ I(Time)+I(Time^2), data = subset)
    # get model parameters
    quad.names <- c("a", "b", "c")
    df.quad <- get_params(growth.quad, quad.names, id, "Quadratic")
    # model selection values
    stats.quad <- get_stats(growth.quad, id, "Quadratic", TSS_not_log, n)
    
    
    # fit cubic ----
    growth.cubic <- lm(PopBio ~ I(Time)+I(Time^2)+I(Time^3), data = subset)
    # get model parameters
    cubic.names <- c("a", "b", "c", "d")
    df.cubic <- get_params(growth.cubic, cubic.names, id, "Cubic")
    # model selection values
    stats.cubic <- get_stats(growth.cubic, id, "Cubic", TSS_not_log, n)

    
    # Parameter sampling for non-linear logistic model ----
    # get slope estimate
    growth.straight <- lm(PopBio ~ Time, data = subset)
    # coef(growth.straight)
    
    N_0_est <- min(subset$PopBio)
    K_est <- max(subset$PopBio)
    r_max_est <- coef(growth.straight)[[2]]
    # r_max_est <- exp_slope_est
    
    params_try_log <- data_frame()
    for (i in 1:150) {
        
        starts_aic_l <- param_sample_logistic(subset, r_max_est, N_0_est, K_est, n)
        params_try_log <- rbind(params_try_log, starts_aic_l)
        
    }

    # fit logistic ----
    # get best starting values for coefficients (based on lowest AICc)
    lowest_aic_l <- min(params_try_log$AICc)
    best_starts_l <- params_try_log[params_try_log$AICc == lowest_aic_l,]
    if (nrow(best_starts_l) > 1) {
        best_starts_l <- best_starts_l[1,]
    } else if (nrow(best_starts_l) == 0) {  # if there are no best starts - still pass estimates to try for final fit! (rather than passing nothing!)
        best_starts_l <- data_frame(r_max_est, N_0_est, K_est)
        names(best_starts_l) <- c("r_max_start", "N_0_start", "K_start")
    }
    
    growth.log <- try_fit_logistic(subset, id, best_starts_l)
    # get model parameters
    log.names <- c("r_max", "N_0", "K")
    df.log <- get_params(growth.log, log.names, id, "Logistic")
    # model selection values
    stats.log <- get_stats(growth.log, id, "Logistic", TSS_not_log, n)

    
    
    #########################################################################################
    # log-transformed models
    
    # fit rolling OLS - to get max slope estimate ----
    roll_lm_log <- try(roll_regres(logPopBio ~ Time, data=subset, width=4), silent=T)
    # width = 4 is good value generally (for datasets w few values - most datasets!)- gets steepest line - but fails for some data
    if (class(roll_lm_log) == "try-error") {
        roll_lm_log <- try(roll_regres(logPopBio ~ Time, data=subset, width=5), silent=T)
    }
    if (class(roll_lm_log) == "try-error") {
        roll_lm_log <- try(roll_regres(logPopBio ~ Time, data=subset, width=6))
    }
    
    all_lines <- as.data.frame(roll_lm_log$coefs)
    # find slope and intercept of steepest line
    exp_slope_est_log <- max(all_lines$Time, na.rm=T)
    best_slope_log <- subset(all_lines, all_lines$Time == exp_slope_est_log)
    
    
    # Parameter sampling for log-tranformed non-linear models (Gompertz and Baranyi) ----
    N_0_est <- min(subset$logPopBio)
    K_est <- max(subset$logPopBio)
    r_max_est <- exp_slope_est_log
    
    t_lag_est = (N_0_est - best_slope_log[[1]]) / exp_slope_est_log
    
    params_try_gomp <- data_frame()
    params_try_baranyi <- data_frame()
    
    for (i in 1:70) {
        
        starts_aic_g <- param_sample_gompertz(subset, r_max_est, N_0_est, K_est, t_lag_est, n)
        params_try_gomp <- rbind(params_try_gomp, starts_aic_g)
        
        starts_aic_b <- param_sample_baranyi(subset, r_max_est, N_0_est, K_est, t_lag_est, n)
        params_try_baranyi <- rbind(params_try_baranyi, starts_aic_b)
        
    }
    
    
    # fit gompertz ----
    lowest_aic_g <- min(params_try_gomp$AICc)
    best_starts_g <- params_try_gomp[params_try_gomp$AICc == lowest_aic_g,]
    if (nrow(best_starts_g) > 1) {
        best_starts_g <- best_starts_g[1,]
    } 
    growth.gompertz <- try_fit_gompertz(subset, id, best_starts_g)
    # get model parameters
    gomp.names <- c("r_max", "K", "N_0", "t_lag")
    df.gomp <- get_params(growth.gompertz, gomp.names, id, "Gompertz")
    # model selection values
    stats.gomp <- get_stats(growth.gompertz, id, "Gompertz", TSS_log, n)
    

    # fit Baranyi ----
    lowest_aic_b <- min(params_try_baranyi$AICc)
    best_starts_b <- params_try_baranyi[params_try_baranyi$AICc == lowest_aic_b,]
    if (nrow(best_starts_b) > 1) {
        best_starts_b <- best_starts_b[1,]
    } 
    growth.baranyi <- try_fit_baranyi(subset, id, best_starts_b)
    # get model parameters
    baranyi.names <- c("r_max", "K", "N_0", "t_lag")
    df.baranyi <- get_params(growth.baranyi, baranyi.names, id, "Baranyi")
    # model selection values
    stats.baranyi <- get_stats(growth.baranyi, id, "Baranyi", TSS_log, n)
    

    # parameter values for all models
    coef_frame <- rbind(df.quad, df.cubic, df.log, df.gomp, df.baranyi)
    all_models <- rbind(all_models, coef_frame)
    
    # selection stats from all models
    selection_stats <- rbind(stats.quad, stats.cubic, stats.log, stats.gomp, stats.baranyi)
    all_stats <- rbind(all_stats, selection_stats)
    
}

write.csv(all_models, "../data/model_params_not_log.csv", row.names = FALSE)
write.csv(all_stats, "../data/selection_stats_not_log.csv", row.names = FALSE)


write.csv(all_models, "../data/model_params.csv", row.names = FALSE)
write.csv(all_stats, "../data/selection_stats.csv", row.names = FALSE)
