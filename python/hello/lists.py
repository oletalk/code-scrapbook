colors = ["red", "orange", "yellow", "green", "blue", "indigo"]
colors.append("violet")
print(colors[2])

i = 0
for num in colors:
    i += 1
    print("word = ", num, " (length ", len(num), ")")

print("i counted ", i, " colours.")
colors.sort()  # sort in place
print("list = ", colors)
