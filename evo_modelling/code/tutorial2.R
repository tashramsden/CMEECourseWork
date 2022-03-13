## Evo modelling

# Tutorial Q2ai)
tau <- function(x0, N) {
    return(-2*N*(x0*log(x0) + (1-x0)*log(1-x0)))
}
x0 <- seq(0, 1, 0.05)

N=100

plot(x0, tau(x0, N=N)/(2*N), type="l",
     xlab="x0", ylab="tau / 2N")


# Q2b)

N <- seq(100, 10^8, 10000)

x0 = 0.01
plot(log(N), log(tau(x0=x0, N=N)), type="l",
     ylab="log(tau)")

x0 = 0.1
lines(log(N), log(tau(x0=x0, N=N)), col="red")

x0 = 0.5
lines(log(N), log(tau(x0=x0, N=N)), col="blue")


