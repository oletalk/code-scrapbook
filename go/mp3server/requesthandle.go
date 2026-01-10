package main

import (
	"log"
	"net/http"
)

type SongHandler struct {
}

func (s SongHandler) GetAllSongs(w http.ResponseWriter, r *http.Request) {

	allPls, gerr := getAllSongs()
	if gerr != nil {

		log.Printf("Error getting all songs for playlist: %v\n", gerr)
		http.Error(w, "Internal Error", http.StatusInternalServerError)
		return
	}
	// TODO get ACTUAL host header!
	hh := "http://localhost:4567"
	_, err := w.Write([]byte(generatePlaylist(allPls, hh)))
	if err != nil {
		log.Printf("Error outputting playlist: %v\n", err)
	}

}
