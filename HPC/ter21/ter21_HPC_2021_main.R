# CMEE 2021 HPC excercises R code main pro forma
# you don't HAVE to use this but it will be very helpful.  If you opt to write everything yourself from scratch please ensure you use EXACTLY the same function and parameter names and beware that you may loose marks if it doesn't work properly because of not using the proforma.

name <- "Natasha Ramsden"
preferred_name <- "Tash"
email <- "ter21@ic.ac.uk"
username <- "ter21"

require(ggplot2)

# please remember *not* to clear the workspace here, or anywhere in this file. If you do, it'll wipe out your username information that you entered just above, and when you use this file as a 'toolbox' as intended it'll also wipe away everything you're doing outside of the toolbox.  For example, it would wipe away any automarking code that may be running and that would be annoying!


# Question 1
species_richness <- function(community){
  spp_rich <- length(unique(community))  # num of diff spp in a community, ie spp richness
  return(spp_rich)
}

# Question 2
init_community_max <- function(size){
  max_comm <- seq(size)  # max richness = every indiv of diff spp
  return(max_comm)
}

# Question 3
init_community_min <- function(size){
  min_comm <- rep(1, size)  # min richness = all indivs same spp
  return(min_comm)
}

# Question 4
choose_two <- function(max_value){
  choose_vec <- c(1:max_value)
  two_nums <- sample(choose_vec, 2, replace=FALSE)
  return(two_nums)
}

# Question 5
neutral_step <- function(community){
  indices <- choose_two(length(community))  # choose two indivs at random from the community
  indiv_dies <- indices[1]
  indiv_repro <- indices[2]
  community[indiv_dies] <- community[indiv_repro]  # one indiv will die and be replaced by the offspring of another
  return(community)
}

# Question 6
# generation = amount of time expected between birth and repro
# generation = x/2 where x = num of indivs in community
# if x not even - choose at random to round up/down
# eg 10 indivs -> 5 neutral steps (5 births, 5 deaths) = one generation
neutral_generation <- function(community){
  # get gen length = x/2 (round up or down randomly if not even num)
  gen_length <- round(length(community)/2 + sample(c(0, -0.1), 1))  # sample+0 will round up, sample-0.1 will round down if x/2 = *.5, if x/2 whole number will still round to correct num
  for (step in 1:gen_length) {
    community <- neutral_step(community)
  }
  return(community)
}

# Question 7
neutral_time_series <- function(community,duration)  {
  time_series_richness <- c()
  # carry out neutral theory simulation and return species richness time series
  for (gen in 1:duration) {
    spp_rich <- species_richness(community)
    time_series_richness <- c(time_series_richness, spp_rich)
    community <- neutral_generation(community)
  }
  return(time_series_richness)
}

# Question 8
question_8 <- function() {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  spp_rich_time_series <- neutral_time_series(community = init_community_max(100), duration=200)

  par(mar=c(5,5,3,2), mfrow=c(1,1), bty = "l")  # bty so that plot not in a box
  plot(x=1:length(spp_rich_time_series), y = spp_rich_time_series, type="l", lwd=2,
       xlab="Time in generations", ylab="Species richness",
       main="Neutral Model Without Speciation")
  
  return("The system always converges to a point where species richness is equal to 1. Species richness cannot increase as there is no speciation, but species can be lost through extinction. Extinct species cannot re-enter the population so, due to the stochasticity of the system, the community will eventually randomly lose all species but one.")
}

# Question 9
neutral_step_speciation <- function(community,speciation_rate) {
  indices <- choose_two(length(community))
  indiv_dies <- indices[1]
  
  # speciation will replace the dead indiv with a new spp w probability speciation_rate
  # otherwise dead indiv replaced w offspring of another as before
  chance <- runif(1,0,1) # get one number between 0 and 1
  if (chance <= speciation_rate) {  # speciation
    # new species must not already be in set - get max value + 1 (definitely not in the pop)
    new_spp <- max(community) + 1
    community[indiv_dies] <- new_spp
  } else {  # replaced by offspring of another indiv
    indiv_repro <- indices[2]
    community[indiv_dies] <- community[indiv_repro]
  }
  return(community)
}

# Question 10
neutral_generation_speciation <- function(community,speciation_rate)  {
  gen_length <- round(length(community)/2 + sample(c(0, -0.1), 1))  # sample+0 will round up, sample-0.1 will round down if x/2 = *.5, if x/2 whole number will still round to correct num
  for (step in 1:gen_length) {
    community <- neutral_step_speciation(community, speciation_rate)
  }
  return(community)
}

# Question 11
neutral_time_series_speciation <- function(community,speciation_rate,duration)  {
  time_series_richness <- c()
  for (gen in 1:duration) {
    spp_rich <- species_richness(community)
    time_series_richness <- c(time_series_richness, spp_rich)
    community <- neutral_generation_speciation(community, speciation_rate)
  }
  return(time_series_richness)
}

