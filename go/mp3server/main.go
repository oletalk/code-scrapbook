package main

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

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
