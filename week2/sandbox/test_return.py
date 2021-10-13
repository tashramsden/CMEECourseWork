#####################################
# TESTING RETURN DIRECTIVE
#####################################

## WITHOUT return
def modify_list_1(some_list):
    print("got", some_list)
    some_list = [1, 2, 3, 4]
    print("set to", some_list)

my_list = [1, 2, 3]

print("before, my_list =", my_list)

modify_list_1(my_list)

print("after, my_list =", my_list)


## WITH return
def modify_list_2(some_list):
    print('got', some_list)
    some_list = [1, 2, 3, 4]
    print('set to', some_list)
    return some_list

my_list = modify_list_2(my_list)

print('after, my_list =', my_list)


## Modify original list in place
def modify_list_3(some_list):
    print('got', some_list)
    some_list.append(5) # an actual modification of the list
    print('changed to', some_list)

modify_list_3(my_list)

print('after, my_list =', my_list)

# append will change list outside of function BUT still better to use return - sure to capture the output
