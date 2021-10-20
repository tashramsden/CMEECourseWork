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

# TreeHeight(41.28264, 31.66583)

all_trees <- read.csv("../data/trees.csv", header=TRUE)

# print(all_trees)
# print(all_trees[1,][3])
# nrow(all_trees)

heights <- vector()

for (index in 1:nrow(all_trees)) {  # find num of rows in all_trees
    row = all_trees[index,]  # get hold of each row
    dist <- row[2]
    angle <- row[3]
    # print(paste("dist:", dist, "angle:", angle))

    height <- TreeHeight(angle, dist)
    # print(height)

    heights <- c(heights, height)

}

# print(heights)

all_trees_height <- all_trees
all_trees_height$Height.m <- heights
# all_trees_height

write.csv(all_trees_height, "../results/TreeHts.csv", row.names=FALSE)
