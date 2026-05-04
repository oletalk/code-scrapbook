package main

// needsDownload returns true if the file doesn't exist or is older than maxAge.

import (
	"log"
	"os"
	"os/exec"
	"time"
)

func needsDownload(path string) bool {
	info, err := os.Stat(path)
	if os.IsNotExist(err) {
		return true
	}
	if err != nil {
		log.Printf("Warning: could not stat file: %v", err)
		return true
	}
	return time.Since(info.ModTime()) > maxAge
}

// downloadFile uses curl to download from url into dest.
func downloadFile(dest, apiKey, url string) error {
	fullUrl := url + "?lat=" + latitude + "&lon=" + longitude + "&appid=" + apiKey + "&cnt=5&units=" + units + "&lang=" + lang + "&exclude=" + exclusions
	cmd := exec.Command("curl", "-fsSL", "-o", dest, fullUrl)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
