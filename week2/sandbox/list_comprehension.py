# print numbers in range
x = [i for i in range(10)]
print(x)

x = []
for i in range(10):
    x.append(i)
print(x)

# lower case not upper
x = [i.lower() for i in ["LIST","COMPREHENSIONS","ARE","COOL"]]
print(x)

x = ["LIST","COMPREHENSIONS","ARE","COOL"]
for i in range(len(x)): # explicit loop
    x[i] = x[i].lower()
print(x)

x = ["LIST","COMPREHENSIONS","ARE","COOL"]
x_new = []
for i in x: # implicit loop
    x_new.append(i.lower())
print(x_new)

# flatten matrix

# nested loop
matrix = [[1,2,3],[4,5,6],[7,8,9]]
flattened_matrix = []
for row in matrix:
    for n in row:
        flattened_matrix.append(n)
print(flattened_matrix)

matrix = [[1,2,3],[4,5,6],[7,8,9]]
flattened_matrix = [n for row in matrix for n in row]
print(flattened_matrix)

# sets
words = (["These", "are", "some", "words"])
first_letters = set()
for w in words:
    first_letters.add(w[0])
print(first_letters)

# set comprehension
words = (["These", "are", "some", "words"])
first_letters = {w[0] for w in words}
print(first_letters)



