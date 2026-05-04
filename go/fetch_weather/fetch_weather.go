package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
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

	// fmt.Printf("Parsed JSON data: %+v\n", data)
	if weatherJson, rerr := createForecast(data); rerr == nil {
		// out, _ := json.Marshal(weatherJson)
		// fmt.Println(string(out))
		var outStr strings.Builder
		enc := json.NewEncoder(&outStr)
		enc.SetEscapeHTML(false)
		eerr := enc.Encode(weatherJson)
		if eerr != nil {
			fmt.Println("{\"text\": \"error\", \"tooltip\": \"error\"}")
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
