package main

import "strings"

// get filename from path, then strip out extension
func songfrompath(path string) string {
	displayTitle := path
	if fp := strings.LastIndex(path, "/"); fp != -1 {
		displayTitle = displayTitle[fp+1:]
		displayTitle = removedSuffix(displayTitle, ".mp3")
		displayTitle = removedSuffix(displayTitle, ".MP3")
		displayTitle = removedSuffix(displayTitle, ".ogg")
	}
	return displayTitle
}

func removedSuffix(s string, suf string) string {
	if strings.HasSuffix(s, suf) {
		return s[:len(s)-len(suf)]
	}
	return s
}
