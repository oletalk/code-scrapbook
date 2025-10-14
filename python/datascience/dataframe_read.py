import pandas as pd

print("max rows = ", pd.options.display.max_rows)
df = pd.read_csv("data.csv")

# to_string() prints the entire DataFrame. data.csv has >170 rows
# just printing df hides most of it behind ellipses
# print(df)

# or just the top 10
print(df.head(10))

# CLEANING DATA
# new_df = df.dropna()  # optional inplace param

# find the mode
x = df["Calories"].mode()[0]
print("mode = ", x)
# replace any value of Calories that's n/a with the mode
new_df = df.fillna({"Calories": x})
# sort in descending order of Duration and then Calories column
print(new_df.sort_values(by=["Duration", "Calories"], ascending=False))
print(new_df.describe())
