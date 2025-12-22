package main

import (
	"crypto/sha1"
	"fmt"
	"strings"
)

// get filename from path, then optionally strip out extension
func songfrompath(path string, removeSuffix bool) string {
	displayTitle := path
	if fp := strings.LastIndex(path, "/"); fp != -1 {
		displayTitle = displayTitle[fp+1:]
		if removeSuffix {
			displayTitle = removedSuffix(displayTitle, ".mp3")
			displayTitle = removedSuffix(displayTitle, ".MP3")
			displayTitle = removedSuffix(displayTitle, ".ogg")
		}
	}
	return displayTitle
}

func removedSuffix(s string, suf string) string {
	if strings.HasSuffix(s, suf) {
		return s[:len(s)-len(suf)]
	}
	return s
}

// construct filename needed to save a newly downloaded song file in cache location
func cachedFilename(filename string) string {
	data := []byte(filename)
	// first 6 characters of this, underscore then base filename
	fullhash := fmt.Sprintf("%x", sha1.Sum(data))[:6]
	basename := songfrompath(filename, false)
	return fullhash + "_" + basename
}
