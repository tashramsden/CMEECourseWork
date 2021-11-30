# Functions for searching parameter space for the coefficients of the non-linear models ----

# Logistic
param_sample_logistic <- function(subset, r_max_est, N_0_est, K_est, n) {
    success_fit <- tryCatch(
        {
            r_max_start = rnorm(1, r_max_est, abs(r_max_est*3))
            N_0_start = rnorm(1, N_0_est, abs(N_0_est*3))
            K_start = rnorm(1, K_est, abs(K_est*3))
            
            growth.log <- nlsLM(PopBio ~ logistic_model(t = Time, r_max, K, N_0), 
                                data=subset,
                                list(r_max=r_max_start, N_0 = N_0_start, K = K_start))
            aic <- AIC(growth.log)
            p = 3
            AICc <- aic + (2*p * (p + 1)) / (n - p - 1)
            
            starts_aic <- data_frame(r_max_start, N_0_start, K_start, AICc)
            names(starts_aic) <- c("r_max_start", "N_0_start", "K_start", "AICc")
            return(starts_aic)
        },
        error=function(cond){
            return(NULL)
        }
    )
    return(success_fit)
}


# Gompertz
param_sample_gompertz <- function(subset, r_max_est, N_0_est, K_est, t_lag_est, n) {
    success_fit <- tryCatch(
        {
            r_max_start = rnorm(1, r_max_est, abs(r_max_est*2))
            N_0_start = rnorm(1, N_0_est, abs(N_0_est*2))
            K_start = rnorm(1, K_est, abs(K_est*2))
            t_lag_start = rnorm(1, t_lag_est, abs(t_lag_est*2))
            
            growth.gompertz <- nlsLM(logPopBio ~ gompertz_model(t = Time, r_max, K, N_0, t_lag),
                                     data = subset,
                                     list(r_max=r_max_start, K = K_start, N_0 = N_0_start,
                                          t_lag = t_lag_start))
            aic <- AIC(growth.gompertz)
            p = 4
            AICc <- aic + (2*p * (p + 1)) / (n - p - 1)
            
            starts_aic <- data_frame(r_max_start, N_0_start, K_start, t_lag_start, AICc)
            names(starts_aic) <- c("r_max_start", "N_0_start", "K_start", "t_lag_start", "AICc")
            return(starts_aic)
        },
        error=function(cond){
            return(NULL)
        }
    )
    return(success_fit)
}


# Baranyi
param_sample_baranyi <- function(subset, r_max_est, N_0_est, K_est, t_lag_est, n) {
    success_fit <- tryCatch(
        {
            r_max_start = rnorm(1, r_max_est, abs(r_max_est*2))
            N_0_start = rnorm(1, N_0_est, abs(N_0_est*2))
            K_start = rnorm(1, K_est, abs(K_est*2))
            t_lag_start = rnorm(1, t_lag_est, abs(t_lag_est*2))
            
            growth.baranyi <- nlsLM(logPopBio ~ baranyi_model(t = Time, r_max, K, N_0, t_lag),
                                    data = subset,
                                    list(r_max=r_max_start, K = K_start, N_0 = N_0_start,
                                         t_lag = t_lag_start))
            aic <- AIC(growth.baranyi)
            p = 4
            AICc <- aic + (2*p * (p + 1)) / (n - p - 1)
            
            starts_aic <- data_frame(r_max_start, N_0_start, K_start, t_lag_start, AICc)
            names(starts_aic) <- c("r_max_start", "N_0_start", "K_start", "t_lag_start", "AICc")
            return(starts_aic)
        },
        error=function(cond){
            return(NULL)
        }
    )
    return(success_fit)
}
