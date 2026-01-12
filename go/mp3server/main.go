package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func run_test() {
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
		fmt.Printf("number of songs in playlist = %d\n", len(allPls))
		if song_remote, err := getSongLocation("ff7db7c3573e38f20e4e3a877f3ec639dbced4af"); err == nil {
			// if err == nil {
			song_local := filenameForCache(song_remote)
			fmt.Printf("location = %s\n", song_remote)
			fmt.Printf("local file to save = %s\n", song_local)
			// don't clobber file on download...
			if songInCache(song_local) {
				fmt.Println("song is already in cache")
			} else {
				if dlerr := downloadFile(song_remote, song_local); dlerr == nil {
					// TODO stream locally downloaded file
					fmt.Println("download completed.")
				} else {
					fmt.Printf("Error downloading file: %v\n", dlerr)
				}
			}

		} else {
			fmt.Printf("Failed to get song location: %v\n", err)
		}
	}
}

func main() {
	// run_test()
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Mount("/member", SongRoutes())
	http.ListenAndServe(":4567", r)
}

func SongRoutes() chi.Router {
	r := chi.NewRouter()
	songHandler := SongHandler{}
	r.Get("/m3u/all", songHandler.GetAllSongs)
	r.Get("/play/{hash}", songHandler.FetchSong)
	return r
}
