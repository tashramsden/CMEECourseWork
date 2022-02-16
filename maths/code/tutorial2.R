## Tutorial 2 ----

rm(list=ls())


## Q1 - Lotka volterra ----

x <- function(t, R, omega, phi) {
    return(R*cos(omega*t - phi))
}

y <- function(t, R, omega, phi) {
    return(R*sin(omega*t - phi))
}

t <- seq(0, 8, 0.5)

plot(seq(0, 8, 0.5), seq(-1, 1, 0.125), type="n")

lines(t, x(t, R=1, omega=pi/4, phi=pi/4), col="green")
lines(t, y(t, R=1, omega=pi/4, phi=pi/4), col="red")

# x(0, 1, pi/4, pi/4)
# x(1, 1, pi/4, pi/4)
# x(2, 1, pi/4, pi/4)
# x(3, 1, pi/4, pi/4)
# x(4, 1, pi/4, pi/4)
# x(5, 1, pi/4, pi/4)
# x(6, 1, pi/4, pi/4)
# x(7, 1, pi/4, pi/4)
# x(8, 1, pi/4, pi/4)
# 
# y(0, 1, pi/4, pi/4)
# y(1, 1, pi/4, pi/4)
# y(2, 1, pi/4, pi/4)
# y(3, 1, pi/4, pi/4)
# y(4, 1, pi/4, pi/4)
# y(5, 1, pi/4, pi/4)
# y(6, 1, pi/4, pi/4)
# y(7, 1, pi/4, pi/4)
# y(8, 1, pi/4, pi/4)


## changing the phase, phi = translation - shift horizontally
lines(t, x(t, R=1, omega=pi/4, phi=pi), col="blue")
lines(t, y(t, R=1, omega=pi/4, phi=pi), col="black")

# chaning sign of phi
plot(seq(0, 8, 0.5), seq(-1, 1, 0.125), type="n")

lines(t, x(t, R=1, omega=pi/4, phi=pi/4), col="green")
lines(t, y(t, R=1, omega=pi/4, phi=pi/4), col="red")

lines(t, x(t, R=1, omega=pi/4, phi=-pi/4), col="blue")
lines(t, y(t, R=1, omega=pi/4, phi=-pi/4), col="black")


# x vs y
plot(seq(-1, 1, 0.125), seq(-1, 1, 0.125), type="n")
lines(x(t, R=1, omega=pi/4, phi=pi/4), y(t, R=1, omega=pi/4, phi=pi/4), col="green")


# CHANGING OMEGA
plot(seq(0, 8, 0.5), seq(-1, 1, 0.125), type="n")

# orig
lines(t, x(t, R=1, omega=pi/4, phi=pi/4), col="green")
lines(t, y(t, R=1, omega=pi/4, phi=pi/4), col="red")

# now w omega twice as big == twice as many oscillations/time
lines(t, x(t, R=1, omega=pi/2, phi=pi/4), col="blue")
lines(t, y(t, R=1, omega=pi/2, phi=pi/4), col="black")


# omega = pi/2, phi = 0
plot(seq(0, 8, 0.5), seq(-1, 1, 0.125), type="n")
lines(t, x(t, R=1, omega=pi/2, phi=0), col="green")
lines(t, y(t, R=1, omega=pi/2, phi=0), col="red")

cos(pi/4)
sin(-pi/4)
