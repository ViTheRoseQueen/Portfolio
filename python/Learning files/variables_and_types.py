# Code written by Kristen Laurencelle
# Tutorial from https://www.learnpython.org/
#=========================================================

# Python supports 2 types of numbers. integers(whole numbers) and floating point numbers(decimals).
# Python also supports complex numbers but those will not be used here.

# Defines an integer and then prints it to the terminal
myint = 7
print(myint)

# Defining a floating point number is a little different and has at least 2 ways of doing it.

# This is the first way
myfloat = 7.0
print(myfloat)

# This is the second way
myfloat = float(7)
print(myfloat)

# Strings are defined either with a single quote or a double quote.

# This is single
mystring = 'Hello'
print(mystring)

# This is double
mystring = "Hello"
print(mystring)

# The difference between the two is that using double quotes makes it easy to include apostrophes (whereas these would terminate the string if using single quotes)

# There are additional variations on defining strings that make it easier to include things such as carriage returns, backslashes and Unicode characters

# Simple operators can be executed on numbers and strings
one = 1
two = 2
three = one + two
print(three)

hello = "hello"
world = "world"
helloworld = hello + " " + world
# The space is needed because the language compiler doesnt automatically add a space when code is run
print(helloworld)

# Assignments can be done on more than one variable "simultaneously" on the same line
a, b = 3, 4
print(a, b)

# Mixing operators between numbers and strings is not supported

one = 1
two = 2
hello = "hello"
print(one + two + hello)
# This will not print to terminal and will error out. 