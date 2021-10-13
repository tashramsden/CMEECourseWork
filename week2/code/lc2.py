# Average UK Rainfall (mm) for 1910 by month
# http://www.metoffice.gov.uk/climate/uk/datasets
rainfall = (('JAN',111.4),
            ('FEB',126.1),
            ('MAR', 49.9),
            ('APR', 95.3),
            ('MAY', 71.8),
            ('JUN', 70.2),
            ('JUL', 97.1),
            ('AUG',140.2),
            ('SEP', 27.0),
            ('OCT', 89.4),
            ('NOV',128.4),
            ('DEC',142.2),
           )

# (1) Use a list comprehension to create a list of month,rainfall tuples where
# the amount of rain was greater than 100 mm.
 
print("\nStep #1")
more_rain = [(month, rain) for (month, rain) in rainfall if rain > 100]
print(f"Months and rainfall values when the amount of rain was greater than 100mm:\n{more_rain}")

# (2) Use a list comprehension to create a list of just month names where the
# amount of rain was less than 50 mm. 

print("\nStep #2")
less_rain = [(month, rain) for (month, rain) in rainfall if rain < 50]
print(f"Months and rainfall values when the amount of rain was less than 50mm:\n{less_rain}")

# (3) Now do (1) and (2) using conventional loops (you can choose to do 
# this before 1 and 2 !). 

print("\nStep #3: Using normal loops")

more_rain2 = []
less_rain2 = []

for record in rainfall:
    if record[1] > 100:
        more_rain2.append(record)
    elif record[1] < 50:
        less_rain2.append(record)

print(f"Months and rainfall values when the amount of rain was greater than 100mm:\n{more_rain2}")

print(f"Months and rainfall values when the amount of rain was less than 50mm:\n{less_rain2}")

# A good example output is:
#
# Step #1:
# Months and rainfall values when the amount of rain was greater than 100mm:
# [('JAN', 111.4), ('FEB', 126.1), ('AUG', 140.2), ('NOV', 128.4), ('DEC', 142.2)]
# ... etc.

