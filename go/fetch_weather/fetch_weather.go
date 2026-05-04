package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"
)

const (
	jsonFilePath = "/home/colin/.cache/openweather-new.json"
	downloadURL  = "https://api.openweathermap.org/data/3.0/onecall"
	maxAge       = 10 * time.Minute
	latitude     = "55.86"
	longitude    = "-4.25"
	units        = "metric"
	lang         = "en"
	exclusions   = "minutely"
)

func main() {
	if needsDownload(jsonFilePath) {
		fmt.Println("File is missing or older than 10 minutes, downloading...")
		apiKey := os.Getenv("API_KEY")
		if err := downloadFile(jsonFilePath, apiKey, downloadURL); err != nil {
			log.Fatalf("Failed to download file: %v", err)
		}
		fmt.Println("Download complete.")
	} else {
		fmt.Println("File is fresh, skipping download.")
	}

	data, err := parseJSON(jsonFilePath)
	if err != nil {
		log.Fatalf("Failed to parse JSON: %v", err)
	}

	fmt.Printf("Parsed JSON data: %+v\n", data)
}

// needsDownload returns true if the file doesn't exist or is older than maxAge.
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

// parseJSON reads and unmarshals the JSON file at path into a generic map.
func parseJSON(path string) (OneCallResult, error) {
	f, err := os.Open(path)
	if err != nil {
		return OneCallResult{}, fmt.Errorf("opening file: %w", err)
	}
	defer f.Close()

	var data OneCallResult
	if err := json.NewDecoder(f).Decode(&data); err != nil {
		return OneCallResult{}, fmt.Errorf("decoding JSON: %w", err)
	}
	return data, nil
}
