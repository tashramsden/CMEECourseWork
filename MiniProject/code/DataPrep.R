#### Data import, exploration and preparation ----

rm(list = ls())
require(dplyr)


# Load data ----
# bacterial growth data
data <- read.csv("../data/LogisticGrowthData.csv")
print(paste("Loaded", length(colnames(data)), "columns."))

colnames(data)

head(data)


# meta data 
meta <- read.csv("../data/LogisticGrowthMetaData.csv")
print(meta)


print(unique(data$PopBio_units))  # diff units of the response variable
# optical density 595nm, N, colony-forming units, dry weight (mg/ml)

print(unique(data$Time_units))  # independent variable units


# ID column ----
# no ID column - need to create one based on unique combos of species, medium, 
# temp and citation
data$bad_ID <- paste(data$Species,"_",data$Temp,"_",data$Medium,"_",data$Citation,
                 sep="")

# change IDs to numbers!
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
data_subset <- subset(data, data$ID == 89) 
par(mfrow=c(1,1))
plot(data_subset$Time, data_subset$PopBio)
abline(h=0)
# looks like an outlier - v likely that the minus sign is a mistake!
# and from looking at original paper - doesn't appear to have this negative value
# units are N - cannot have -668 bacteria
data$PopBio[data$PopBio < -0.1] <- abs(data$PopBio[data$PopBio < -0.1])

# fixed!
data_subset <- subset(data, data$ID == 89) 
par(mfrow=c(1,1))
plot(data_subset$Time, data_subset$PopBio)
abline(h=0)

# other negative values
min(data$PopBio)

# 2 negative values for ID 5 and one for ID 17
# ID 21 has lots of negative values - with a clear trend - taking absolute 
# values of these would result in a trend with the opposite slope

# 3 datasets with a value of 0 - need to avoid infinite values for log(0)

# negative nums - not take abs - get not orig trends
#               - could set as v small num - but then trend dictated by which num set - made up data!
#               - REMOVE!!

# ZEROS  - could set as v small num - again trend would depend on num set 
#          - REMOVE

zeros <- subset(data, data$PopBio == 0) #NOT USED - DELETE LATER!!!!!!!!!!!!!!!!!!!!!!!!!!!

# remove negative values and zeros - 25 rows
data <- data[!(data$PopBio <= 0),]

# data$PopBio[data$PopBio <= 0] <- 0.0001
min(data$PopBio)



# Negative times ----

min(data$Time)  # definitely doesn't have any meaning!
all_neg_times <- subset(data, data$Time < 0)

big_neg_times <- subset(data, data$Time < -0.1)

# options:
# remove
# set to 0
# ignore..! (but negative time doesn't make sense - maybe it does, eg ID 210 has -25hrs as first point - this because plates inoculated w one bact 25 hrs before starting "official" counting...!)
# shift data along so that all start at 0

# keep thinking/come back and plot diff options...!


# Log transformation ----
data$logPopBio <- log(data$PopBio)

any(is.na(data$logPopBio))  # no NAs to remove
any(is.infinite(data$logPopBio))  # and no infinite values


# Save cleaned data ----
write.csv(data, "../data/modified_growth_data.csv", row.names = FALSE)






##################################


unique(data$Species)
unique(data$Temp)


# explore PopBio units a bit
unique(data$PopBio_units)

op_dens <- subset(data, data$PopBio_units == "OD_595")
Num <- subset(data, data$PopBio_units == "N")
CFU <- subset(data, data$PopBio_units == "CFU")
dryweight <- subset(data, data$PopBio_units == "DryWeight")


# Optical Density 595nm
hist(op_dens$PopBio)  # between ~0 and 1 ish
min(op_dens$PopBio)


# N - count or cells/ml 
hist(Num$PopBio)
min(Num$PopBio)
max(Num$PopBio)
# BIG range in numbers
mean(Num$PopBio)
# 3 spp w especially high numbers...
ggplot(Num, aes(x=Species, y=log(PopBio))) +
    geom_violin()
# one medium w especially high nums
ggplot(Num, aes(x=Medium, y=log(PopBio))) +
    geom_violin()

length(unique(Num$Citation))

# explore negative values
neg_nums <- subset(Num, Num$PopBio < 0)



# Colony Forming Units
hist(CFU$PopBio)
min(CFU$PopBio)
max(CFU$PopBio)
# again, BIG range in values
# one spp w especially high values - but I think due to diff in medium NOT spp! (see below)
ggplot(CFU, aes(x=Species, y=log(PopBio))) +
    geom_violin()
# one medium much higher than others - ATP broth
ggplot(CFU, aes(x=Medium, y=log(PopBio))) +
    geom_violin()

# just comparing the 2 labelled as Pseudomonas sp. or spp. can see that big 
# diffs in numbers seems to be down to medium - only get those v v high nums w ATP broth
# also these are from diff studies so the diff could be down to some other sampling diff...!
psuedo_cfu <- subset(CFU, CFU$Species == "Pseudomonas sp." | CFU$Species == "Pseudomonas spp.")
ggplot(psuedo_cfu, aes(x=Species, y=log(PopBio), color=Medium)) +
    geom_jitter()


# Dry weight (units unclear - check ref!)
hist(dryweight$PopBio)
min(dryweight$PopBio)
max(dryweight$PopBio)
# uniform ish distribution between 1 and 6 mg/ml





### DATA TRANFORMATION????!

##### COME BACK TO THIS - ARE THERE ANY ~ACTUAL~ PROBLEMATIC VALUES THAT ~NEED~ REMOVING?! - eg clear errors etc
### prob comment below out!
data_subset <- subset(data, data$ID == 89)  
# try diff IDs, eg 5 looks v weird..! - v small nums for OD - big fluctuations - 
# prob will never get a fit for this - actually just a strightish flat line - didn't ever grow
head(data_subset)

par(mfrow=c(1,1))
plot(data_subset$Time, data_subset$PopBio)
abline(h=0)

plot(data_subset$X, data_subset$Time)
range(data_subset$Time)
plot(data_subset$Time, data_subset$PopBio)

ggplot(data_subset, aes(Time, PopBio, color=ID)) +
    geom_point()

data_subset2 <- subset(data, data$Citation == "Bae, Y.M., Zheng, L., Hyun, J.E., Jung, K.S., Heu, S. and Lee, S.Y., 2014. Growth characteristics and biofilm formation of various spoilage bacteria isolated from fresh produce. Journal of food science, 79(10), pp.M2072-M2080.")

require(ggplot2)
ggplot(data_subset2, aes(Time, PopBio, color=Species)) +
    geom_point()


subset_more <- subset(data_subset2, data$Species=="Pantoea.agglomerans.2")

ggplot(subset_more, aes(Time, PopBio, color=ID)) +
    geom_point()


unique(data_subset2$ID)

hist(data$Time)
hist(data$PopBio)
hist(data$Temp)
hist(data$Rep)
