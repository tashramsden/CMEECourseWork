################################################################
################## Wrangling the Pound Hill Dataset ############
################################################################

############# Load the dataset ###############
# header = false because the raw data don't have real headers
MyData <- as.matrix(read.csv("../data/PoundHillData.csv", header = FALSE))

# header = true because we do have metadata headers
MyMetaData <- read.csv("../data/PoundHillMetaData.csv", header = TRUE, 
                       sep = ";")

############# Inspect the dataset ###############
head(MyData)
dim(MyData)
str(MyData)
fix(MyData) #you can also do this
fix(MyMetaData)

############# Replace species absences with zeros ###############
MyData[MyData == ""] = 0

############# Transpose ###############
# To get those species into columns and treatments into rows 
MyData <- t(MyData) 
head(MyData)
dim(MyData)
# colnames(MyData)  # atm the headers are just row 1 - not treated as headers

############# Convert raw matrix to data frame ###############
TempData <- as.data.frame(MyData[-1,], stringsAsFactors = F) #stringsAsFactors 
# = F is important! (maybe not from R 4.0 onwards...)  # This creates dataframe 
# w just data, not col names (first row)

# head(TempData)
colnames(TempData) <- MyData[1,] # assign column names from original data
# head(TempData)

# row names remain - can just ignore them or remove:
rownames(TempData) <- NULL
# head(TempData)

############# Convert from wide to long format  ###############
require(reshape2) # load the reshape2 package - require() similar to library 
# but returns FALSE rather than error if package doesn't exist

# ?melt #check out the melt function

MyWrangledData <- melt(TempData, 
                       id=c("Cultivation", "Block", "Plot", "Quadrat"),
                       variable.name = "Species", value.name = "Count")
# head(MyWrangledData); tail(MyWrangledData)

## Now assign correct data types to each column
# Factors
MyWrangledData[, "Cultivation"] <- as.factor(MyWrangledData[, "Cultivation"])
MyWrangledData[, "Block"] <- as.factor(MyWrangledData[, "Block"])
MyWrangledData[, "Plot"] <- as.factor(MyWrangledData[, "Plot"])
MyWrangledData[, "Quadrat"] <- as.factor(MyWrangledData[, "Quadrat"])
# Int - count - num of species
MyWrangledData[, "Count"] <- as.integer(MyWrangledData[, "Count"])

str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)

############# Exploring the data (extend the script below)  ###############

require(tidyverse)
## shows conflicts - e.g. dplyr filter() - beacuse already func called filter,
# to use dplyr one use dplyr::filter()
tidyverse_packages(include_self = TRUE)  # the include_self = TRUE means 
# list "tidyverse" as well 

# convert dataframe to tibble
tibble::as_tibble(MyWrangledData)

dplyr::glimpse(MyWrangledData)  # like str(), but nicer!!!
# utils::View(MyWrangledData) #same as fix()

dplyr::filter(MyWrangledData, Count>100) #like subset(), but nicer!

dplyr::slice(MyWrangledData, 10:15) # Look at an arbitrary set of data rows
