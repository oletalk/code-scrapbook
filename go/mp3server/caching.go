package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"strconv"
	"time"
)

const MAX_DELETES = 5

type FileInfo struct {
	name       string
	size       int64
	accessTime time.Time
}

// representation of the cache directory
type FileCache struct {
	cacheDir string
	maxSize  int64
	files    []FileInfo
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
	log.Printf("Cache directory: %s\n", cacheDir)
	// read files in directory and create FileInfo entries
	entries, err := getFileInfos(cacheDir)
	if err != nil {
		return nil, err
	}
	log.Printf("Number of files in cache: %d\n", len(entries))
	return &FileCache{
		cacheDir: cacheDir,
		maxSize:  maxSize,
		files:    entries,
	}, nil
}

func cacheFilename(filename string) string {
	cache_dir := os.Getenv("CACHE_DIR")
	return cache_dir + "/" + filename
}

// is a song with this filename in the cache?
func songInCache(filename string) bool {
	_, err := os.Stat(cacheFilename(filename))
	return !errors.Is(err, os.ErrNotExist)
}

// current total size of files in the cache
func (f FileCache) currentSize() int64 {
	var total int64 = 0
	for _, entry := range f.files {
		total += entry.size
	}
	return total
}

// deletes the oldest file in the cache if it is over the maxSize.
func (f *FileCache) prune() error {
	log.Printf("(actual) cache current size = %d\n", f.currentSize())
	if f.maxSize < f.currentSize() {
		log.Println("PRUNE NEEDED")
		// get oldest file and delete it
		if oldest, oerr := f.oldestFile(); oerr == nil {
			log.Printf("*** removing %s/%s (%dK)\n", f.cacheDir, oldest.name, oldest.size)
			// delete file
			if err := os.Remove(cacheFilename(oldest.name)); err != nil {
				log.Printf("error removing file: %v", err)
			}
		} else {
			log.Printf("error figuring out oldest file: %v", oerr)
		}

		// now refresh cache from OS
		if newFiles, nferr := getFileInfos(f.cacheDir); nferr == nil {
			f.files = newFiles
			log.Printf("(updated) cache current size = %d\n", f.currentSize())
		}

	}
	return nil
}

func getFileInfos(dir string) ([]FileInfo, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	files := []FileInfo{}

	for _, entry := range entries {
		if !entry.IsDir() {
			fin := FileInfo{name: entry.Name()}
			fs, err := entry.Info()
			if err == nil {
				fin.size = fs.Size() / 1024
				fin.accessTime = fs.ModTime()
			} else {
				fmt.Printf("error getting file info for %s: %v\n", entry.Name(), err)
			}
			// fmt.Printf("DEBUG: %v\n", fin)
			files = append(files, fin)
		}

	}
	return files, nil
}

func (f FileCache) oldestFile() (*FileInfo, error) {
	tme := time.Now()
	var old FileInfo
	found := false
	for _, fi := range f.files {
		if fi.accessTime.Before(tme) {
			old = fi
			tme = fi.accessTime
			found = true
		}

	}
	if found {
		return &old, nil
	} else {
		return nil, &ApplicationError{"No values in list"}
	}
}

func manage_cache() {
	fc, fcerr := NewFileCache()
	if fcerr != nil {
		panic(fcerr)
	}

	// periodically prune
	for {
		log.Printf("checking if cache directory needs pruning.")
		pgerr := fc.prune()
		if pgerr != nil {
			log.Printf("Unable to prune cache dir: %v", pgerr)
		}
		time.Sleep(time.Minute * 1)
	}
}
