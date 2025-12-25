package main

import (
	"fmt"
	"os"
	"strconv"
)

// representation of the cache directory
type FileCache struct {
	cacheDir string
	maxSize  int64
}

// returns the file cache where location and max total size were specified in application config
func NewFileCache() (*FileCache, error) {
	// get cacheDir from OS
	cacheDir := os.Getenv("CACHE_DIR")
	if cacheDir == "" {
		return nil, &ApplicationError{"CACHE_DIR not set"}
	}

	maxSizeStr := os.Getenv("MAX_TOTAL_SIZE_KB")
	if maxSizeStr == "" {
		return nil, &ApplicationError{"MAX_TOTAL_SIZE_KB not set"}
	}
	maxSize, err := strconv.ParseInt(maxSizeStr, 10, 64)
	if err != nil {
		return nil, &ApplicationError{fmt.Sprintf("invalid MAX_TOTAL_SIZE_KB value: %s", maxSizeStr)}
	}

	// Create cache directory if it doesn't exist
	if err := os.MkdirAll(cacheDir, 0755); err != nil {
		return nil, &ApplicationError{fmt.Sprintf("failed to create cache directory: %v", err)}
	}

	return &FileCache{
		cacheDir: cacheDir,
		maxSize:  maxSize,
	}, nil
}
