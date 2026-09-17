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
func findArtifacts(entry JournalEntry, artifacts *EventFlags) {
	message := string(entry.Message)
	if entry.Identifier == "apcupsd" {
		artifacts.ApcupsdEvent = true
	}
	if strings.HasSuffix(entry.Identifier, "smtpd") && strings.Contains(message, "NOQUEUE") {
		artifacts.PostfixNoqueue = true
	}
	if strings.HasSuffix(entry.Identifier, "local") && strings.Contains(message, "status=sent") {
		artifacts.PostfixDelivery = true
	}
	if entry.Identifier == "kernel" && strings.Contains(message, "DROP:") {
		artifacts.NftablesBlacklist = true
	}
	if entry.Identifier == "vdirsyncer" && strings.Contains(message, "updating") {
		artifacts.VdirSyncerUpdate = true
	}
	if entry.Identifier == "kernel" && strings.Contains(message, "USB device found") {
		artifacts.UsbConnect = true
	}
	if entry.Identifier == "kernel" && strings.Contains(message, "USB disconnect") {
		artifacts.UsbDisconnect = true
	}
	if entry.Identifier == "systemd-coredump" && strings.Contains(message, "dumped core") {
		artifacts.CoreDumped = true
	}
}
