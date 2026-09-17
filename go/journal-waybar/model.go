package main

import (
	"encoding/json"
	"fmt"
	"strings"
)

/* flags for interesting events in journal */
type EventFlags struct {
	PostfixNoqueue    bool
	PostfixDelivery   bool
	NftablesBlacklist bool
	ApcupsdEvent      bool
	VdirSyncerUpdate  bool
	UsbConnect        bool
	UsbDisconnect     bool
	CoreDumped        bool
}

type JournalStats struct {
	currNameCount int
	currName      string
	currEntry     JournalEntry
	artifacts     EventFlags
}

/* keep track of current entry and number of journal entries so far with entry identifier, as well as any interesting artifacts  */
func (j *JournalStats) processEntry(entry JournalEntry) {
	processName := entry.Identifier
	if processName != j.currName {
		j.currName = processName
		j.currNameCount = 1
	} else {
		j.currNameCount++
	}
	j.currEntry = entry
	findArtifacts(entry, &(j.artifacts))
}

type EmojiLookup struct {
	flag    bool
	emoji   string
	details string
}

func eventFlagLookup(f EventFlags) []EmojiLookup {
	return []EmojiLookup{
		{f.PostfixNoqueue, "↩️", "smtpd-noqueue"},
		{f.PostfixDelivery, "📥", "mail-delivery"},
		{f.NftablesBlacklist, "🙅‍♀️", "ip-blacklist"},
		{f.ApcupsdEvent, "⚡", "apcupsd-event"},
		{f.VdirSyncerUpdate, "📆", "new-cal-event"},
		{f.UsbConnect, "🤝", "new-usb-device"},
		{f.UsbDisconnect, "🔌", "usb-disconnect"},
		{f.CoreDumped, "💥", "core-dumped"},
	}
}

func (f EventFlags) display() string {
	var sb strings.Builder
	for _, e := range eventFlagLookup(f) {
		if e.flag {
			sb.WriteString(e.emoji)
		}
	}
	return sb.String()
}
func (f EventFlags) getFlags() string {
	var flist []string
	for _, e := range eventFlagLookup(f) {
		if e.flag {
			flist = append(flist, e.details)
		}
	}
	if len(flist) > 0 {
		return "(recently:" + strings.Join(flist, ",") + ")"
	} else {
		return ""
	}
}

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
