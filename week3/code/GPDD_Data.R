## Mapping the Global Population Dynamics Database (GPDD)
# a freely available database developed at Silwood
# Living Planet Index based on this!

# maps package
require(maps)
require(tidyverse)

# load GPDD Rdata
load("../data/GPDDFiltered.RData")
head(gpdd)
dplyr::glimpse(gpdd)

pdf("../sandbox/GPDD_map.pdf", 8, 10)
# create world map
maps::map(database = "world", fill=TRUE, col="lightgrey", border="darkgray",
    bg = "lightblue", xlim = c(-180, 180), ylim = c(-90, 90), wrap=c(-180,180))
# add species from gpdd
points(x = gpdd$long, y = gpdd$lat, col=alpha("darkgreen", 0.6), lwd=2)
dev.off()

## There is a strong sampling bias towards the UK and North America 
# (especially the West coast). The rest of the world is largely unsampled; 
# these data should not be considered to be representative of the whole world. 
# The word "Global" in the name of the database is misleading.
