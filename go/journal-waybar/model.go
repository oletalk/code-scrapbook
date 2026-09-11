package main

type JournalEntry struct {
	Identifier        string `json:"SYSLOG_IDENTIFIER"`
	Message           string `json:"MESSAGE"`
	Priority          string `json:"PRIORITY"`
	CommandLine       string `json:"CMDLINE"`
	ProcessId         string `json:"_PID"`
	UserId            string `json:"_UID"`
	Hostname          string `json:"_HOSTNAME"`
	RealtimeTimestamp string `json:"__REALTIME_TIMESTAMP"`
}
