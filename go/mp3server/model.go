package main

import (
	"fmt"
	"strings"
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

const (
	EXTINF = "#EXTINF"
)

// generate an M3U playlist from a list of songs and the host header
func generatePlaylist(slist []Song, hostheader string) string {
	var sb strings.Builder
	sb.WriteString("#EXTM3U\n")

	for _, value := range slist {
		sb.WriteString(value.m3uline(hostheader))
	}
	return sb.String()
}

// generate line for the song in an M3U playlist. needs host header
func (s Song) m3uline(hostheader string) string {
	// if artist or title is null, use the song filepath
	var displayTitle string

	if s.artist != "" && s.title != "" {
		displayTitle = fmt.Sprintf("%s - %s", s.artist, s.title)
	} else {
		displayTitle = songfrompath(s.filepath)
	}

	return fmt.Sprintf("%s:%d,%s\n%s/member/play/%s\n",
		EXTINF, s.secs, displayTitle, hostheader, s.hash)
}