# Question 12
question_12 <- function()  {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  # species richness time series from neutral theroy w speciation simulation
  spp_rich_time_series_min <- neutral_time_series_speciation(community=init_community_min(100), 
                                                             duration=200,
                                                             speciation_rate=0.1)
  spp_rich_time_series_max <- neutral_time_series_speciation(community=init_community_max(100), 
                                                             duration=200,
                                                             speciation_rate=0.1)
  
  par(mar=c(5,5,3,2), mfrow=c(1,1), bty = "l") 
  plot(x=1:length(spp_rich_time_series_min), y = spp_rich_time_series_min, 
       type="l", lwd=2, col="orange", ylim=c(0, 100),
       xlab="Time in generations", ylab="Species richness",
       main="Neutral Model With Speciation (speciation rate = 0.1)")
  lines(x=1:length(spp_rich_time_series_max), y = spp_rich_time_series_max, 
        lwd=2, col="cyan")
  legend("topright", inset=0.05, title="Initial community state", 
         legend=c("Minimum richness", "Maximum richness"), 
         col=c("orange", "cyan"),
         lwd=2, box.lty=0)
  
  return("Different communities simulated by the neutral model that have equal rates of speciation will reach the same dynamic equilibrium as eachother, regardless of their initial state of richness. The initial richness has no impact as the chances of extinction and speciation are the same in both populations, these factors balance eachother once the community is in dynamic equilibrium. The value of species richness at equilibrium depends on the values of speciation rate and exitinction rate.")
}

# Question 13
species_abundance <- function(community)  {
  abundance <- as.numeric(sort(table(community), decreasing=TRUE))
  # returns abundance of each spp in a community
  return(abundance)
}

# Question 14
octaves <- function(abundance_vector) {
  bins <- rep(0, 1, floor(log2(max(abundance_vector)))+1)  # vector of 0s for num of bins needed
  for (abundance in abundance_vector) {
    # nth value in bins should contain any spp whose abundance is >= 2**n-1
    # so get which bin each abundance value should be in like:
    bin <- floor(log2(abundance)) + 1
    # and add one to the value of that bin:
    bins[bin] <- bins[bin] + 1
  }
  # returns abundance of spp binned into octave classes
  return(bins)
}

# Question 15
# will want to get average of octaves as simulations stochastic
# num of bins not always the same, so when adding for averaging need to 
# account for diff length vectors:
sum_vect <- function(x, y) {
  if (length(x) < length(y)) {
    long_vect <- y
    short_vect <- x
  } else if (length(y) < length(x)) {
    long_vect <- x
    short_vect <- y
  } else {
    return(x + y)
  }
  diff <- length(long_vect) - length(short_vect)
  short_vect <- c(short_vect, rep(0, diff))
  return(short_vect + long_vect)
}


# function to calculate mean abundance octaves for a given starting community (for q16)
calculate_mean_abund <- function(community, spec_rate) {
  
  NUM_REPEATS = 101 #  num to divide running total by (one at end of burn in, further 100 during rest of simulation)
  
  # "burn in" period
  for (gen in 1:200) {
    community <- neutral_generation_speciation(community=community,
                                               speciation_rate = spec_rate)
  }
  # first calculation of abund octave after burn-in
  abundance_octaves <- octaves(species_abundance(community))

  for (gen in 1:2000) {
    community <- neutral_generation_speciation(community=community,
                                               speciation_rate = spec_rate)

    # every 20 generations, calculate abundance octave again:
    if (gen %% 20 == 0) {
      next_abund_octave <- octaves(species_abundance(community))
      # add each new octave to the running total
      abundance_octaves <- sum_vect(abundance_octaves, next_abund_octave)
    }
    
  }
  # divide total sum of octaves by num of repeats to get average for each bar
  abundance_octaves_mean <- abundance_octaves / NUM_REPEATS
  
  return(abundance_octaves_mean)
}


# returns a data frame for plotting - of mean octaves and bins (with bin names and init richness/init size category)
# (for q16 and 20 and challenge D)
get_abund_df <- function(octaves_vector, grouping_factor_name, grouping_factor) {  
  # grouping factor is initial richness for q16 and community size for q20 and challenge D
 
  # numerical bins (lower bound - used to order bars in barplot)
  bins <- c(2**seq(0, length.out=length(octaves_vector)))
  
  # names for x axis
  bin_names_lower <- bins
  bin_names_upper <- c(2**seq(1, length.out=length(octaves_vector))-1)
  
  bin_names <- c(paste(bin_names_lower, "-", bin_names_upper, sep=" "))
  bin_names[1] <- "1"
  
  # data frame for plotting
  abund_df <- data.frame(octaves_vector)
  abund_df$octave <- bins
  abund_df$octave_labels <- bin_names
  abund_df$group <- grouping_factor
  names(abund_df) <- c("abundance", "octave", "bin_labels", grouping_factor_name)
  
  return(abund_df)
}


