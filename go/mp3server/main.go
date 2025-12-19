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
		songloc := getSongLocation("ff7db7c3573e38f20e4e3a877f3ec639dbced4af")
		fmt.Printf("location = %s\n", songloc)
		downloadFile(songloc, "test.mp3")
	}
}
