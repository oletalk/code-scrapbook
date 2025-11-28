import re

str = "an example word:cat!!"
match = re.search(r"word:\w\w\w", str)
if match:
    print("found", match.group())
else:
    print("sorry, nothing found")
