#### Model fitting and comparison ----

rm(list = ls())

data <- read.csv("../data/modified_growth_data.csv")

set.seed(12345)


logistic_model <- function(t, r_max, K, N_0) {
    return(N_0 * K * exp(r_max * t)/(K + N_0 * (exp(r_max * t) - 1)))
}


# NOTE this is in log scale log(Nt) = equation
gompertz_model <- function(t, r_max, K, N_0, t_lag) { # Modified gompertz growth model (Zwietering 1990)
    return(N_0 + (K - N_0) * exp(-exp(r_max * exp(1) * (t_lag - t)/((K - N_0) * log(10)) + 1)))
} 


# try_fit_logistic <- function(subset, id, r_max_est) {
#     success_fit <- tryCatch(
#         {
#             # starting params
#             N_0_start <- min(subset$logPopBio) # log
#             K_start <- max(subset$logPopBio)
#             # r_max_start <- max(diff(subset$logPopBio))/2  # steepest part of curve.... better to try to find steepest aprt of curve do lm etc....
#             r_max_start <- r_max_est
#             
#             growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0), 
#                                 data=subset,
#                                 list(r_max=r_max_start, N_0 = N_0_start, K = K_start))
#             
#             return(growth.log)
#         },
#         error=function(cond){
#             message(paste("Logistic fit for dataset ID ",id," did not converge:\n", cond, sep=""))
#             return(NULL)
#         }
#     )
#     return(success_fit)
# }



try_fit_gompertz <- function(subset, id, r_max_est) {
    success_fit <- tryCatch(
        {
            # starting params
            N_0_start <- min(subset$logPopBio)
            K_start <- max(subset$logPopBio)
            r_max_start <- r_max_est
            
            t_lag_start <- subset$Time[which.max(diff(diff(subset$logPopBio)))]  # last timepoint of lag phase - not v robust...
            
            growth.gompertz <- nlsLM(logPopBio ~ gompertz_model(t = Time, r_max, K, N_0, t_lag),
                                     data = subset,
                                     list(r_max=r_max_start, K = K_start, N_0 = N_0_start,
                                          t_lag = t_lag_start))

            return(growth.gompertz)
        },
        error=function(cond){
            message(paste("Gompertz fit for dataset ID ",id," did not converge:\n", cond, sep=""))
            return(NULL)
        }
    )
    return(success_fit)
}



param_select_logistic <- function(subset, r_max_start, N_0_start, K_start) {
    success_fit <- tryCatch(
        {
            growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0), 
                                data=subset,
                                list(r_max=r_max_start, N_0 = N_0_start, K = K_start))
            
            aic <- AIC(growth.log)
            
            starts_aic <- data_frame(r_max_start, N_0_start, K_start, aic)
            names(starts_aic) <- c("r_max_start", "N_0_start", "K_start", "AIC")
            
            return(starts_aic)
            
        },
        error=function(cond){
            # message(paste("Logistic fit did not converge:\n", cond))
            return(NULL)
        }
    )
    return(success_fit)
}



# Headers for data frames of model parameters and model selection values
param_df_headers <- c("Param.name", "Param.value", "ID", "model")
stats_df_headers <- c("ID", "Sample.size", "Model.params", "AIC", "AICc", "BIC", "SSE", "RSq", "model")


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
    
    if (is.null(fit_model)) {
        missing_stats <- rep(NA, length(stats_df_headers)-3)
        stats <- c(id, n, missing_stats, model_name)
        stats <- as.data.frame(t(stats))
        names(stats) <- stats_df_headers
        return(stats)
    }
    
    aic <- AIC(fit_model)
    bic <- BIC(fit_model)
    
    # sums of squared errors
    m <- length(coef(fit_model))   # m = number of fitted coefficients
    sse <- signif(sum(resid(fit_model)^2)/(n-2 * m), 3)
    
    # Residual sum of squares
    rss <- sum(residuals(fit_model)^2)
    
    # R-squared
    RSq <- 1 - (rss/tss) 
    
    # small sample (corrected) aic
    p <- m
    # gives same as inbuilt - thankfully!
    # aic_self <- n + 2 + n * log((2 * pi) / n) + n * log(rss) + 2 * p
    AICc <- aic + (2*p * (p + 1)) / (n - p - 1)
    
    #### INCLUDE N AND P IN DATA FRAME --- USEFUL FOR INTERPRETING!!!!!!
    stats <- data_frame(id, n, p, aic, AICc, bic, sse, RSq, model_name)  # etc....!
    
    names(stats) <- stats_df_headers
    
    return(stats)
}


