package main

import (
	"fmt"
)

func main() {
	var allPls []Song

	fc, fcerr := NewFileCache()
	if fcerr != nil {
		panic(fcerr)
	}
	fmt.Printf("max cache size = %v", fc.maxSize)
	allPls, err := getAllSongs()
	if err != nil {
		panic(err)
	} else {
		// print them out
		// fmt.Println(generatePlaylist(allPls, "https://foobar.org:8180"))
		fmt.Println(len(allPls))
		song_remote, err := getSongLocation("FOX ff7db7c3573e38f20e4e3a877f3ec639dbced4af")
		if err == nil {
			song_local := cachedFilename(song_remote)
			fmt.Printf("location = %s\n", song_remote)
			fmt.Printf("local file to save = %s\n", song_local)
			// TODO: don't clobber file on download...
			downloadFile(song_remote, song_local)

		} else {
			fmt.Printf("Failed to get song location: %v\n", err)
		}
	}
}
