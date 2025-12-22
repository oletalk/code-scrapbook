package main

import (
	"fmt"
)

func main() {
	var allPls []Song

	allPls, err := getAllSongs()
	if err != nil {
		panic(err)
	} else {
		// print them out
		fmt.Println(generatePlaylist(allPls, "https://foobar.org:8180"))
		song_remote := getSongLocation("ff7db7c3573e38f20e4e3a877f3ec639dbced4af")
		song_local := cachedFilename(song_remote)
		fmt.Printf("location = %s\n", song_remote)
		fmt.Printf("local file to save = %s\n", song_local)
		// TODO: don't clobber file on download...
		downloadFile(song_remote, song_local)
	}
}
