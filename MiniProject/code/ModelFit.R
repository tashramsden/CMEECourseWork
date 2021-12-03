#### Model fitting and comparison ----

rm(list = ls())

library(rollRegres)
library(minpack.lm)
library(dplyr)
# library(nlstools)  # for inspecting residuals

data <- read.csv("../data/modified_growth_data.csv")

set.seed(12345)

source("DefineModels.R")
source("ParamSampling.R")
source("TryFinalFits.R")
source("GetStats.R")


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

all_models <- data.frame()
all_stats_log <- data.frame()
all_stats_not_log <- data.frame()


for (id in unique(data$ID)) {
    
    subset <- subset(data, data$ID == id)
    
    n <- length(subset$logPopBio)  # sample size
    # Total sum of squares - pass this to get_stats() for each model for calculating Rsq
    TSS_not_log <- sum((subset$PopBio - mean(subset$PopBio))^2)
    TSS_log <- sum((subset$logPopBio - mean(subset$logPopBio))^2)
    
    # fit quadratic ----
    growth.quad <- lm(PopBio ~ I(Time)+I(Time^2), data = subset)
    # get model parameters
    quad.names <- c("a", "b", "c")
    df.quad <- get_params(growth.quad, quad.names, id, "Quadratic")
    
    # pdf(paste("../sandbox/residuals/ID", id,"_quad.pdf", sep=""), 6, 6)
    # par(mfrow=c(2,2))
    # plot(growth.quad)
    # dev.off()
    
    
    # model selection values
    times = subset$Time
    pred.quad <- coef(growth.quad)[[1]] + coef(growth.quad)[[2]]*times + coef(growth.quad)[[3]]*(times^2)
    # in log space
    stats.quad_log <- get_stats_log_for_not_log_models(growth.quad, id, "Quadratic", TSS_log, 
                                           n, pred.quad, subset, times)
    # in not log space
    stats.quad_not_log <- get_stats_not_log(growth.quad, id, "Quadratic", TSS_not_log, n)
    
    
    # fit cubic ----
    growth.cubic <- lm(PopBio ~ I(Time)+I(Time^2)+I(Time^3), data = subset)
    # get model parameters
    cubic.names <- c("a", "b", "c", "d")
    df.cubic <- get_params(growth.cubic, cubic.names, id, "Cubic")
    
    # model selection values
    pred.cubic <- coef(growth.cubic)[[1]] + coef(growth.cubic)[[2]]*times + 
        coef(growth.cubic)[[3]]*(times^2) + coef(growth.cubic)[[4]]*(times^3)
    # in log space
    stats.cubic_log <- get_stats_log_for_not_log_models(growth.cubic, id, "Cubic", TSS_log, 
                                           n, pred.cubic, subset, times)
    # in not log space
    stats.cubic_not_log <- get_stats_not_log(growth.cubic, id, "Cubic", TSS_not_log, n)

    # pdf(paste("../sandbox/residuals/ID", id,"_cubic.pdf", sep=""), 6, 6)
    # par(mfrow=c(2,2))
    # plot(growth.cubic)
    # dev.off()
    
    
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
    
    # res <- try(nlsResiduals(growth.log), silent=T)
    # pdf(paste("../sandbox/residuals/ID", id,"_logistic.pdf", sep=""), 6, 6)
    # try(plot(res, which=0), silent=T)
    # dev.off()

    # get model parameters
    log.names <- c("r_max", "N_0", "K")
    df.log <- get_params(growth.log, log.names, id, "Logistic")
    
    # model selection values
    # in log space
    if (is.null(growth.log)) {
        stats.log_log <- get_stats_log_for_not_log_models(growth.log, id, "Logistic", TSS_log, n)  # will just make df w NULLs
    } else {
        pred.log <- logistic_model(t = times, r_max = coef(growth.log)[["r_max"]], 
                               K = coef(growth.log)[["K"]],
                               N_0 = coef(growth.log)[["N_0"]])

        stats.log_log <- get_stats_log_for_not_log_models(growth.log, id, "Logistic", TSS_log, 
                                            n, pred.log, subset, times)
    }
    # not in log space
    stats.log_not_log <- get_stats_not_log(growth.log, id, "Logistic", TSS_not_log, n)
    
    
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
    
    # res <- try(nlsResiduals(growth.gompertz), silent=T)
    # pdf(paste("../sandbox/residuals/ID", id,"_gompertz.pdf", sep=""), 6, 6)
    # try(plot(res, which=0), silent=T)
    # dev.off()
    
    gomp.names <- c("r_max", "K", "N_0", "t_lag")
    df.gomp <- get_params(growth.gompertz, gomp.names, id, "Gompertz")

    # model selection values ----
    # in log space
    stats.gomp_log <- get_stats_log(growth.gompertz, id, "Gompertz", TSS_log, n)
    
    # not in log space
    pred.gomp <- gompertz_model(t = times, r_max = coef(growth.gompertz)[["r_max"]], 
                                K = coef(growth.gompertz)[["K"]], 
                                N_0 = coef(growth.gompertz)[["N_0"]], 
                                t_lag = coef(growth.gompertz)[["t_lag"]])
    stats.gomp_not_log <- get_stats_not_log_for_log_models(growth.gompertz, id, "Gompertz", TSS_not_log,
                                          n, pred.gomp, subset)



    # fit Baranyi ----
    lowest_aic_b <- min(params_try_baranyi$AICc)
    best_starts_b <- params_try_baranyi[params_try_baranyi$AICc == lowest_aic_b,]
    if (nrow(best_starts_b) > 1) {
        best_starts_b <- best_starts_b[1,]
    } 
    growth.baranyi <- try_fit_baranyi(subset, id, best_starts_b)
    
    # res <- try(nlsResiduals(growth.baranyi), silent=T)
    # pdf(paste("../sandbox/residuals/ID", id,"_baranyi.pdf", sep=""), 6, 6)
    # try(plot(res, which=0), silent=T)
    # dev.off()
    
    # get model parameters
    baranyi.names <- c("r_max", "K", "N_0", "t_lag")
    df.baranyi <- get_params(growth.baranyi, baranyi.names, id, "Baranyi")
    
    # model selection values ----
    # in log space
    stats.baranyi_log <- get_stats_log(growth.baranyi, id, "Baranyi", TSS_log, n)
    
    # not in log space
    pred.baranyi <- baranyi_model(t = times, r_max = coef(growth.baranyi)[["r_max"]],
                                  K = coef(growth.baranyi)[["K"]],
                                  N_0 = coef(growth.baranyi)[["N_0"]],
                                  t_lag = coef(growth.baranyi)[["t_lag"]])
    stats.baranyi_not_log <- get_stats_not_log_for_log_models(growth.baranyi, id, "Baranyi", TSS_not_log,
                                             n, pred.baranyi, subset)
    
    
    # parameter values for all models
    coef_frame <- rbind(df.quad, df.cubic, df.log, df.gomp, df.baranyi)
    all_models <- rbind(all_models, coef_frame)
    
    # selection stats from all models
    selection_stats_log <- rbind(stats.quad_log, stats.cubic_log, stats.log_log, stats.gomp_log, stats.baranyi_log)
    all_stats_log <- rbind(all_stats_log, selection_stats_log)
    
    selection_stats_not_log <- rbind(stats.quad_not_log, stats.cubic_not_log, stats.log_not_log, stats.gomp_not_log, stats.baranyi_not_log)
    all_stats_not_log <- rbind(all_stats_not_log, selection_stats_not_log)
    
}


write.csv(all_models, "../data/model_params.csv", row.names = FALSE)
write.csv(all_stats_log, "../data/selection_stats_log_space.csv", row.names = FALSE)
write.csv(all_stats_not_log, "../data/selection_stats_not_log_space.csv", row.names = FALSE)

