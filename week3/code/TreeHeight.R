# The function, TreeHeight, calculates heights of trees given distance of each tree 
# from its base and angle to its top, using the trigonometric formula 
#
# height = distance * tan(radians)
# 
# ARGUMENTS
# degrees: The angle of elevation of tree
# distance: The distance from base of tree (e.g. meters)
#
# OUTPUT
# The height of the tree, same units as "distance"

TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- as.numeric(distance * tan(radians))
    # print(paste("Tree height is:", height,"meters"))

    return (height)
}
# TreeHeight(41.28264, 31.66583)  # test first tree values  

all_trees <- read.csv("../data/trees.csv", header=TRUE)
# print(all_trees)

all_trees$Height.m <- TreeHeight(all_trees$Angle.degrees, all_trees$Distance.m)

write.csv(all_trees, "../results/TreeHts.csv", row.names=FALSE)
