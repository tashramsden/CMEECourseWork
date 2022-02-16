## Tutorial 4 ----

rm(list=ls())
library(expm)

## Q3d ----

L <- matrix(c(-2, 1, 0, 0, 1, 0, 
              1, -3, 1, 0, 1, 0,
              0, 1, -2, 1, 0, 0,
              0, 0, 1, -3, 1, 1,
              1, 1, 0, 1, -3, 0,
              0, 0, 0, 1, 0, -1),
            6, 6, byrow=T)

# I <- matrix(c(1, 0, 0, 0, 0, 0,
#               0, 1, 0, 0, 0, 0,
#               0, 0, 1, 0, 0, 0,
#               0, 0, 0, 1, 0, 0, 
#               0, 0, 0, 0, 1, 0,
#               0, 0, 0, 0, 0, 1),
#             6, 6, byrow=T)


eigen <- eigen(L)
eigen_values <- eigen$values
eigen_values


## Q5b ----
y1 <- function(x) {
    return(3/4 - 1/2*x)
}
y2 <- function(x) {
    return(9/12 - 1/2*x)
}

x <- seq(-100, 100, 0.5)

plot(x, x, type="n")
lines(x, y1(x), col="red", lty=2)
lines(x, y2(x), col="blue", lty=3)


## 5c
y1 <- function(x, b1) {
    return(b1/4 - 1/2*x)
}
y2 <- function(x, b2) {
    return(b2/6 - 1/2*x)
}

x <- seq(-100, 100, 0.5)
b1 = 5
b2 = 100

plot(x, x, type="n")
lines(x, y1(x, b1), col="red", lty=2)
lines(x, y2(x, b2), col="blue", lty=3)


## Q7a ----

P <- matrix(c(0, 5, 3, 2, 1,
              0.9, 0, 0, 0, 0,
              0, 0.3, 0, 0, 0, 
              0, 0, 0.1, 0, 0, 
              0, 0, 0, 0.05, 0),
            5, 5, byrow=T)

p0 <- c(0, 0, 0, 0, 10)

time = 20
pt <- p0
tot_pop <- c(sum(p0))

for(t in 1:time) {
    pt <- pt %*% P
    tot_pop <- c(tot_pop, sum(pt))
}

pt

plot(x=seq(0, 20, 1), y=tot_pop, type="l")

plot(x=seq(0, 20, 1), y=log(tot_pop), type="l")


# part b 
# same but w diff starting pop:
p0_b <- c(80, 16, 5, 1, 1)

pt_b <- p0
tot_pop_b <- c(sum(p0))

for(t in 1:time) {
    pt_b <- pt_b %*% P
    tot_pop_b <- c(tot_pop_b, sum(pt_b))
}

pt

plot(x=seq(0, 20, 1), y=tot_pop_b, type="l")

plot(x=seq(0, 20, 1), y=log(tot_pop_b), type="l")

tot_pop_b

plot(x=seq(0, 20, 1), y=tot_pop, type="l", col="red")
lines(x=seq(0, 20, 1), y=tot_pop_b, type="l", col="blue")

plot(x=seq(0, 20, 1), y=log(tot_pop), type="l", col="red")
lines(x=seq(0, 20, 1), y=log(tot_pop_b), type="l", col="blue")