# Question 16
question_16 <- function()  {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  speciation_rate = 0.1
  
  # initialise communities
  min_community <- init_community_min(100)
  max_community <- init_community_max(100)

  # calculate abundance octaves
  octaves_min <- calculate_mean_abund(min_community, speciation_rate)
  octaves_max <- calculate_mean_abund(max_community, speciation_rate)
  
  # get data frames of octaves and bins for plotting
  df_min <- get_abund_df(octaves_min, "init_rich", "Minimum richness")
  df_max <- get_abund_df(octaves_max, "init_rich", "Maximum richness")
  
  df_both <- rbind(df_min, df_max)

  p <- ggplot(df_both, aes(x=reorder(bin_labels, octave), y=abundance, fill=init_rich)) +  # order the bins by octave (numeric) but show the bin labels
    geom_bar(stat="identity", position=position_dodge()) +
    labs(title="Species Abundance Distribution", 
         x="Number of Individuals per Species",
         y="Mean Number of Species",
         fill="Initial Community State") +
    theme_classic() +
    theme(legend.position = c(0.8,0.8), 
          plot.title = element_text(hjust = 0.5),
          text = element_text(size=14),
          plot.margin = margin(0.5, 1.5, 0.5, 0.5, "cm")) +
    scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))  # integers for y axis
  show(p)
  
  return("The initial richness of the system does not matter; different communities simulated by the neutral model that have equal rates of speciation will reach the same dynamic equilibrium as eachother, regardless of their initial state of richness. By chance individual species appear and go extinct and their abundances fluctuate over time, but overall the distribution of species abundances in the community has the same shape regardless of initial richness since speciation rate and extinction rate are the same in both populations.")
}

# Question 17
cluster_run <- function(speciation_rate, size, wall_time, interval_rich, 
                        interval_oct, burn_in_generations, output_file_name)  {
    
    start <- proc.time()[[3]]  # start timer - function will run until wall_time has elapsed
  
    community <- init_community_min(size)

    gen = 1
    time_series <- c()  # spp richness time series during the burn in period
    abund_octaves <- list()  # spp abundance octaves after the burn-in
    
    while (proc.time()[[3]] - start <= wall_time*60) {
      
        community <- neutral_generation_speciation(community, speciation_rate)
        
        # during burn-in period calculate spp richness at intervals of interval_rich
        if (gen <= burn_in_generations & gen %% interval_rich == 0) {
          spp_richness <- species_richness(community)
          time_series <- c(time_series, spp_richness)
        }
        
        # record spp abundance octaves at intervals of interval_oct after 
        # the burn in period (once dynamic equilib reached)
        if (gen > burn_in_generations & gen %% interval_oct == 0) {
          abundance_octave <- octaves(species_abundance(community))
          abund_octaves <- c(abund_octaves, list(abundance_octave))
        }
        
        gen <- gen + 1

    }

    total_time <- (proc.time()[[3]] - start)/60  # total time taken in minutes
    save(time_series, abund_octaves, community, total_time, speciation_rate, 
         size, wall_time, interval_rich, interval_oct, burn_in_generations,
         file = output_file_name)
    return(paste(output_file_name, "done!", sep=" "))
}

# Questions 18 and 19 involve writing code elsewhere to run your simulations on the cluster

# Question 20 
process_cluster_results <- function()  {
  combined_results <- list() #create your list output here to return
  # save results to an .rda file
  
  simulation <- 1
  community_sizes <- c(500, 1000, 2500, 5000)
  
  for (diff_size in community_sizes) {
    
    print(paste("size=",diff_size))
    # running total of octaves for each community size
    abund_octaves_runnning_total <- c()
    total_to_divide_by <- 0
    
    # for each simulation of each community size (25 each)
    for (i in 1:25) {

      print(paste("simulation",simulation))
      
      load(paste("simulation_", simulation, ".rda", sep=""))
      
      for (octave in abund_octaves) {
        abund_octaves_runnning_total <- sum_vect(abund_octaves_runnning_total, octave)
      }
      
      total_to_divide_by <- total_to_divide_by + length(abund_octaves)
      
      simulation <- simulation + 1
      
    }
    
    mean_octave <- abund_octaves_runnning_total / total_to_divide_by
    combined_results <- c(combined_results, list(mean_octave))
    
  }
  
  
  # create dataframe for plotting - same format as q16
  df_for_plotting <- data.frame()
  
  for (i in 1:4) {  # for each diff community size
    size <- community_sizes[i]
    vector <- combined_results[[i]]
    
    # make a data frame of mean abund octave in bins etc for each initial community size
    df_octave <- get_abund_df(vector,
                              grouping_factor_name = "comm_size", 
                              grouping_factor = size)
    
    df_for_plotting <- rbind(df_for_plotting, df_octave)
  }
  
  # for facets
  df_for_plotting$comm_size <- factor(df_for_plotting$comm_size,
                                      labels=c("Community size = 500", 
                                               "Community size = 1000",
                                               "Community size = 2500", 
                                               "Community size = 5000"))
  
  save(combined_results, df_for_plotting, file="cluster_abund_results.rda")
}


