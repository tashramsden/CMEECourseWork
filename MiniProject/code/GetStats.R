## Calculate selection values (AICc, BIC, RSq etc) for all model fits ----
# 2 methods here - first calculating these values for all models in log space (ie transform predictions of not-log models into log space)
# and then for all models in not-log space (ie transforming predictions of log models into not-log space - exp)


# 1. Calculate for predictions ALL in LOG SPACE ----
# (ie transform predictions of models not in log space before calculating rss etc)

# Create data frame of model selection values - for models already applied to LOG (Gompertz, Baranyi)
get_stats_log <- function(fit_model, id, model_name, tss, n) {
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
    # R-squared
    RSq <- 1 - (rss/tss) 
    stats <- data_frame(id, n, p, aic, AICc, bic, RSq, model_name) 
    names(stats) <- stats_df_headers
    return(stats)
}


# Create data frame of model selection values - for models on NOT log-data - need 
# to calculate residuals in log space (quadratic, cubic and logistic)
get_stats_log_for_not_log_models <- function(fit_model, id, model_name, tss, n, predictions, subset, times) {
    if (is.null(fit_model)) {  # if no model fit - replace selection values w NA
        missing_stats <- rep(NA, length(stats_df_headers)-3)
        stats <- c(id, n, missing_stats, model_name)
        stats <- as.data.frame(t(stats))
        names(stats) <- stats_df_headers
        return(stats)
    }
    log_predictions <- log(predictions) # I'm aware of NAs here! - remove next
    
    prediction_df <- data_frame(times, predictions, log_predictions, subset$logPopBio)
    # remove any NA values (when prediction produced negative result)
    prediction_df <- prediction_df[!is.na(prediction_df$log_predictions),]
    
    residuals <- prediction_df$`subset$logPopBio` - prediction_df$log_predictions
    rss <- sum(residuals^2)
    
    # tss <- sum((prediction_df$`subset$logPopBio` - mean(prediction_df$`subset$logPopBio`))^2)  calculating manually here DOES give same result as tss passed in

    RSq <- 1 - (rss/tss) 
    
    p <- length(coef(fit_model))   # number of fitted coefficients
    
    aic <- n + 2 + n * log((2 * pi) / n) + n * log(rss) + 2 * p
    bic <- n + 2 + n * log((2 * pi) / n) + n * log(rss) + p * log(n)
    
    # small sample corrected aic
    AICc <- aic + (2*p * (p + 1)) / (n - p - 1)
    
    stats <- data_frame(id, n, p, aic, AICc, bic, RSq, model_name) 
    names(stats) <- stats_df_headers
    return(stats)
}


# 2. Calculate for predictions ALL NOT in LOG SPACE ----
# (ie transform predictions of models in log space before calculating rss etc)

# Create data frame of model selection values - for models already applied to non-transformed data (quadratic, cubic, logistic)
get_stats_not_log <- function(fit_model, id, model_name, tss, n) {
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
    
    # R-squared
    RSq <- 1 - (rss/tss) 
    
    stats <- data_frame(id, n, p, aic, AICc, bic, RSq, model_name) 
    names(stats) <- stats_df_headers
    return(stats)
}


# Create data frame of model selection values - for models on log-data - need 
# to calculate residuals in non-log space (Gompertz, Baranyi)
get_stats_not_log_for_log_models <- function(fit_model, id, model_name, tss, n, predictions, subset) {
    if (is.null(fit_model)) {  # if no model fit - replace selection values w NA
        missing_stats <- rep(NA, length(stats_df_headers)-3)
        stats <- c(id, n, missing_stats, model_name)
        stats <- as.data.frame(t(stats))
        names(stats) <- stats_df_headers
        return(stats)
    }
    
    # subset$logPopBio - log_predictions
    # not logged
    exp_pred <- exp(predictions)
    residuals <- subset$PopBio - exp_pred
    rss <- sum(residuals^2)
    
    RSq <- 1 - (rss/tss) 
    
    p <- length(coef(fit_model))   # number of fitted coefficients
    
    aic <- n + 2 + n * log((2 * pi) / n) + n * log(rss) + 2 * p
    bic <- n + 2 + n * log((2 * pi) / n) + n * log(rss) + p * log(n)
    
    # small sample corrected aic
    AICc <- aic + (2*p * (p + 1)) / (n - p - 1)
    
    stats <- data_frame(id, n, p, aic, AICc, bic, RSq, model_name) 
    names(stats) <- stats_df_headers
    return(stats)
}
