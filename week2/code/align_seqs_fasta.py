#!/usr/bin/env python3

"""Reads nucleotide sequences from 2 fasta files 
(passed as args - deaults are: ../data/407228326.fasta and ../data/407228412.fasta);
calculates alignments with highest number of matching bases;
saves last alignment with highest score to ../results/sequence_alignment.txt"""
__author__ = 'Awesome Aardvarks'
__version__ = '0.0.1'


## imports ##
import sys


## default fasta files ##
default1 = "../data/407228326.fasta"
default2 = "../data/407228412.fasta"


## functions ##
def read_sequences(seq_file):
    """Reads contents of a fasta file and returns the contained sequence as a string (without new line characters or comments)"""
    with open(seq_file, "r") as file:
        all_lines = file.readlines()
    seq = [line.replace("\n", "") for line in all_lines if not line.startswith(">")]  # remove any commented lines and all new line chars
    seq = "".join(seq)  # join all items in list
    return seq


def get_sequences_lengths():
    """Gets 2 sequences and their lengths either from 2 input fasta files or from the default files. 
    Assigns the longer seqeunce to s1 with length l1, and the shorter to s2 with length l2.
    Returns s1, s2, l1, l2."""
    ## Get sequences from fasta files##
    if len(sys.argv) != 3:  # arg 0 is always file name, 1 and 2 will be the inputs
        print("Getting sequences from the default files...\n(Run with 2 fasta files as inputs if you want to use these instead).")
        seq1 = read_sequences(default1)
        seq2 = read_sequences(default2)
    elif not sys.argv[1].endswith(".fasta") or not sys.argv[2].endswith(".fasta"):
        print("Please provide 2 fasta files as inputs.\nGetting sequences from default files instead...")
        seq1 = read_sequences(default1)
        seq2 = read_sequences(default2)
    else:
        print(f"Getting sequences from {sys.argv[1]} and {sys.argv[2]}...")
        seq1 = read_sequences(sys.argv[1])
        seq2 = read_sequences(sys.argv[2])
    
    ## Get lengths ##
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
    """A function that computes a base-matching score by returning the number of matches starting from arbitrary startpoint (chosen by user)"""
    matched = "" # to hold string displaying alignments
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"
    return score


def find_best_alignment(s1, s2, l1, l2):
    """Finds the best alignment of 2 sequences, s1 and s2, by iteratively comparing their "matching" scores.
    Returns the last best alignment and its score."""
    ## Find best alignment ##
    my_best_align = None
    my_best_score = -1
    
    for i in range(l1): # Note that you just take the first/last alignment with the highest score
        z = calculate_score(s1, s2, l1, l2, i)
        if z >= my_best_score:  # if this >= then would get last matching alignment (> for first)
            my_best_align = "." * i + s2
            my_best_score = z 
    
    return my_best_align, my_best_score


def save_best_align(my_best_align, my_best_score, s1):
    """Takes the best alignment, its score, and the longer sequence; 
    saves this information to a text file in ../results."""
    output_contents = f"Aligned sequences, with highest matching score of {my_best_score}:\n\n{my_best_align}\n{s1}"
    # print(output_contents)
    
    with open("../results/sequence_alignment.txt", "w") as output:
        print(f"Saving the best alignment to ../results/sequence_alignment.txt...")
        output.write(output_contents)
        print("Done!")


def main(argv):
    """Main entry point of the program."""
    s1, s2, l1, l2 = get_sequences_lengths()
    my_best_align, my_best_score = find_best_alignment(s1, s2, l1, l2)
    save_best_align(my_best_align, my_best_score, s1)
    return 0


if __name__ == "__main__":
    status = main(sys.argv) 
    sys.exit(status) 