plot_cluster_results <- function()  {
    # clear any existing graphs and plot your graph within the R window
    dev.off()
  
    # load combined_results from your rda file
    load("cluster_abund_results.rda")
  
    # plot the graphs
    p <- ggplot(df_for_plotting, aes(x=reorder(bin_labels, octave), y=abundance, fill=comm_size)) +
      geom_bar(stat="identity") + 
      labs(title="Species Abundance Distributions",
        x="Number of Individuals per Species",
        y="Mean Number of Species",
        fill="Community size") +
      theme_classic() +
      facet_wrap(~comm_size, scales="free") +
      theme(legend.position = "none",
            plot.title = element_text(hjust = 0.5),
            text = element_text(size=14),
            strip.background = element_blank(),
            axis.text.x = element_text(angle=-50, vjust=0.5, hjust=0),
            plot.margin = margin(0.5, 1.5, 0.5, 0.5, "cm"),) +
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))  # integers for y axis
    show(p)
    
    return(combined_results)
}


# Question 21
question_21 <- function()  {
  num_dimensions = log(8) / log(3)
  explanation = "In order to create an object which is three times the size of the original, you would need 8 times the amount of material. So 8 = 3^x where x is the number of dimensions; and therefore the number of dimensions will be log(8)/log(3)."
  return(paste("Number of dimensions:", round(num_dimensions,3), "Explanation:", explanation, sep="  "))
}

# Question 22
question_22 <- function()  {
  num_dimensions = log(20) / log(3)
  explanation = "In order to create an object 3 times the size of the original, 20 times the material would be needed. So 20 = 3^x and therefore x dimensions = log(20)/log(3)."
  return(paste("Number of dimensions:", round(num_dimensions,3), "Explanation:", explanation, sep="  "))
  
}

# Question 23
chaos_game <- function()  {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  # points of the Sierpinski gasket outer triangle
  A <- c(0,0)
  B <- c(3,4)
  C <- c(4,1)
  coords <- list(A, B, C)
  
  X <- c(0,0)  # start position
  
  # empty plot
  par(mfrow=c(1,1), mar=c(3,3,3,2), bty = "l")
  plot(1, type="n", xlab="", ylab="", xlim=c(0, 4), ylim=c(0, 4), main="Wonky Sierpinski Gasket")
  
  for (i in 1:40000) {
    points(x=X[1], y=X[2], cex=0.001, col="blue")  # make a point on the plot at X
    random_choice <- sample(coords, 1)[[1]]  # choose A, B, or C at random
    X <- X + ((random_choice - X) / 2)  # move X half way towards the random ponit (A/B/C)
  }
  
  return("It's a wonky Sierpinski gasket! The initial points of the triangle are subdivided recursively so that a self-similar pattern of smaller triangles, defined by the midpoints of the larger triangles, is created within the boundaries of the original.")
}

# Question 24
turtle <- function(start_position, direction, length)  {
  # length = radius of circle
  # direction = angle in circle
  x_end <- start_position[1] + length * cos(direction)
  y_end <- start_position[2] + length * sin(direction)
  endpoint <- c(x_end, y_end)
  
  segments(x0 = start_position[1], y0 = start_position[2],
           x1 = x_end, y1 = y_end, col="black")
  
  return(endpoint) # you should return your endpoint here.
}

# Question 25
elbow <- function(start_position, direction, length)  {
    endpoint <- turtle(start_position, direction, length)
    turtle(endpoint, direction - pi/4, length*0.95)
}

# Question 26
spiral <- function(start_position, direction, length)  {
  if (length > 1e-10) {  # when length becomes v small, stop (won't have infinite recursion) (unless starting length is v big...!)
      endpoint <- turtle(start_position, direction, length)
      spiral(endpoint, direction - pi/4, length*0.95)
  }
  return("A spiral is created and an error was produced (prior to introducing the length threshold). This is because the function calls itself recursively and would continue to do this in an infinite loop (infinite recursion).")
}

# Question 27
draw_spiral <- function()  {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  par(mar=c(3,3,3,2), mfrow=c(1,1), bty = "l") 
  plot(1, type="n", xlab="", ylab="", xlim=c(0, 6), ylim=c(0, 5), main="Spiral")
  return(spiral(start_position = c(1,1), direction=pi/2, length=2))
}

# Question 28
tree <- function(start_position, direction, length)  {
  if (length > 0.05) {  # when length becomes v small, stop (won't have infinite recursion) (unless starting length is v big...!)
    endpoint <- turtle(start_position, direction, length)
    endpoint_left <- tree(endpoint, direction + pi/4, length*0.65)
    endpoint_right <- tree(endpoint, direction - pi/4, length*0.65)
  }
}

draw_tree <- function()  {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  par(mar=c(3,3,3,2), mfrow=c(1,1), bty = "l") 
  plot(1, type="n", xlab="", ylab="", xlim=c(0, 50), ylim=c(0, 45), main="Tree")
  tree(start_position = c(25,1), direction=pi/2, length=15)
}

