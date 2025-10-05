f = open("foo.txt", "rt", encoding="utf-8")
for line in f:
    print(line, end="")

f.close()
