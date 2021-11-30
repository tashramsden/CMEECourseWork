# Define non-linear model functions ----

# Logistic 
logistic_model <- function(t, r_max, K, N_0) {
    return(N_0 * K * exp(r_max * t)/(K + N_0 * (exp(r_max * t) - 1)))
}


# Gompertz
# NOTE this is in log scale log(Nt) = equation
gompertz_model <- function(t, r_max, K, N_0, t_lag) { # Modified gompertz growth model (Zwietering, 1990)
    return(N_0 + (K - N_0) * exp(-exp(r_max * exp(1) * (t_lag - t)/((K - N_0) * log(10)) + 1)))
} 


# Baranyi
# NOTE this is in log scale log(Nt) = equation
baranyi_model <- function(t, r_max, K, N_0, t_lag) {  # Baranyi model (Grijspeerdt and Vanrolleghem, 1999)
    v = r_max
    m = 1
    # t_lag = h_0 / r_max
    h_0 = t_lag * r_max
    B = t + (1/r_max) * log(exp(-v*t) + exp(-h_0) - exp((-v*t)-h_0))  # separate out part of equation which is repeated
    return(N_0 + r_max*B - (1/m)*log(1 + ((exp(m*r_max*B) - 1) / exp(m*(K - N_0)))))
} 


# # Buchanan (three-phase linear model)
# buchanan_model <- function(t, r_max, K, N_0, t_lag) {  # Buchanan model (Buchanan et al, 1997)
#     # during exponential growth
#     Nt = N_0 + r_max*(t - t_lag)
#     # during lag phase
#     Nt[t < t_lag] = Nt = N_0
#     # once K reached (during stationary phase)
#     Nt[Nt > K] = K
#     return(Nt)
# }