# Question 29
fern <- function(start_position, direction, length)  {
  if (length > 0.05) {  # when length becomes v small, stop (won't have infinite recursion) (unless starting length is v big...!)
    endpoint <- turtle(start_position, direction, length)
    endpoint_left <- fern(endpoint, direction + pi/4, length*0.38)
    endpoint_straight <- fern(endpoint, direction, length*0.87)
  }
}

draw_fern <- function()  {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  par(mar=c(3,3,3,2), mfrow=c(1,1), bty = "l") 
  plot(1, type="n", xlab="", ylab="", xlim=c(15, 80), ylim=c(0, 120), main="Half Fern")
  fern(start_position = c(50,1), direction=pi/2, length=15)
}

# Question 30
fern2 <- function(start_position, direction, length, dir)  {
  if (length > 0.05) {  # when length becomes v small, stop (won't have infinite recursion) (unless starting length is v big...!)
    endpoint <- turtle(start_position, direction, length)
    endpoint_left <- fern2(endpoint, direction + pi/4*dir, length*0.38, dir)
    endpoint_straight <- fern2(endpoint, direction, length*0.87, dir*-1)
  }
}

draw_fern2 <- function()  {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  par(mar=c(3,3,3,2), mfrow=c(1,1), bty = "l") 
  plot(1, type="n", xlab="", ylab="", xlim=c(10, 90), ylim=c(0, 120), main="Fern")
  fern2(start_position = c(50,1), direction=pi/2, length=15, dir=1)
}

# Challenge questions - these are optional, substantially harder, and a maximum of 16% is available for doing them.  


# calculate species richness series - averages and confidence intervals (for challenge A and B)
calculate_mean_richness_series <- function(community, num_reps, duration) {
  
  # initialise empty data frames to hold all the time series
  richness_series <- data.frame(matrix(NA, nrow=num_reps, ncol=duration))
  
  for (rep in 1:num_reps) {
    # calculate species richness at each time point
    spp_rich_time_series <- neutral_time_series_speciation(community=community,
                                                           duration=duration,
                                                           speciation_rate=0.1)
    # append to data frame
    richness_series[rep,] <- spp_rich_time_series
  }
    
  mean_rich_time_series <- apply(richness_series, 2, mean)
  
  # z score for 97.2% 
  z <- qnorm(0.986)  # (97.2 + 2.8/2)
  
  # CI = mean +- z * (s / sqrt(n))
  # s = st dev, n = sample size
  stdev_rich_time_series <- apply(richness_series, 2, sd)
  CI_rich_time_series <- z * (stdev_rich_time_series / sqrt(num_reps))
  
  return(list(mean_rich_time_series, CI_rich_time_series))
}


richness_runs_for_challenge_A <- function() {
  # runs the simulations and saves the data to an .rda
  NUM_REPS <- 200
  DURATION <- 200
  
  # initialise communities
  min_community <- init_community_min(100)
  max_community <- init_community_max(100)
  
  # get mean species richness time series as well as confidence intervals
  min_means_and_CIs <- calculate_mean_richness_series(min_community, NUM_REPS, DURATION)
  max_means_and_CIs <- calculate_mean_richness_series(max_community, NUM_REPS, DURATION)
 
  # extract means and CIs separately - for min community
  mean_rich_time_series_min <- min_means_and_CIs[[1]]
  CI_rich_time_series_min <- min_means_and_CIs[[2]]
  
  # extract means and CIs separately - for max community
  mean_rich_time_series_max <- max_means_and_CIs[[1]]
  CI_rich_time_series_max <- max_means_and_CIs[[2]]
 
  save(mean_rich_time_series_min, mean_rich_time_series_max,
       CI_rich_time_series_min, CI_rich_time_series_max, 
       file="Challenge_A_data.rda")
  
}

# Challenge question A
Challenge_A <- function() {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  DURATION <- 200
  
  load("Challenge_A_data.rda")

  par(mar=c(5,5,3,2), mfrow=c(1,1), bty = "l")  # add a bit of border to left of y axis label
  # min richness community
  plot(x=1:DURATION, y = mean_rich_time_series_min, 
       type="l", lwd=2, col="orange", ylim=c(0,100),
       xlab="Time in generations", 
       ylab=expression(paste("Mean Species ", Richness %+-% 97.2,  "% CI", sep=" ")),
       main="Neutral Model With Speciation (speciation rate = 0.1)",
       cex.lab=1.1)  # make axes label text slightly bigger
  polygon(c(1:DURATION, rev(1:DURATION)), 
          c(mean_rich_time_series_min - CI_rich_time_series_min,
            rev(mean_rich_time_series_min + CI_rich_time_series_min)),
          col=alpha("orange", 0.5), border=NA)
  # max richness community
  lines(x=1:DURATION,
        y = mean_rich_time_series_max,
        lwd=2, col="cyan")
  polygon(c(1:DURATION, rev(1:DURATION)), 
          c(mean_rich_time_series_max - CI_rich_time_series_max,
            rev(mean_rich_time_series_max + CI_rich_time_series_max)),
          col=alpha("cyan", 0.5), border=NA)
  abline(v=45, col="red", lty="dashed")
  legend("topright", inset=0.05, title="Initial community state", 
         legend=c("Minimum richness", "Maximum richness", "", "Dynamic equilibrium reached"), 
         col=c("orange", "cyan", "white", "red"),
         lwd=c(2,2,0,1), lty=c(1,1,1,2), box.lty=0)
}


