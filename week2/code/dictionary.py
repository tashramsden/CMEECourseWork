taxa = [ ('Myotis lucifugus','Chiroptera'),
         ('Gerbillus henleyi','Rodentia',),
         ('Peromyscus crinitus', 'Rodentia'),
         ('Mus domesticus', 'Rodentia'),
         ('Cleithrionomys rutilus', 'Rodentia'),
         ('Microgale dobsoni', 'Afrosoricida'),
         ('Microgale talazaci', 'Afrosoricida'),
         ('Lyacon pictus', 'Carnivora'),
         ('Arctocephalus gazella', 'Carnivora'),
         ('Canis lupus', 'Carnivora'),
        ]

# Write a short python script to populate a dictionary called taxa_dic 
# derived from  taxa so that it maps order names to sets of taxa.
# 
# An example output is:
#  
# 'Chiroptera' : set(['Myotis lucifugus']) ... etc.
#  OR,
# 'Chiroptera': {'Myotis lucifugus'} ... etc

## First attempt:
## create empty dict with key names
# taxa_dict = {entry[1]: set() for entry in taxa}

## populate dict w values
# for entry in taxa:
#     taxa_dict[entry[1]].add(entry[0])

# print(taxa_dict)

# ONE LINE
taxa_dict2 = {entry[1]: set(row[0] for row in taxa if row[1] == entry[1]) for entry in taxa}

print(taxa_dict2)

