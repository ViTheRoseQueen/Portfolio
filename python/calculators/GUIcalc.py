# Import required packages
from tkinter import *

# Variable to store the user stored expression
exp=' '

# Function to store the values entered by the user (numbers and operators)
def press(number):
    global exp
    exp+=str(number)
    equation.set(exp)

def equalpress():
    try: 