# Challenge question B

# create community of given species richness
init_random_rich_community <- function(max_richness, size) {
  community_one_of_each <- seq(1, max_richness)  # create community which is as rich as max_richness
  community <- c(community_one_of_each,  
                 sample(community_one_of_each,  # randomly add indivs of the spp present so that community is correct size
                        size-length(community_one_of_each),
                        replace=TRUE))
  return(community)
}


richness_runs_for_challenge_B <- function() {
  
  NUM_COMMUNITIES <- 11
  NUM_REPS <- 100  # for each diff community
  DURATION <- 200
  
  richness_vals <- seq(0, 100, 10)
  richness_vals[1] <- 1
  
  means <- vector(mode = "list", length = NUM_COMMUNITIES)
  CIs <- vector(mode = "list", length = NUM_COMMUNITIES)
  
  for(comm in 1:NUM_COMMUNITIES) {
    
    community <- init_random_rich_community(max_richness=richness_vals[comm],size=100)
    
    means_and_CIs <- calculate_mean_richness_series(community, NUM_REPS, DURATION)
    
    # extract means and CIs separately
    mean_rich_time_series <- means_and_CIs[[1]]
    CI_rich_time_series <- means_and_CIs[[2]]

    means[comm] <- list(mean_rich_time_series)
    CIs[comm] <- list(CI_rich_time_series)
  }
  
  save(means, CIs, richness_vals, file="Challenge_B_data.rda")
}

Challenge_B <- function() {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  load("Challenge_B_data.rda")
  
  NUM_COMMUNITIES <- 11
  DURATION <- 200
  
  colour_palette <- c(rainbow(NUM_COMMUNITIES))
  
  # create blank plot
  par(mar=c(5,5,3,2), mfrow=c(1,1), bty = "l")  # add a bit of border to left of y axis label
  plot(1:DURATION, type="n",
       ylim=c(0, 100),
       xlab="Time in generations", 
       ylab=expression(paste("Mean Species ", Richness %+-% 97.2,  "% CI", sep=" ")),
       main="Neutral Model With Speciation (speciation rate = 0.1)",
       cex.lab=1.1)  # make axes label text slightly bigger
  
  for (i in 1:NUM_COMMUNITIES) {
    lines(x=1:DURATION,
          y = means[[i]],
          lwd=2, col=colour_palette[i])
    polygon(c(1:DURATION, rev(1:DURATION)),
            c(means[[i]] - CIs[[i]],
              rev(means[[i]] + CIs[[i]])),
            col=alpha(colour_palette[i], 0.5), border=NA)
  }
  legend("topright", inset=0.05, title="Initial species richness", 
         legend=c(richness_vals), 
         col=c(colour_palette),
         lwd=2, box.lty=0)
  
}


# Challenge question C

save_richness_data_for_challenge_C <- function() {
  
  simulation <- 1
  community_sizes <- c(500, 1000, 2500, 5000)
  
  means <- list()

  for (size in community_sizes) {

    # running total of richness for each community size
    richness_series_runnning_total <- c()

    # for each simulation of each community size (25 each)
    for (i in 1:25) {

      load(paste("simulation_", simulation, ".rda", sep=""))

      richness_series_runnning_total <- sum_vect(richness_series_runnning_total, time_series)

      simulation <- simulation + 1
    }
    
    mean_rich_series <- richness_series_runnning_total / 25
    means <- c(means, list(mean_rich_series))
  }
  save(means, community_sizes, file="Challenge_C_data.rda")
}


Challenge_C <- function() {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  load("Challenge_C_data.rda")
  
  num_diff_sizes <- length(community_sizes)
  longest_duration <- community_sizes[4] * 8
  
  colour_palette <- c(rainbow(num_diff_sizes))
  
  # create blank plot
  par(mar=c(5,5,3,2), mfrow=c(1,1), bty = "l")  # add a bit of border to left of y axis label
  plot(1:longest_duration, type="n",
       ylim=c(0, 80),
       xlab="Time in generations", 
       ylab="Mean Species Richness",
       main="Neutral Model With Speciation (speciation rate = 0.1)",
       cex.lab=1.1)  # make axes label text slightly bigger
  
  # add lines
  for (i in 1:num_diff_sizes) {
    lines(x = 1:length(means[[i]]),
          y = means[[i]],
          lwd=2, col=colour_palette[i])
    abline(v=2*community_sizes[i], col=colour_palette[i], lty="dashed")  # equilib reached
  }
  
  legend("right", inset=0.05, title="Community size", 
         legend=c(community_sizes, "", "Equilibrium reached"), 
         col=c(colour_palette, "white","black"),
         lwd=2, box.lty=0, lty=c(1,1,1,1,1,3))
  
  # inset plot of first 1000 generations
  par(fig=c(0.6,0.9,0.2,0.35), new=TRUE, mar=c(0,0,0,0), bty = "o")
  
  plot(1:1000, type="n",
       ylim=c(0, 75),
       xlab="", 
       ylab="")
  
  for (i in 1:num_diff_sizes) {
    lines(x = 1:length(means[[i]]),
          y = means[[i]],
          lwd=2, col=colour_palette[i])
    abline(v=2*community_sizes[i], col=colour_palette[i], lty="dashed")
  }

  return("All communities reached dynamic equilibrium within the burn-in period. A better estimate of this burn-in period might be to use the community size multiplied by 2 (as indicated by the dashed lines on the plot) rather than 8 times the community size. This would allow plenty of leeway for equilibrium to be reached whilst minimising the burn-in time.")
}


