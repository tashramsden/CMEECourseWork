def buggyfunc(x):
    y = x
    for i in range(x):
        try: 
            y = y - 1
            z = x / y
        # import ipdb; ipdb.set_trace()
        # import pdb; pdb.set_trace()
        except ZeroDivisionError:
            print(f"The result of dividing a number by zero is undefined")
        except:
            print(f"This didn't work; x = {x}; y = {y}")
        else:
            print(f"OK; x = {x}; y = {y}, z = {z};")
    return z

buggyfunc(20)