all_models <- data.frame()
all_stats <- data.frame()


for (id in unique(data$ID)) {
# for (id in 1:1) {
    
    subset <- subset(data, data$ID == id)
    # subset <- subset(data, data$ID == 95)
    
    n <- length(subset$logPopBio)

    # Total sum of squares - pass this to get_stats() for each model
    TSS <- sum((subset$logPopBio - mean(subset$logPopBio))^2)
    
    
    # fit straight line ----
    growth.straight <- lm(logPopBio ~ Time, data = subset)
    # summary(growth.straight)
    # get model parameters
    lin.names <- c("Intercept", "Slope")
    df.lin <- get_params(growth.straight, lin.names, id, "Straight line")
    # get selection values
    stats.lin <- get_stats(growth.straight, id, "Straight line", TSS, n)
    
    
    # fit quadratic ----
    growth.quad <- lm(logPopBio ~ I(Time)+I(Time^2), data = subset)
    # summary(growth.quad)
    # get model parameters
    quad.names <- c("a", "b", "c")
    df.quad <- get_params(growth.quad, quad.names, id, "Quadratic")
    # model selection values
    stats.quad <- get_stats(growth.quad, id, "Quadratic", TSS, n)
    
    
    # fit cubic ----
    growth.cubic <- lm(logPopBio ~ I(Time)+I(Time^2)+I(Time^3), data = subset)
    # summary(growth.cubic)
    # get model parameters
    cubic.names <- c("a", "b", "c", "d")
    df.cubic <- get_params(growth.cubic, cubic.names, id, "Cubic")
    # model selection values
    stats.cubic <- get_stats(growth.cubic, id, "Cubic", TSS, n)

    
    # fit logistic ----
    # start with estimate of r max based on slope of the straight lm
    r_max_est <- df.lin$Param.value[df.lin$Param.name == "Slope"]

    # parameter sampling
    N_0_starts <- rnorm(100, min(subset$logPopBio), 0.2)
    K_starts <- rnorm(100, max(subset$logPopBio), 0.2)
    r_max_starts <- rnorm(100, r_max_est, 0.2)
    
    params_try <- data_frame()
    
    for (i in 1:length(N_0_starts)) {
        N_0_start <- N_0_starts[i]
        K_start <- K_starts[i]
        r_max_start <- r_max_starts[i]
        # try to fit the logistic model with the starting params
        starts_aic <- param_select_logistic(subset, r_max_start, N_0_start, K_start)
        # save starting vals and their aic if successful fit
        params_try <- rbind(params_try, starts_aic)
    }
    
    # identify starting values which resulted in minimal aic and use for final fit
    lowest_aic <- min(params_try$AIC)
    best_starts <- params_try[params_try$AIC == lowest_aic,]
    if (nrow(best_starts) > 1) {
        best_starts <- best_starts[1,]
    }
    
    N_0_start <- best_starts[["N_0_start"]]
    K_start <- best_starts[["K_start"]]
    r_max_start <- best_starts[["r_max_start"]]
    
    growth.log <- nlsLM(logPopBio ~ logistic_model(t = Time, r_max, K, N_0),
                        data=subset,
                        list(r_max=r_max_start, N_0 = N_0_start, K = K_start))
    # summary(growth.log)
    # coef(growth.log)
    
    # growth.log <- try_fit_logistic(subset, id, r_max_estimate)
    
    # get model parameters
    log.names <- c("r_max", "N_0", "K")
    df.log <- get_params(growth.log, log.names, id, "Logistic")
    # model selection values
    stats.log <- get_stats(growth.log, id, "Logistic", TSS, n)

    
    
    
    # fit Gompertz ----
    
    # N_0_est <- min(subset$logPopBio)
    # K_est <- max(subset$logPopBio)
    r_max_est <- df.lin$Param.value[df.lin$Param.name == "Slope"]
    
    # t_lag_start <- subset$Time[which.max(diff(diff(subset$logPopBio)))]  # last timepoint of lag phase - not v robust...
    
    growth.gompertz <- try_fit_gompertz(subset, id, r_max_est)
    # growth.gompertz <- nlsLM(logPopBio ~ gompertz_model(t = Time, r_max, K, N_0, t_lag),
    #                          data = subset,
    #                          list(r_max=r_max_start, K = K_start, N_0 = N_0_start,
    #                               t_lag = t_lag_start))
    # # 
    # 
    # summary(growth.gompertz)
    # coef(growth.gompertz)
    
    ### HERE
    # get model parameters
    gomp.names <- c("r_max", "K", "N_0", "t_lag")
    df.gomp <- get_params(growth.gompertz, gomp.names, id, "Gompertz")
    # model selection values
    stats.gomp <- get_stats(growth.gompertz, id, "Gompertz", TSS, n)
    
    
    
    
    # parameter values for all models
    coef_frame <- rbind(df.lin, df.quad, df.cubic, df.log, df.gomp)
    all_models <- rbind(all_models, coef_frame)
    
    # selection stats from all models
    selection_stats <- rbind(stats.lin, stats.quad, stats.cubic, stats.log, stats.gomp)
    all_stats <- rbind(all_stats, selection_stats)
    
}


