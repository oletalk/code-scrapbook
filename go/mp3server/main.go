package main

import (
	"fmt"
	"log"
)

func main() {
	var allPls []Song

	fc, fcerr := NewFileCache()
	if fcerr != nil {
		panic(fcerr)
	}
	log.Printf("(config) max cache size = %v\n", fc.maxSize)
	log.Printf("(actual) cache current size = %d\n", fc.currentSize())

	allPls, err := getAllSongs()
	if err != nil {
		panic(err)
	} else {
		// print them out
		// fmt.Println(generatePlaylist(allPls, "https://foobar.org:8180"))
		fmt.Printf("number of songs in playlist = %d\n", len(allPls))
		song_remote, err := getSongLocation("FOO ff7db7c3573e38f20e4e3a877f3ec639dbced4af")
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
