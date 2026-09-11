package main

import (
	"encoding/json"
	"strconv"
	"strings"
	"time"
)

func getJournalEntry(str string) (JournalEntry, error) {
	var data JournalEntry
	reader := strings.NewReader(str)
	if err := json.NewDecoder(reader).Decode(&data); err != nil {
		return data, err
	} else {
		return data, nil
	}
}

func unixMicroTimestamptostring(timestampstr string) (string, error) {
	i, err := strconv.ParseInt(timestampstr, 10, 64)
	if err != nil {
		return "", err
	} else {
		tm := time.UnixMicro(i)
		// just want the date and time
		return tm.Format("2006-01-02 15:04:05"), nil
	}
}
