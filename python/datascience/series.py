import numpy as np
import pandas as pd

s = pd.Series(np.random.randn(6), index=["a", "b", "c", "d", "e", "z"])

print(s)

x = {"a": 3.0, "b": 5.0, "c": 4.4}

ser = pd.Series(x, index=["a", "b", "c"])
print("MEDIAN...")
print(ser.median())
print("MODE...")
print(ser.mode())
