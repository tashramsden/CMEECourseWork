#!/usr/bin/env python3

"""Prints lists of information about bird species (latin names, common names, and body masses)"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
        )

# Birds is a tuple of tuples of length three: latin name, common name, mass.
# write a (short) script to print these on a separate line or output block by species 
# 
# A nice example output is:
# 
# Latin name: Passerculus sandwichensis
# Common name: Savannah sparrow
# Mass: 18.7
# ... etc.

# Hints: use the "print" command! You can use list comprehensions!

## loop
# for bird in birds:
#     print(f"\nLatin name: {bird[0]}\nCommon name: {bird[1]}\nMass: {bird[2]}")

## lc
bird_info = [print(f"\nLatin name: {bird[0]}\nCommon name: {bird[1]}\nMass: {bird[2]}") for bird in birds]
