# CMEE 2021 HPC excercises R code HPC run code pro forma

rm(list=ls()) # good practice 
# dev.off()
source("ter21_HPC_2021_main.R")

# personal speciation rate:
my_speciation_rate <- 0.0021818

iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

# FOR TESTING LOCALLY
# iter <- 3

set.seed(iter)

# 25 runs for each community size (500, 1000, 2500, 5000)
if (1 <= iter & iter <= 25) {
    comm_size = 500
} else if (26 <= iter & iter <= 50) {
    comm_size = 1000
} else if (51 <= iter & iter <= 75) {
    comm_size = 2500
} else if (76 <= iter & iter <= 100) {
    comm_size = 5000
}

file_name = paste("simulation_", iter, ".rda", sep="")

cluster_run(speciation_rate = my_speciation_rate,
            size = comm_size, 
            wall_time = (11.5 * 60),  # 11.5 hours
            interval_rich = 1,
            interval_oct = comm_size / 10, 
            burn_in_generations = 8 * comm_size,
            output_file_name = file_name)
