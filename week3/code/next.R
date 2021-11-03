# The 'next' statement in R

# prints odd numbers up to 10
for (i in 1:10) {
    if ((i %% 2) == 0)  # check if number odd
        next  # skip to next iteration
    print(i)
}
