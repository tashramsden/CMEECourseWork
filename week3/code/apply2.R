## Using the apply function with a newly defined function

## Takes each v as input, if sum of v is positive, 
# returns v w each item * 100
# otherwise returns v as it was
SomeOperation <- function(v) {
    if (sum(v) > 0) {
        return (v * 100)
    }
    return (v)
}

M <- matrix(rnorm(100), 10, 10)
print(apply(M, 1, SomeOperation))