# Challenge question D

get_coalescence_results <- function() {
  
  comm_sizes <- c(500, 1000, 2500, 5000)
  NUM_REPEATS <- 2500
  
  v <- 0.0021818  # my speciation rate
  mean_octaves <- list()  # will be list of 4 containing final abund vect for each community size
  
  start <- proc.time()[[3]]  # start timing
  
  # size of simulation
  for (comm_size in comm_sizes) {
    
    J <- comm_size  # J = size of simulation
    running_total_octaves <- c()
    
    for (i in 1:NUM_REPEATS) { 
      
      lineages <- rep(1, J)  # all indivs/lineages at end point (observed)
      abundances <- c()
      N <- J  # N = num indivs/lineages
      
      theta <- v * ((J - 1) / (1 - v))
      
      while (N > 1) {
        j <- sample(1:length(lineages), 1)  # random index of lineages
        randnum <- runif(1, 0, 1) 
        
        if (randnum < (theta / (theta + N - 1))) {
          # speciation event - (add abundance of this spp to overall abund vect)
          abundances <- c(abundances, lineages[j])
        } else {
          # coalescence
          i <- sample(1:length(lineages), 1)  # get another random lineage w index i
          while (i == j) {  # not the same as lineages[j]
            i <- sample(1:length(lineages), 1)
          }
          lineages[i] = lineages[i] + lineages[j]  # coalescence 
        }
        lineages <- lineages[-j]  # remove lineage[j] from total
        N = N - 1  # reduce size 
      }
      
      abundances <- c(abundances, lineages)  # add final remaining lineage abundance to abundances 
      
      octave <- octaves(abundances)  # calculate abundance octave 
      running_total_octaves <- sum_vect(running_total_octaves, octave)
    }   
    
    mean_octave <- running_total_octaves / NUM_REPEATS  # divide by num repeats for each size
    
    mean_octaves <- c(mean_octaves, list(mean_octave))  # add to list of final vectors
  }
  
  total_time <- (proc.time()[[3]] - start)  # total time taken in seconds
  
  # make data frame for plotting
  df_for_plotting_D <- data.frame()
  
  for (i in 1:4) {
    size <- comm_sizes[i]
    vector <- mean_octaves[[i]]
    
    # make a data frame of mean abund octave in bins etc for each initial community size
    df_octave <- get_abund_df(vector, 
                              grouping_factor_name = "comm_size",
                              grouping_factor = size)
    
    df_for_plotting_D <- rbind(df_for_plotting_D, df_octave)
  }
  
  # for plot facets
  df_for_plotting_D$comm_size <- factor(df_for_plotting_D$comm_size,
                                        labels=c("Community size = 500", 
                                                 "Community size = 1000", 
                                                 "Community size = 2500", 
                                                 "Community size = 5000"))
  
  
  save(mean_octaves, total_time, df_for_plotting_D, file="Challenge_D_data.rda")
  
}


Challenge_D <- function() {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  # load results from cluster simulations
  load("cluster_abund_results.rda")
  df_for_plotting$method <- "Cluster"
  
  # load results from coalescence simulations
  load("Challenge_D_data.rda")
  df_for_plotting_D$method <- "Coalescence"
  
  # combine the 2 dataframes
  df_for_plotting_both <- rbind(df_for_plotting, df_for_plotting_D)
  
  # plot results 
  p <- ggplot(df_for_plotting_both, aes(x=reorder(bin_labels, octave),
                                     y=abundance, fill=method)) +
    geom_bar(stat="identity", position=position_dodge()) +
    labs(title="Species Abundance Distributions",
         x="Number of Individuals per Species",
         y="Mean Number of Species",
         fill="Method") +
    theme_classic() +
    facet_wrap(~comm_size, scales="free") +
    theme(legend.position = "top",
          plot.title = element_text(hjust = 0.5),
          text = element_text(size=14),
          strip.background = element_blank(),
          axis.text.x = element_text(angle=-50, vjust=0.5, hjust=0),
          plot.margin = margin(0.5, 1.5, 0.5, 0.5, "cm"),) +
    scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))  # integers for y axis
  show(p)
 
  time_taken <- paste(round(total_time/60, 2), "minutes (or", round(total_time/3600, 2), "hours)", sep=" ")

  return(paste(time_taken, "were taken for the coalescence simulations (2500 repeats), compared to a total of 1150 hours taken to run an equivalent set of simulations on the cluster (11.5 hrs for each of 100 simulations). The coalescence simulations were so much faster because only those lineages which are present in the final community are simulated. The two methods produce concordant results but coalescence theory is able to reach this answer vastly quicker.", sep=" "))
}


