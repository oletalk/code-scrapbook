package main

import (
	"log"
)

// this was originally in main.go but i'm cleaning it up
func run_test() {
	/*
		  test run:
			1. load up a playlist of all songs
			2. print a few stats from this
			3. get song location for a particular (known) hash
			4. check if it's in the cache
			5. if it is, STOP
			6. download the file for the given hash from the SFTP server
			7. downsample to a temporary file
			8. replace the file in the cache with this file
	*/
	var allPls []Song

	fc, fcerr := NewFileCache()
	if fcerr != nil {
		panic(fcerr)
	}
	pgerr := fc.prune()
	if pgerr != nil {
		log.Printf("Unable to prune cache dir: %v", pgerr)
	}

	allPls, err := getAllSongs()
	if err != nil {
		panic(err)
	} else {
		// print them out
		// fmt.Println(generatePlaylist(allPls, "https://foobar.org:8180"))
		log.Printf("number of songs in playlist = %d\n", len(allPls))
		if song_remote, err := getSongLocation("ff7db7c3573e38f20e4e3a877f3ec639dbced4af"); err == nil {
			// if err == nil {
			song_local := filenameForCache(song_remote)
			log.Printf("location = %s\n", song_remote)
			log.Printf("local file to save = %s\n", song_local)
			// don't clobber file on download...
			if songInCache(song_local) {
				log.Println("song is already in cache")
			} else {
				if dlerr := downloadFile(song_remote, song_local); dlerr == nil {
					log.Println("download completed.")
					// try downsampling it
					if err := processDownsampleAndReplace("MP3", cacheFilename(song_local)); err != nil {
						log.Printf("Downsampling failed: %v\n", err)
					}
				} else {
					log.Printf("Error downloading file: %v\n", dlerr)
				}
			}

		} else {
			log.Printf("Failed to get song location: %v\n", err)
		}
	}
}
