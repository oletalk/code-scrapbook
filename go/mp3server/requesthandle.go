package main

import (
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/go-chi/chi/v5"
)

type SongHandler struct {
}

func (s SongHandler) GetAllSongs(w http.ResponseWriter, r *http.Request) {
	log.Printf("GetAllSongs called")
	allPls, gerr := getAllSongs()
	if gerr != nil {

		log.Printf("Error getting all songs for playlist: %v\n", gerr)
		http.Error(w, "Internal Error", http.StatusInternalServerError)
		return
	}
	// TODO get ACTUAL host header!
	// hh := "http://localhost:4567"

	hh := r.Host
	if r.TLS != nil {
		hh = "https://" + hh
	} else {
		hh = "http://" + hh
	}
	_, err := w.Write([]byte(generatePlaylist(allPls, hh)))
	if err != nil {
		log.Printf("Error outputting playlist: %v\n", err)
	}

}

func (s SongHandler) FetchSong(w http.ResponseWriter, r *http.Request) {
	songhash := chi.URLParam(r, "hash")
	log.Printf("FetchSong called for %s", songhash)
	if song_remote, err := getSongLocation(songhash); err == nil {
		song_local := filenameForCache(song_remote)
		if songInCache(song_local) {
			log.Println("song is already in cache")
		} else {
			if dlerr := downloadFile(song_remote, song_local); dlerr == nil {
				log.Println("download completed.")
			} else {
				log.Printf("Error downloading file: %v\n", dlerr)
			}
		}
		// TODO stream locally downloaded file
		filePath := getCacheFilepath(song_local)
		file, err := os.Open(filePath)
		if err != nil {
			http.Error(w, "File not found", 404)
			return
		}
		defer file.Close()

		fileStat, err := file.Stat()
		if err != nil {
			http.Error(w, "Internal server error", 500)
			return
		}

		w.Header().Set("Content-Type", r.Header.Get("Content-Type"))
		w.Header().Set("Content-Length", strconv.FormatInt(fileStat.Size(), 10))

		// stream the file
		http.ServeContent(w, r, song_local, fileStat.ModTime(), file)
	}
}
