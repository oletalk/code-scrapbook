import pandas as pd

# NOTE!!!
# This program uses libraries that have been installed in a virtual environment, 'debugpy', that you created in 10/2025.
# This means you should activate this environment ASAP, e.g. with the swenv.vim plugin.
#      so that the terminal has access to these libraries and can run this program.
# Updating nvim-dap-python, in order to debug Python programs, will also require you to do this.
# Series
a = {"foo": 1, "bar": 7, "baz": 2}
myvar = pd.Series(a, index=["baz"])
print(myvar)

# DataFrames
data = {"calories": [420, 380, 390], "duration": [50, 40, 45]}

myvar = pd.DataFrame(data)
# first row
print(myvar.loc[0])
