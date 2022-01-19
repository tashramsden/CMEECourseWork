# Author: Awesome Aardvarks
# Script: get_TreeHeight.R
# Desc: Takes a csv file name from the command line. 
#       Calculates heights of trees given distance of each tree 
#       from its base and angle to its top.
# Arguments: 3 (args: csv for analysis,
#               degrees:   The angle of elevation of tree,
#               distance:  The distance from base of tree (e.g., meters))
# Output: The heights of the tree, same units as "distance". Results saved to new csv file
# Date: Dec 2021

rm(list = ls())

#read data from command line
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) { 
  stop("Require input file", call.=FALSE)
} else if (length(args)==1) {
  readfile <- read.csv(args)
}

#calculate tree heights
TreeHeight <- function(degrees, distance){
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    return (height)
}

#add Tree Height column to readfile 
readfile$Tree.Height.m <- TreeHeight(readfile$Angle.degrees, readfile$Distance.m)

#save file without extension
name <- tools::file_path_sans_ext(basename(args))

#save all data to csv file in results/
write.csv(readfile, paste("../results/",name,"_treeheights.csv", sep=""), row.names=FALSE)