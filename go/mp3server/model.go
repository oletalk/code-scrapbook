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

type StatItem struct {
	item  string
	count int64
}

type StatDetail struct {
	item   string
	detail string
}

type StatDisplay struct {
	topArtists []StatItem
	songsToday []StatItem
	errors     []StatDetail
}

func formatStatItems(items []StatItem, itemDesc string) string {
	var sb strings.Builder
	if len(items) > 0 {
		fmt.Fprintf(&sb, "<h2>All %s</h2>", itemDesc)
		for _, s := range items {
			fmt.Fprintf(&sb, "<b>%s</b>: %d<br/>", s.item, s.count)
		}
	} else {
		fmt.Fprintf(&sb, "no %s", itemDesc)
	}
	return sb.String()
}

func formatStatDetails(items []StatDetail, itemDesc string) string {
	var sb strings.Builder
	if len(items) > 0 {
		fmt.Fprintf(&sb, "<h2>All %s</h2>", itemDesc)
		for _, s := range items {
			fmt.Fprintf(&sb, "<b>%s</b>: %s<br/>", s.item, s.detail)
		}
	} else {
		fmt.Fprintf(&sb, "no %s", itemDesc)
	}
	for _, s := range items {
		fmt.Fprintf(&sb, "<b>%s</b>: %s<br/>", s.item, s.detail)
	}
	return sb.String()
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
		displayTitle = songfrompath(s.filepath, true)
	}

	return fmt.Sprintf("%s:%d,%s\n%s/member/play/%s\n",
		EXTINF, s.secs, displayTitle, hostheader, s.hash)
}
