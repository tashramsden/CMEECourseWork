####### Maths for biologists - tutorial 1 ----

rm(list=ls())

## Q3. ----
monod <- function(N, a, k) {
    return((a*N) / (k + N))
}

plot(seq(0, 75, by=7.5), seq(0, 10, by=1), type="n")
# i) a = 5, k = 1
lines(0:100, monod(N=0:100, a=5, k=1), col="red")
# ii) a = 5, k = 3
lines(0:100, monod(N=0:100, a=5, k=3), col="green")
# iii) a = 8, k = 1
lines(0:100, monod(N=0:100, a=8, k=1), col="blue")


## Q4. ----
f <- function(x, n, b) {
    return(x^n / (b^n + x^n))
}

# b = 2

plot(0:10, seq(0, 1, by=0.1), type="n")
# n=1
lines(0:10, f(x=0:10, n=1, b=2), col="green")
# n=2
lines(0:10, f(x=0:10, n=2, b=2), col="red")
# n=3
lines(0:10, f(x=0:10, n=3, b=2), col="blue")

## the same but for more vals of x
plot(0:100, seq(0, 1, by=0.01), type="n")
# n=1
lines(0:100, f(x=0:100, n=1, b=2), col="green")
# n=2
lines(0:100, f(x=0:100, n=2, b=2), col="red")
# n=3
lines(0:100, f(x=0:100, n=3, b=2), col="blue")

f(x=2, n=3, b=2)


## Q5. ----
moby <- read.csv("../data/words_moby_dick.csv", header=T)

X = moby$occurences
Y = moby$word_label
logX = log(moby$occurences)
logY = log(moby$word_label)

plot(logX, logY)

dY = (max(logY) - min(logY)) # -9.151
dX = (max(logX) - min(logX)) # 8.766

# estimate of D = dY/dX
dY/dX

# estimate D - know it's the slope = dY/dX:
poww1 <- function(x) {
    return(x^(-9.151 / 8.766))
}

plot(X, Y)
lines(seq(0.1, 6000, by=0.1), poww1(seq(0.1, 6000, 0.1)), col="red")


# better way - use lm to get ests of coef in front of x and of D - this looks much better

plot(logX, logY)
lm(logY ~ logX)

poww2 = function(x) {
    return(14415 * x^(-0.8774))
}

plot(X, Y)
lines(seq(0.1, 6000, by=0.1), poww2(seq(0.1, 6000, 0.1)), col="green")


## Q7 ----
zoop <- function(N0, r, t) {
    return(N0*(exp(r*t)))
}
dev.off()
plot(seq(0, 5, by=0.005), seq(0, 5000, by=5), type="n")
lines(0:5, zoop(N0=100, r=2, t=0:5), col="red")
lines(0:5, zoop(N0=100, r=3, t=0:5), col="green")


## Q8 ----
fish <- function(L_inf, k, x) {
    return(L_inf * (1 - exp(-k * x)))
}

plot(seq(0, 50, 1), seq(0, 25, 0.5), type="n")
lines(0:50, fish(L_inf = 20, k=1, x=0:50), col="green")
lines(0:50, fish(L_inf = 20, k=0.1, x=0:50), col="blue")


## Q9 ----

## a)
fa1 <- function(x) {
    return(exp(x))
}
fa2 <- function(x) {
    return(x^2)
}

plot(seq(0, 1000, 20), seq(0, 10000, 200), type="n")
lines(0:1000, fa1(0:1000), col="blue")
lines(0:1000, fa2(0:1000), col="red")

lines(0:1000, (fa1(0:1000)/fa2(0:1000)), col="green")