# Challenge question E
Challenge_E <- function() {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  NUM_DIFF_START_X <- 20
  
  A <- c(2,2)
  B <- c(6,2)
  C <- c(4,6)
  coords <- list(A, B, C)
  
  par(mfrow=c(1,1), mar=c(3,3,3,2), bty = "l")
  plot(1, type="n", xlab="", ylab="", xlim=c(0, 10), ylim=c(0, 10), main="Sierpinski Gasket with Varying Start Points")

  colours <- c(rainbow(NUM_DIFF_START_X))

  for (x in 1:NUM_DIFF_START_X) {

    X <- c(runif(1, 0, 10), runif(1, 0, 10))

    for (i in 1:1000) {
      
      if (i == 1) {  # plot first point as cross
        points(x=X[1], y=X[2], cex=2, col=colours[x], pch=4)
      } else if (i < 10) {  # first 10 points a bit bigger
        points(x=X[1], y=X[2], cex=0.5, col=colours[x], pch=19)
      } else {
        points(x=X[1], y=X[2], cex=0.05, col=colours[x])
      }
      
      random_choice <- sample(coords, 1)[[1]]
      
      X <- X + ((random_choice - X) / 2)
      
    }
    
  }
  
  return("Regardless of the coordinates of the initial point (shown as crosses on the plot), the same Sierpinski Gasket is always created. From the starting point, movement will always be towards the space defined by the set coordinates (A, B, C) then the points will follow the pattern of the original Sierpinski Gasket shape as dictated by the midpoints of the triangles.")
}


# Challenge question F
turtle_mod <- function(start_position, direction, length, colour, line_width)  {
  x_end <- start_position[1] + length * cos(direction)
  y_end <- start_position[2] + length * sin(direction)
  endpoint <- c(x_end, y_end)
  
  segments(x0 = start_position[1], y0 = start_position[2],
           x1 = x_end, y1 = y_end, col=colour, lwd=line_width)
  return(endpoint)
}

pine <- function(start_position, direction, length, colour, line_width, threshold) {
  if (length > threshold) {  
    endpoint <- turtle_mod(start_position, direction, length, colour, line_width)
    endpoint_straight <- pine(endpoint, direction, length*0.8, "darkgreen", 2, threshold)
    endpoint_left <- pine(endpoint, direction + 2.5*pi/4, length*0.4, "darkgreen", 2, threshold)
    endpoint_right <- pine(endpoint, direction - 2.5*pi/4, length*0.4, "darkgreen", 2, threshold)
  }
}

star <- function(start_position, direction, length) {  # obviously not a fractal! (just for decorative/labelling purposes!!!)
  for (i in 1:5) {
    direction = direction + 2.51327
    start_position <- turtle_mod(start_position, direction, length, "gold", 8)
  }
}

Challenge_F <- function() {
  # clear any existing graphs and plot your graph within the R window
  dev.off()
  
  # empty plot
  par(mfrow=c(1,1), mar=c(3,3,3,2), bty = "l")
  plot(1, type="n", xlab="", ylab="", xlim=c(0, 200), ylim=c(0, 200), 
       main="Merry Christmas!")
  
  # coordinates and threshold values for the pines
  pine_tree_start_coords <- list(c(25, 110), c(150, 120), c(95, 70), c(40, 20), c(170, 5))
  threshold_vals <- c(0.5, 0.3, 0.1, 0.05, 0.02)
  pine_times <- c()
  
  # create the pines - all the same size etc - so all params constant apart from threshold val (and position!)
  for (i in 1:5) {
    start_time <- proc.time()[[3]]
    start_point <- pine_tree_start_coords[[i]]
    pine <- pine(start_position = start_point,
                 direction=pi/2, length=15, "brown", 15,
                 threshold=threshold_vals[i])
    pine_time <- (proc.time()[[3]] - start_time)
    star <- star(start_position = c(start_point[1], start_point[2]+80),
                 direction = pi/2+0.3, length=7)
    label <- text(start_point[1], start_point[2]+77, i, col="red")
    pine_times <- c(pine_times, pine_time)
  }

  # table of times and threshold values for each pine
  pines <- data.frame(seq(1:5))
  pines$threshold <- threshold_vals
  pines$times <- pine_times
  names(pines) <- c("Pine", "Line threshold", "Time taken")
  
  print(pines)

  return("As the line threshold value is decreased, the image produced becomes more detailed as increasingly smaller lines are included; this also means that the time taken to run increases even as all other parameters are constant.")
}

# Challenge question G should be written in a separate file that has no dependencies on any functions here.
