package main

import (
	"encoding/json"
	"fmt"
)

type JournalMessage string

// TODO: use test cases from ~/journal-json-extract.txt ok?
func (m *JournalMessage) UnmarshalJSON(data []byte) error {
	if len(data) > 0 && data[0] == '"' {
		var s string
		if err := json.Unmarshal(data, &s); err != nil {
			return err
		}
		*m = JournalMessage(s)
		return nil
	}

	// Not a string -> it's an array of byte values
	var b []byte
	if err := json.Unmarshal(data, &b); err != nil {
		return fmt.Errorf("MESSAGE field is neither string nor byte array: %w", err)
	}
	*m = JournalMessage(b)
	return nil
}

type JournalEntry struct {
	Identifier        string         `json:"SYSLOG_IDENTIFIER"`
	Message           JournalMessage `json:"MESSAGE"`
	Priority          string         `json:"PRIORITY"`
	CommandLine       string         `json:"CMDLINE"`
	ProcessId         string         `json:"_PID"`
	UserId            string         `json:"_UID"`
	Hostname          string         `json:"_HOSTNAME"`
	RealtimeTimestamp string         `json:"__REALTIME_TIMESTAMP"`
}

func (j JournalEntry) processDisplay() string {
	processInd := j.Identifier
	if j.ProcessId != "" {
		processInd = processInd + " [" + j.ProcessId + "]"
	}
	return processInd
}
