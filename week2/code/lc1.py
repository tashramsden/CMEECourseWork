#!/usr/bin/env python3

"""Creates lists of bird information (latin names, common names, and body masses) from tuples using loops and list comprehensions"""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 

print("\nUsing list comprehension:\n")

latin_names = [bird[0] for bird in birds]
common_names = [bird[1] for bird in birds]
body_masses = [bird[2] for bird in birds]

print(f"Latin names:\n{latin_names}")
print(f"Common names:\n{common_names}")
print(f"Mean body masses:\n{body_masses}")

# (2) Now do the same using conventional loops (you can choose to do this 
# before 1 !). 

print("\n\nUsing normal loops:\n")

latin_names2 = []
common_names2 = []
body_masses2 = []

for bird in birds:
    latin_names2.append(bird[0])
    common_names2.append(bird[1])
    body_masses2.append(bird[2])

print(f"Latin names:\n{latin_names2}")
print(f"Common names:\n{common_names2}")
print(f"Mean body masses:\n{body_masses2}")

# A nice example out out is:
# Step #1:
# Latin names:
# ['Passerculus sandwichensis', 'Delichon urbica', 'Junco phaeonotus', 'Junco hyemalis', 'Tachycineata bicolor']
# ... etc.

 