### Tutorial 6 ----

## 3a ----

y <- function(theta) {
    return(sin(theta) / theta)
}

x <- seq(-10, 10, 0.1)
plot(x, y(seq(-10, 10, 0.1)))


## 3b ----

y <- function(N, s) {
    return((1 - exp(-2*s)) / (1 - exp(-2*s*N)))
}


s <- seq(0.001, 0.1, 0.001)

N = 100
plot(s, log(y(N, s)), type="l")
# plot(s, y(N, s), type="l")

N = 10
lines(s, log(y(N, s)), col="red")
# lines(s, y(N, s), col="red")


## Q3ciii

y <- function(s) {
    return(log(1 + s))
}

s <- seq(-0.5, 0.5, 0.0001)

plot(s, y(s), type="l", ylab="ln(1+s)")
# the approximation works well when s << 1, ie ln(1+s) IS ~~ s


## Q3 d iv

sinh <- function(theta) {
    return(1/2 * (exp(theta) - exp(-theta)))
}

theta <- seq(0, 3, 0.001)

plot(theta, sinh(theta) - sin(theta), type="l")
lines(theta, theta^3/3, col="red")
# when theta is small - its a good approximation

