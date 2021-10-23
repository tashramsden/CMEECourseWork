#!/usr/bin/env python3

"""Reads nucleotide sequences from ../data/sequences.csv; 
calculates alignments with highest number of matching bases; 
saves last alignment with highest score to ../results/sequence_alignment.txt"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

## imports ##
import csv
import sys


csv_file = "../data/sequences.csv"


## functions ##
def get_sequences_lengths(seq_csv):
    """Takes a csv file and extracts the sequences, gets the lengths of these sequences:
    assigns longer sequence s1 with length l1, shorter sequence s2 with length l2.
    Returns s1, s2, l1, l2."""
    # read in csv file containing 2 sequences
    with open(seq_csv, "r") as seq_file:
        csvread = csv.reader(seq_file)
        seqs = [seq for seq in csvread]
    
    # print(seqs)
    seq1 = seqs[0][0]
    seq2 = seqs[0][1]
    
    # Assign the longer sequence s1, and the shorter to s2
    # l1 is length of the longest, l2 that of the shortest
    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = seq1
        s2 = seq2
    else:
        s1 = seq2
        s2 = seq1
        l1, l2 = l2, l1 # swap the two lengths
    
    return s1, s2, l1, l2


def calculate_score(s1, s2, l1, l2, startpoint):
    """A function that computes a score by returning the number of matches starting from arbitrary startpoint (chosen by user)"""
    # import ipdb; ipdb.set_trace()
    matched = "" # to hold string displaying alignments
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"

    # some formatted output
    print("." * startpoint + matched)           
    print("." * startpoint + s2)
    print(s1)
    print(score) 
    print(" ")

    return score


def find_best_alignment(s1, s2, l1, l2):
    """Finds the best alignment of 2 sequences, s1 and s2, by iteratively comparing their "matching" scores;
    returns the last best alignment and its score."""
    my_best_align = None
    my_best_score = -1
    
    for i in range(l1): # Note that you just take the first/last alignment with the highest score
        z = calculate_score(s1, s2, l1, l2, i)
        if z >= my_best_score:  # if this >= then would get last matching alignment (> for first)
            my_best_align = "." * i + s2 # think about what this is doing!
            my_best_score = z 
    # print(my_best_align)
    # print(s1)
    # print("Best score:", my_best_score)

    return my_best_align, my_best_score


def save_best_align(my_best_align, my_best_score, s1):
    """Takes the best alignment, its score, and the longer sequence; 
    saves this information to a text file in ../results."""
    output_contents = f"Aligned sequences:\n\n{my_best_align}\n{s1}\n\nBest score: {my_best_score}"
    print(output_contents)
    
    with open("../results/sequence_alignment.txt", "w") as output:
        print("Saving best alignment to ../results/sequence_alignment.txt...")
        output.write(output_contents)
        print("Done!")


def main(argv):
    """Main entry point of the program."""
    s1, s2, l1, l2 = get_sequences_lengths(csv_file)
    my_best_align, my_best_score = find_best_alignment(s1, s2, l1, l2)
    save_best_align(my_best_align, my_best_score, s1)


if __name__ == "__main__":
    status = main(sys.argv) 
    sys.exit(status) 
