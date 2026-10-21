package main

import (
	"encoding/json"
	"regexp"
	"strconv"
	"strings"
	"time"
)

var ansiRe = regexp.MustCompile(`\x1b\[[0-9;?]*[ -/]*[@-~]`)

func stripCSIEscSequences(s string) string {
	return ansiRe.ReplaceAllString(s, "")
}

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
		artifacts.ApcupsdEvent++
	}
	if strings.HasSuffix(entry.Identifier, "smtpd") && strings.Contains(message, "NOQUEUE") {
		if strings.Contains(message, "Relay access") {
			artifacts.PostfixNoRelay++
		} else {
			artifacts.PostfixNoqueue++
		}
	}
	if strings.HasSuffix(entry.Identifier, "local") && strings.Contains(message, "status=sent") {
		artifacts.PostfixDelivery++
	}
	if entry.Identifier == "kernel" && strings.Contains(message, "DROP:") {
		artifacts.NftablesBlacklist++
	}
	if entry.Identifier == "vdirsyncer" && (strings.Contains(message, "updating") || strings.Contains(message, "Copying")) {
		artifacts.VdirSyncerUpdate++
	}
	if entry.Identifier == "kernel" && strings.Contains(message, "USB device found") {
		artifacts.UsbConnect++
	}
	if entry.Identifier == "kernel" && strings.Contains(message, "USB disconnect") {
		artifacts.UsbDisconnect++
	}
	if entry.Identifier == "systemd-coredump" && strings.Contains(message, "dumped core") {
		artifacts.CoreDumped++
	}
	if entry.Identifier == "systemd" && strings.Contains(message, "Failed with") {
		artifacts.ServiceFailed++
	}
	if entry.Identifier == "auth" && strings.Contains(message, "fail") && strings.Contains(message, "dovecot") {
		artifacts.DovecotAuthFailure++
	}
	if entry.Priority == "3" || entry.Priority == "2" || entry.Priority == "1" {
		artifacts.HighPriorityMessage++
	}
}
