package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

// TODO this works, but it's not the best thing having a global variable
// better to explicitly initialise in main() and pass the db around.
var db *sql.DB

const (
	host   = "localhost"
	port   = 5432
	user   = "web"
	dbname = "postgres"
)

// record error/something else for further investigation
func recordDiagnostic(diagType string, detail string) error {
	// truncate strings to 30 and 255 characters
	var diagType_s = diagType
	if len(diagType) > 30 {
		diagType_s = diagType[0:29]
	}
	var detail_s = detail
	if len(detail) > 255 {
		detail_s = detail[0:254]
	}

	if _, perr := db.Exec("insert into mp3s_diagnostics(diag_type, details) values ($1, $2)", diagType_s, detail_s); perr != nil {
		return perr
	}
	log.Println("diagnostic info recorded")
	return nil
}

// record a song was played
func recordStat(hash string) error {
	//db, err := getConn()

	if _, perr := db.Exec("select record_mp3_stat($1)", hash); perr != nil {
		return perr
	}
	log.Println("recorded song as played")
	return nil
}

// fetch song sftp location for a given hash
func getSongLocation(hash string) (string, error) {
	pathsql := "SELECT song_filepath FROM mp3s_metadata WHERE file_hash = $1"
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
	return getSongsFor(" ORDER BY date_added")
}

// fetch latest 30 songs
func getLatestSongs() ([]Song, error) {
	return getSongsFor(" ORDER BY date_added desc LIMIT 30")
}

func getStats() (*StatDisplay, error) {
	// numbers of songs/artists played today
	rows, err := db.Query(`
	select 'SONGS' as item, sum(plays) as num
	from mp3s_stats 
	where last_played > current_date - interval '1 day'
	and category = 'SONG'
	union
	select 'ARTISTS', sum(plays)
	from mp3s_stats 
	where last_played > current_date - interval '1 day'
	and category = 'ARTIST'`)
	if err != nil {
		return nil, fmt.Errorf("getStats %v", err)
	}
	defer func() {
		if rerr := rows.Close(); rerr != nil {
			log.Println("Problem closing rows object after query: ", rerr)
		}
	}()

	var display StatDisplay
	var nums []StatItem
	var errs []StatDetail
	for rows.Next() {
		var item StatItem
		if err := rows.Scan(&item.item, &item.count); err != nil {
			return nil, fmt.Errorf("getStats %v", err)
		}
		nums = append(nums, item)
	}
	display.songsToday = nums
	nums = nil

	// top 5 artists
	rows, err = db.Query(`
	select item, plays from mp3s_stats 
	where category = 'ARTIST'
	order by plays desc limit 5;
	`)
	if err != nil {
		return nil, fmt.Errorf("getStats #1 %v", err)
	}
	defer func() {
		if rerr := rows.Close(); rerr != nil {
			log.Println("Problem closing rows object after query: ", rerr)
		}
	}()

	for rows.Next() {
		var item StatItem
		if err := rows.Scan(&item.item, &item.count); err != nil {
			return nil, fmt.Errorf("getStats #2 %v", err)
		}
		nums = append(nums, item)
	}
	display.topArtists = nums

	// today's errors if any
	rows, err = db.Query(`
	select to_char(created_at, 'Day, HH:MI:SS'), details from mp3s_diagnostics
	where created_at > current_date
	order by created_at desc
	`)
	if err != nil {
		return nil, fmt.Errorf("getStats #2 %v", err)
	}
	defer func() {
		if rerr := rows.Close(); rerr != nil {
			log.Println("Problem closing rows object after query: ", rerr)
		}
	}()

	for rows.Next() {
		var item StatDetail
		if err := rows.Scan(&item.item, &item.detail); err != nil {
			return nil, fmt.Errorf("getStats #2 %v", err)
		}
		errs = append(errs, item)
	}
	display.errors = errs
	return &display, nil
}

func getSongsFor(specifier string) ([]Song, error) {
	var songs []Song

	rows, err := db.Query("SELECT song_filepath, file_hash, artist, title, secs, date_added FROM mp3s_metadata" + specifier)
	if err != nil {
		return nil, fmt.Errorf("getAllSongs %v", err)
	}
	defer func() {
		if rerr := rows.Close(); rerr != nil {
			log.Println("Problem closing rows object after query: ", rerr)
		}
	}()

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
func initialiseDb() {
	password := os.Getenv("DBPASS")
	if password == "" {
		log.Fatal("Please provide DBPASS environment variable!")
	}
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)
	var err error
	db, err = sql.Open("postgres", psqlInfo)
	if err != nil {
		log.Fatal(err)
	}
	if err = db.Ping(); err != nil {
		log.Fatal(err)
	}
}
