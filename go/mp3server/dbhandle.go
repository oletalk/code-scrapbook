package main

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/lib/pq"
)

const (
	host   = "localhost"
	port   = 5432
	user   = "web"
	dbname = "postgres"
)

var db *sql.DB

func getAllSongs() ([]Song, error) {
	var songs []Song
	// TODO initialise db...
	password := os.Getenv("DBPASS")
	if password == "" {
		fmt.Println("Please provide DBPASS environment variable!")
		os.Exit(1)
	}
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}

	// TODO check actual sql
	rows, err := db.Query("SELECT song_filepath, file_hash, artist, title, secs FROM mp3s_metadata")
	if err != nil {
		return nil, fmt.Errorf("getAllSongs %v", err)
	}
	defer rows.Close()

	// loop through rows, using Scan to assign column data to struct fields
	for rows.Next() {
		var song Song
		var strArtist, strTitle sql.NullString
		if err := rows.Scan(&song.filepath, &song.hash, &strArtist, &strTitle, &song.secs); err != nil {
			return nil, fmt.Errorf("getAllSongs %v", err)
		}
		// are the fields non-null?
		if strArtist.Valid {
			song.artist = strArtist.String
		}
		if strTitle.Valid {
			song.title = strTitle.String
		}
		songs = append(songs, song)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("getAllSongs %v", err)
	}
	return songs, nil
}
