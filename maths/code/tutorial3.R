## Tutorial 3 - matrices and systems of equations ----

rm(list=ls())
library(expm)  # for matrix exponentiation


## Q2c ----

y1 <- function(x) {
    return(2*x - 0.5)
}

y2 <- function(x) {
    return(2*x + 2)
}

x <- seq(-10, 10, 0.5)


plot(x, x, type="n")
lines(x, y1(x), col="red")
lines(x, y2(x), col="blue")


## Q3 ----

M <- matrix(c(2/3, 1/2, 1/3, 1/2), 2, 2, byrow=T)

## part b
p0 <- c(1, 0)

p1 <- M%*%p0

p2 <- M %*% M %*% p0
p2a <- (M %^% 2) %*% p0  # this does same as above

p3 <- (M %^% 3) %*% p0

p100 <- (M %^% 100) %*% p0


## part c
p0 <- c(0, 1)

p1 <- M%*%p0
p2 <- (M %^% 2) %*% p0 
p3 <- (M %^% 3) %*% p0
p100 <- (M %^% 100) %*% p0


## part e 
p0 <- c(3/5, 2/5)

p1 <- M%*%p0
p2 <- (M %^% 2) %*% p0 
p3 <- (M %^% 3) %*% p0
p100 <- (M %^% 100) %*% p0

# ratio
p2/p1
p3/p2

## part f
v <- c(-1, 1)

p1 <- M %*% v
p2 <- (M %^% 2) %*% v
p3 <- (M %^% 3) %*% v
p100 <- (M %^% 100) %*% v

p2/p1
p3/p2

# print(p1)
# print(p2)
# print(p3)
# print(p100)


## part g

pt <- function(t) {
    e1 <- c(3/5, 2/5)
    e2 <- c(-1, 1)
    lambda1 <- 1
    lambda2 <- 1/6
    gamma <- -2/5
    return(e1*(lambda1^t) + gamma*(e2*(lambda2^t)))
}

p1 <- pt(1)
p2 <- pt(2)
p3 <- pt(3)
p100 <- pt(100)
## give same results as section b


## Q3i ----

L <- matrix(c(0.23,0.25,0.02,0.23,0.27,0.05,0.35,0.03,0.55,0.02,0.22,0.32,0.17,0.18,0.11,0.26,0.25,0.30,0.07,0.12,0.01,0.34,0.13,0.30,0.22), 5, 5, byrow=F)

# sum of p0 elems = 1
p0 <- c(1/5, 1/5, 1/5, 1/5, 1/5)
# p0 <- c(2/5, 0, 3/5, 0, 0)

# p0<-t(t(p0)) # not needed - making sure it's a COLUMN vector

pstar <- function(n) {
    return((L %^% n) %*% p0)
}

pstar(n=100)
# gives leading eigenvector (relative ranks of each wbepage)

# should get same values (ranks) regardless of p0 and of n

# ranks:
# guardian.co.uk    0.16
# google.co.uk      0.30
# nature.com        0.14
# bbc.co.uk         0.28
# imperial.ac.uk    0.12

# woohoo!