write.csv(all_models, "../data/model_params2.csv", row.names = FALSE)
write.csv(all_stats, "../data/selection_stats2.csv", row.names = FALSE)






### exploring selection vals.....

all_stats$ID <- as.factor(all_stats$ID)

# aic
ggplot(all_stats, aes(x = ID, y = AIC, col = model)) +
    geom_point() +
    theme_bw()

# aic_table <- data.frame(all_stats$ID, all_stats$AIC, min(all_stats$AIC) - all_stats$AIC, all_stats$model)


lowest_aic <- c()
for (id in unique(all_stats$ID)) {
    dataset <- subset(all_stats, all_stats$ID == id)
    # print(paste("For ID", id))
    smallest_aic <- dataset$model[dataset$AIC == min(dataset$AIC)]
    lowest_aic <- c(lowest_aic, smallest_aic)
    

}
# print(lowest_aic)
unique(lowest_aic)

lowest_aic <- as.factor(lowest_aic)
table(lowest_aic)




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


# install.packages("AICcmodavg")
# library(AICcmodavg)


# all_aic <- data.frame()
# for (id in unique(all_stats$ID)) {
#     
#     subset <- subset(all_stats, all_stats$ID == id)
#     
#     cube_quad <- subset$AIC[subset$model == "Cubic"] - subset$AIC[subset$model == "Quadratic"]
#     cube_lin <- subset$AIC[subset$model == "Cubic"] - subset$AIC[subset$model == "Straight line"]
#     
#     aic_diffs <- c(cube_quad, cube_lin)
#     comparison <- c("Cubic - Quadratic", "Cubic - Straight line")
#     
#     aic <- data.frame(id, aic_diffs, comparison)
#     
#     all_aic <- rbind(all_aic, aic)
#     
# }
# 
# ggplot(all_aic, aes(x = id, y = aic_diffs, col=comparison)) +
#     geom_point()
# 
# 
# subset <- subset(all_stats, all_stats$ID == 1)









