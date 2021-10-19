# A simple script to illustrate R input-output.

MyData <- read.csv("../data/trees.csv", header=TRUE)  # import with headers

write.csv(MyData, "../results/MyData.csv")  # write out as new file

write.table(MyData[1,], file = "../results/MyData.csv", append=TRUE)  # append to it

write.csv(MyData, "../results/MyData.csv", row.names=TRUE)  # write row names

write.table(MyData, "../results/MyData.csv", col.names=FALSE)  # ignore column names
