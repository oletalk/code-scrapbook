s = "hi"
print(s.upper() + " there")

print(str(3.14) + "\n thing")

oth = "this is a Big string"
if oth.find("Big") != -1:  # int result, -1 if fail
    print("found big")

for value in oth.split():
    print("value = ", value)

print(oth.replace("Big", "small"))
