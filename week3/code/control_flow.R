## Control flow tools in R

#########################################

## 1. if statements
a <- TRUE
if (a == TRUE) {
    print("a is TRUE")
    } else {
        print("a is FALSE")
}

## on a single line - BUT readability more important
z <- runif(1)  # generate a random number from uniformly distributed 
if (z <= 0.5) {print ("Less than a half")}

#########################################

## 2. for loops
for (i in 1:10) {  # or seq(10)
    j <- i * i
    print(paste(i, " squared is", j))
}

## loop over vector of strings
for(species in c("Heliodoxa rubinoides", 
                 "Boissonneaua jardini", 
                 "Sula nebouxii")) {
    print(paste("The species is", species))
}

## loop using pre-existing vector
v1 <- c("a", "bc", "def")
for (i in v1) {
    print(i)
}

#########################################

## 3. while loops
i <- 0
while (i < 10) {
    i <- i + 1
    print(i^2)
}
