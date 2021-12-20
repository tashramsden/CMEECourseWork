#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=1gb
module load anaconda3/personal
cp $HOME/cluster_sim_runs/ter21_HPC_2021_main.R $TMPDIR
echo "R is about to run"
R --vanilla < $HOME/cluster_sim_runs/ter21_HPC_2021_cluster.R
mv simulation* $HOME/cluster_sim_runs
echo "R has finished running"

