package main

import (
	"time"
)

// mp3s_metadata
type Song struct {
	filepath   string
	hash       string
	artist     string
	title      string
	secs       int
	date_added time.Time
}

// mp3s_stats
type SongStatistic struct {
	category    string
	item        string
	plays       int
	last_played time.Time
}
