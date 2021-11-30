# Functions to fit the non-linear models with the best-guesses of starting values obtained during parameter sampling ----

# Logistic ----
try_fit_logistic <- function(subset, id, best_starts) {
    success_fit <- tryCatch(
        {
            N_0_start <- best_starts[["N_0_start"]]
            K_start <- best_starts[["K_start"]]
            r_max_start <- best_starts[["r_max_start"]]
            
            growth.log <- nlsLM(PopBio ~ logistic_model(t = Time, r_max, K, N_0),
                                data=subset,
                                list(r_max=r_max_start, N_0 = N_0_start, K = K_start))
            return(growth.log)
        },
        error=function(cond){
            message(paste("Logistic fit for dataset ID ",id," did not converge:\n", cond, sep=""))
            return(NULL)
        }
    )
    return(success_fit)
}

# Gompertz ----
try_fit_gompertz <- function(subset, id, best_starts) {
    success_fit <- tryCatch(
        {
            N_0_start <- best_starts[["N_0_start"]]
            K_start <- best_starts[["K_start"]]
            r_max_start <- best_starts[["r_max_start"]]
            t_lag_start <- best_starts[["t_lag_start"]]
            
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

# Baranyi ----
try_fit_baranyi <- function(subset, id, best_starts) {
    success_fit <- tryCatch(
        {
            N_0_start <- best_starts[["N_0_start"]]
            K_start <- best_starts[["K_start"]]
            r_max_start <- best_starts[["r_max_start"]]
            t_lag_start <- best_starts[["t_lag_start"]]
            
            growth.baranyi <- nlsLM(logPopBio ~ baranyi_model(t = Time, r_max, K, N_0, t_lag),
                                    data = subset,
                                    list(r_max=r_max_start, K = K_start, N_0 = N_0_start,
                                         t_lag = t_lag_start))
            return(growth.baranyi)
        },
        error=function(cond){
            message(paste("Baranyi fit for dataset ID ",id," did not converge:\n", cond, sep=""))
            return(NULL)
        }
    )
    return(success_fit)
}
