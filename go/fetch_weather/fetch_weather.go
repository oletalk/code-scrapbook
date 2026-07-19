package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"time"
)

const (
	jsonFilePath = "/home/colin/.cache/openweather-new.json"
	downloadURL  = "https://api.openweathermap.org/data/3.0/onecall"
	maxAge       = 9 * time.Minute
	latitude     = "55.815"
	longitude    = "-4.26"
	units        = "metric"
	lang         = "en"
	exclusions   = "minutely"
	errorString  = "{\"text\": \"error\", \"tooltip\": \"error\"}"
)

func main() {
	if needsDownload(jsonFilePath) {
		// fmt.Println("File is missing or older than 10 minutes, downloading...")
		apiKey := os.Getenv("API_KEY")
		_ = downloadFile(jsonFilePath, apiKey, downloadURL)
		// log.Fatalf("Failed to download file: %v", err)
		// for waybar this is fine but ensure widget has last download time
	}
	var lastDownload string
	var chkErr error
	lastDownload, chkErr = modifiedTs(jsonFilePath)
	if chkErr != nil {
		fmt.Println(errorString)
		os.Exit(0)
	}
	data, err := parseJSON(jsonFilePath)
	if err != nil {
		//	log.Fatalf("Failed to parse JSON: %v", err)
		fmt.Println(errorString)
		os.Exit(0)
	}

	if weatherJson, rerr := createForecast(data, lastDownload); rerr == nil {
		var outStr strings.Builder
		enc := json.NewEncoder(&outStr)
		enc.SetEscapeHTML(false)
		eerr := enc.Encode(weatherJson)
		if eerr != nil {
			fmt.Println(errorString)
		} else {
			fmt.Print(outStr.String())
		}
	}
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
