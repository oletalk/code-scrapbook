# an example of inserting one at a time
mydict = {}
mydict["a"] = "alpha"
mydict["g"] = "gamma"
mydict["o"] = "omega"
del mydict["o"]

# without this if statement it dies with a ValueError
if "d" in mydict:
    print("%(d)", mydict)

for key, value in mydict.items():
    print(key, "-->", value)

# Original syntax from Google class doesn't work...
# the **foo is a format parameter
# see https://stackoverflow.com/questions/5952344/how-do-i-format-a-string-using-a-dictionary-in-python-3-x
if "g" in mydict:
    print(" {g} string...".format(**mydict))
