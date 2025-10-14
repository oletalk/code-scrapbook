import pandas as pd

df = pd.read_csv("/var/tmp/mp3s_stats_20251003.csv")
# category, item details, number of plays, time last played
# sample rows:
#      TITLE      Whitney Houston - Nobody Loves Me Like You Do      2  2025-10-02 17:03:12.025021
#     ARTIST                                   Dinah Washington      1   2025-10-02 17:05:44.97063
#       SONG  /rockport/mp3/napsharefc20080207/Dinah Washing...      1   2025-10-02 17:05:44.97063

# deal with the last column as datetimes...
# print(pd.to_datetime(df["last_played"]))
# CONVERT this column to datetime
df["last_played"] = pd.to_datetime(df["last_played"])
print(df.info())

# can we answer these questions?
# 1. most recently played song
songs = df[df["category"] == "TITLE"]
artists = df[df["category"] == "ARTIST"]

playsort = songs.sort_values(by=["last_played"]).tail(1)
print("most recently played song = ")
print(playsort)
# 2. song with the most plays
print("song with the most plays:")
mostplayed = songs.sort_values(by="plays").tail(1)
print(mostplayed)
# ORRR, easier way of specifying top-n :-)
print(songs.nlargest(3, "plays"))
# 3. number of songs played
print("number of songs played:")
print(len(songs.index))
# 4. most popular artist
print("most popular artist:")
print(artists.nlargest(1, "plays"))
# 5. artists having over 3 plays of any of their songs (could be the same song repeatedly, or four different songs)
# (this is just how the data is stored/compiled in mp3s_stats!)
print("artists played over 6 times:")
print(artists[artists["plays"] > 6].sort_values(by="plays"))
