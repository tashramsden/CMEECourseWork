################################################################
################## Wrangling the Pound Hill Dataset ############
################################################################
# rm(list = ls())

require(tidyverse)

############# Load the dataset ###############
# header = false because the raw data don't have real headers
MyData <- as.matrix(read.csv("../data/PoundHillData.csv", header = FALSE))

# header = true because we do have metadata headers
MyMetaData <- read.csv("../data/PoundHillMetaData.csv", header = TRUE, 
                       sep = ";")

############# Inspect the dataset ###############
dplyr::glimpse(MyData)
utils::View(MyData) #same as fix()
head(MyData)
dim(MyData)
dplyr::glimpse(MyMetaData)
utils::View(MyMetaData)

############# Replace species absences with zeros ###############
MyData <- na_if(MyData, "") %>% replace_na(0)

############# Transpose and convert to data frame ###############
MyData <- as_tibble(t(MyData))

dim(MyData)
class(MyData)

############# Assign headers and remove row names ###############
MyData <- MyData %>% 
    set_names(slice_head(MyData))
MyData <- slice(MyData, -1)

rownames(MyData) <- NULL

############# Convert from wide to long format  ###############
## gather() from tidyr, depreciating...
# MyWrangledData <- tidyr::gather(MyData, key=Species, value=Count, 
#                                 -c(Cultivation, Block, Plot, Quadrat))
## more recent:
MyWrangledData <- pivot_longer(MyData,
                               # all columns apart from these are species:
                               cols = -c(Cultivation, Block, Plot, Quadrat),
                               names_to = "Species",
                               values_to = "Count")

############# Assign correct data types to each variable ###############
MyWrangledData <- MyWrangledData %>% 
    # species as factor too
    mutate(across(c(Cultivation, Block, Plot, Quadrat, Species), factor))
MyWrangledData$Count <- as.integer(MyWrangledData$Count)

# length(levels(MyWrangledData$Species))  # 41 different species
glimpse(MyWrangledData)
head(MyWrangledData); tail(MyWrangledData)
dim(MyWrangledData)
utils::View(MyWrangledData)

############# Exploring the data (extend the script below)  ###############
tidyverse_packages(include_self = TRUE)

tibble::as_tibble(MyWrangledData)  # convert dataframe to tibble

dplyr::glimpse(MyWrangledData)  # like str(), but nicer!!!

dplyr::filter(MyWrangledData, Count>100) #like subset(), but nicer!

dplyr::slice(MyWrangledData, 10:15) # Look at an arbitrary set of data rows
