package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

const (
	host   = "localhost"
	port   = 5432
	user   = "web"
	dbname = "postgres"
)

// fetch song sftp location for a given hash
func getSongLocation(hash string) (string, error) {
	pathsql := "SELECT song_filepath FROM mp3s_metadata WHERE file_hash = $1"
	db, err := getConn()

	if err != nil {
		return "", err
	}
	var loc string

	row := db.QueryRow(pathsql, hash)
	switch err := row.Scan(&loc); err {
	case sql.ErrNoRows:
		return "", &ApplicationError{"song not found"}
	case nil:
		return loc, nil
	default:
		return "", err
	}
}

// fetch all songs from mp3s_metadata
func getAllSongs() ([]Song, error) {
	var songs []Song
	// TODO initialise db...
	db, err := getConn()

	if err != nil {
		panic(err)
	}

	// TODO check actual sql
	rows, err := db.Query("SELECT song_filepath, file_hash, artist, title, secs, date_added FROM mp3s_metadata ORDER BY date_added")
	if err != nil {
		return nil, fmt.Errorf("getAllSongs %v", err)
	}
	defer rows.Close()

	// loop through rows, using Scan to assign column data to struct fields
	for rows.Next() {
		var song Song
		var strArtist, strTitle sql.NullString
		if err := rows.Scan(&song.filepath, &song.hash, &strArtist, &strTitle, &song.secs, &song.date_added); err != nil {
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

// get a connection from the database
func getConn() (*sql.DB, error) {
	password := os.Getenv("DBPASS")
	if password == "" {
		log.Fatal("Please provide DBPASS environment variable!")
	}
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	return sql.Open("postgres", psqlInfo)
}
