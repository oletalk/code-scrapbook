#!/usr/bin/python3

# import modules used here
import sys

def repeat(s:str, exclaim: bool):
    """
    Returns the string 's' repeated 3 times.
    If exclaim is true, add exclamation marks.
    """

    result = s * 3
    if exclaim:
        result = result + '!!!'
    return result


# Gather our code in a main() function
def main():
    greet = sys.argv[1]
    if greet == 'Colin':
        print('Hey we have the same name!')   
    else:
        print('Hello there', greet)
    print(repeat("yeah, whatever ", True))
    print(repeat(2, 2))

if __name__ == '__main__':
    main()
