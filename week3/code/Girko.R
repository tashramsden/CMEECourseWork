## Girko's circular law:
# the eigenvalues of a matrix M of size N x N are approxiamately contained
# in a circle in the complex plane w radius sqrt(N) 

# Aim: draw results of a simulation displaying this result:

require(ggplot2)

# first build function to calculate the ellipse (predicted bounds of eigenvalues)
build_ellipse <- function(hradius, vradius) {  # returns an ellipse
    npoints = 250
    a <- seq(0, 2 * pi, length = npoints + 1)
    x <- hradius * cos(a)
    y <- vradius * sin(a)
    return(data.frame(x = x, y = y))
}

N <- 250  # assign size of matrix
M <- matrix(rnorm(N * N), N, N)  # build matrix

eigvals <- eigen(M)$values  # find eigenvalues
eigDF <- data.frame("Real" = Re(eigvals), "Imaginary" = Im(eigvals))  # build data frame

my_radius <- sqrt(N)  # radius of the circle is sqrt(N)

ellDF <- build_ellipse(my_radius, my_radius)  # data frame to plot the ellipse
names(ellDF) <- c("Real", "Imaginary")  # rename columns

# plot it
p <- ggplot(eigDF, aes(x = Real, y = Imaginary)) +
    geom_point(shape = I(3)) +
    # add vertical and horizontal lines
    geom_hline(aes(yintercept = 0)) +
    geom_vline(aes(xintercept = 0)) +
    # add the ellipse
    geom_polygon(data = ellDF, 
                 aes(x = Real, y = Imaginary, alpha = 1/20, fill = "red")) +
    theme_bw() +
    theme(legend.position = "none")
p

## Saving plot
pdf("../results/Girko.pdf", 5, 5)
print(p)
dev.off()
