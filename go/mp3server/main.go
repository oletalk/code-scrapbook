package main

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	run_test()
}

func new_main() {
	go manage_cache()

	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Mount("/member", SongRoutes())
	if err := http.ListenAndServe(":4567", r); err != nil {
		panic(err)
	}
}

func SongRoutes() chi.Router {
	r := chi.NewRouter()
	songHandler := SongHandler{}
	r.Get("/m3u/all", songHandler.GetAllSongs)
	r.Get("/m3u/latest", songHandler.GetLatestSongs)
	r.Get("/play/{hash}", songHandler.FetchSong)
	return r
}
