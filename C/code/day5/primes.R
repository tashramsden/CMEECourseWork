## Function for counting the prime numbers between 1 and the given limit
count.primes.R <- function(limit) {
    prime = 1
    n_prime = 2 # Counting 2 as the first prime

    while (prime < limit)
    {
        is_prime = 0

        for(divisor in 2:(prime/2))
        {
            if(prime %% divisor == 0)
            {
                is_prime = 1
                break
            }
        }

        if (is_prime == 0) {
            n_prime <- n_prime + 1
        }

        prime <- prime + 1
    }

    return(n_prime)
}

time_R <- system.time(results_R <- count.primes.R(10000))
print(paste("Time taken in R:", round(time_R[[3]], 3)))
# increase to 100000 and it takes muuuch longer, 40secs
# increase to 1000000 - would just take forever!!!

# Compared to the same but in C:

## Loading the compiled function
dyn.load("primes.so")

## Bench marking the speed of this function
time_C <- system.time(results_C <- .C("count_primes_C", 
                                       limit = as.integer(10000), 
                                       n_primes = as.integer(0)))
print(paste("Time taken in C:", round(time_C[[3]], 3)))


## Did both functions returned the same values?
results_C$n_primes == results_R ## I want a TRUE!

## What was the actual time difference?
time_R[[3]] / time_C[[3]] ## C is that many times faster!

if (results_C$n_primes == results_R) {
    print(paste("It took", round(time_R[[3]] / time_C[[3]], 3), "times as long for R to reach the same answer as C"))
}

# increase num of primes counted, even to 1000000 only takes 40secs!!!
# time_C <- system.time(results_C <- .C("count_primes_C", 
#                                       limit = as.integer(1000000), 
#                                       n_primes = as.integer(0)))
# print(paste("Time taken in C:", round(time_C[[3]], 3)))
