#### Data import, exploration and preparation ----

rm(list = ls())
require(dplyr)

# Load data ----
# bacterial growth data
data <- read.csv("../data/LogisticGrowthData.csv")
print(paste("Loaded", length(colnames(data)), "columns."))

colnames(data)
# head(data)

# meta data 
meta <- read.csv("../data/LogisticGrowthMetaData.csv")
print(meta)

print(unique(data$PopBio_units))  # diff units of the response variable
# optical density 595nm, N, colony-forming units, dry weight (mg/ml)

print(unique(data$Time_units))  # independent variable units


# ID column ----
# create ID based on unique combos of species, medium, temp and citation
data$bad_ID <- paste(data$Species,"_",data$Temp,"_",data$Medium,"_",data$Citation,
                 sep="")
# change IDs to numbers
data <- data %>%
    mutate(ID = factor(bad_ID, levels = unique(bad_ID), 
                       labels = c(1:length(unique(bad_ID)))),
           .before = X) %>% 
    select(-bad_ID)
print(length(unique(data$ID)))  # num of unique data sets 

any(is.na(data))  # no NAs to remove


# Negative population/biomass values - PROBLEM: ----
# 1. will produce NAs for log(PopBio)
# 2. it doesn't make sense to have negative values!
min(data$PopBio)
all_neg_nums <- subset(data, data$PopBio < 0)
# mostly all v v slightly negative, ie > -0.01
# apart from one value: -668.2839 for one value in dataset ID = 89
# explore this further:

# data_subset <- subset(data, data$ID == 89)
# par(mfrow=c(1,1))
# plot(data_subset$Time, data_subset$PopBio)
# abline(h=0)

# looks like an outlier - v likely that the minus sign is a mistake!
# and from looking at original paper - doesn't appear to have this negative value
# units are N - cannot have -668 bacteria
data$PopBio[data$PopBio < -0.1] <- abs(data$PopBio[data$PopBio < -0.1])

# other negative values
min(data$PopBio)

# 2 negative values for ID 5 and one for ID 17
# ID 21 has lots of negative values - with a clear trend - taking absolute 
# values of these would result in a trend with the opposite slope

# 3 datasets with a value of 0 - need to avoid infinite values for log(0)

# negative nums - not take abs - get not orig trends
#               - could set as v small num - but then trend dictated by which num set - made up data!
#               -> REMOVE!!

# ZEROS  - could set as v small num - again trend would depend on num set 
#          -> REMOVE

# remove negative values and zeros - 25 rows
data <- data[!(data$PopBio <= 0),]
min(data$PopBio)


# Negative times ----
min(data$Time)
all_neg_times <- subset(data, data$Time < 0)

# remove negative times - improves model fitting
data <- data[!(data$Time < 0),]


# Log transformation ----
data$logPopBio <- log(data$PopBio)

any(is.na(data$logPopBio))  # no NAs to remove
any(is.infinite(data$logPopBio))  # and no infinite values


# Save cleaned data ----
write.csv(data, "../data/modified_growth_data.csv", row.names = FALSE)
