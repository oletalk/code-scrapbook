package main

import (
	"fmt"
)

func main() {
	var allPls []Song

	allPls, err := getAllSongs()
	if err != nil {
		panic(err)
	} else {
		// print them out
		fmt.Printf("Songs found: %v\n", allPls)
	}
}
