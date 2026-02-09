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
	if allPls, gerr := getAllSongs(); gerr != nil {

		log.Printf("Error getting all songs for playlist: %v\n", gerr)
		http.Error(w, "Internal Error", http.StatusInternalServerError)
		return
	} else {
		writeResults(w, r, allPls)
	}
}

func (s SongHandler) GetLatestSongs(w http.ResponseWriter, r *http.Request) {
	log.Printf("GetLatestSongs called")
	if allPls, gerr := getLatestSongs(); gerr != nil {

		log.Printf("Error getting latest songs for playlist: %v\n", gerr)
		http.Error(w, "Internal Error", http.StatusInternalServerError)
		return
	} else {
		writeResults(w, r, allPls)
	}
}

func writeResults(w http.ResponseWriter, r *http.Request, songs []Song) {
	hostHeader := GetHostHeader(r)
	if _, err := w.Write([]byte(generatePlaylist(songs, hostHeader))); err != nil {
		log.Printf("Error outputting playlist: %v\n", err)
	}

}

func GetHostHeader(r *http.Request) string {
	hostHeader := r.Host
	// check if behind proxy
	if proto := r.Header.Get("X-Forwarded-Proto"); proto != "" {
		hostHeader = proto + "://" + hostHeader
	} else if r.TLS != nil {
		hostHeader = "https://" + hostHeader
	} else {
		hostHeader = "http://" + hostHeader
	}
	return hostHeader
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
				// downsample and replace (see sample_run.go)
				filetype := downsampleType(song_local)
				if err := processDownsampleAndReplace(filetype, cacheFilename(song_local)); err != nil {
					log.Printf("Downsampling failed: %v\n", err)
				}
			} else {
				log.Printf("Error downloading file: %v\n", dlerr)
			}
		}

		// stream locally downloaded file
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
