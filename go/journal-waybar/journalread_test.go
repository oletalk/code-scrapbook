package main

import (
	"strconv"
	"testing"
)

type ParseTestCase struct {
	input          string
	expectedOutput JournalEntry
}

func TestParseLine(t *testing.T) {
	for ind, c := range allTestCases() {
		journalEntry, _ := getJournalEntry(c.input)
		if expected, actual := entryFirstDiff(journalEntry, c.expectedOutput); actual != "" {
			throwError(t, "TestParseLine", "test #"+strconv.Itoa(ind), expected, actual)
		}
	}
}

func TestInterestingEvents(t *testing.T) {
	var artifacts EventFlags
	expectedArtifacts := "↩️"
	for _, c := range allTestCases() {
		entry, _ := getJournalEntry(c.input)
		findArtifacts(entry, &artifacts)
	}
	if artifacts.display() != expectedArtifacts {
		throwError(t, "TestInterestingEvents", "test", expectedArtifacts, artifacts.display())
	}

}

func entryFirstDiff(a, b JournalEntry) (string, string) {
	if a.Hostname != b.Hostname {
		return a.Hostname, b.Hostname
	}
	if a.Message != b.Message {
		return string(a.Message), string(b.Message)
	}
	if a.ProcessId != b.ProcessId {
		return a.ProcessId, b.ProcessId
	}
	if a.Priority != b.Priority {
		return a.Priority, b.Priority
	}
	if a.Identifier != b.Identifier {
		return a.Identifier, b.Identifier
	}
	if a.RealtimeTimestamp != b.RealtimeTimestamp {
		return a.RealtimeTimestamp, b.RealtimeTimestamp
	}
	return "", ""
}

func throwError(t *testing.T, testname, input, expected, actual string) {
	t.Errorf(`Test %q Failed: input %q expected: %q, actual: %q`, testname, input, expected, actual)
}

func allTestCases() []ParseTestCase {
	return []ParseTestCase{
		{
			input: `{"_COMM":"smtpd","_CAP_EFFECTIVE":"0","SYSLOG_IDENTIFIER":"postfix/smtpd","_HOSTNAME":"andres","_EXE":"/usr/lib/postfix/bin/smtpd","PRIORITY":"6","_RUNTIME_SCOPE":"system","_CMDLINE":"smtpd -n smtp -t inet -u -o stress= -s 2","__REALTIME_TIMESTAMP":"1789228152650438","_BOOT_ID":"008efef50f404b3fabc40080aa3eb46e","SYSLOG_PID":"314894","__CURSOR":"s=e78b838844e74ae493345c409fcf1038;i=120a6a;b=008efef50f404b3fabc40080aa3eb46e;m=6c571b897;t=65b4b2475fac6;x=f3e4b22e42be6a22","_SOURCE_REALTIME_TIMESTAMP":"1789228152650416","SYSLOG_TIMESTAMP":"Sep 12 16:49:12 ","_PID":"314894","__MONOTONIC_TIMESTAMP":"29082368151","SYSLOG_FACILITY":"2","__SEQNUM_ID":"e78b838844e74ae493345c409fcf1038","_SYSTEMD_SLICE":"system.slice","_SYSTEMD_CGROUP":"/system.slice/postfix.service","_SYSTEMD_INVOCATION_ID":"37095c77bbbd4b01bbb094839a39b5a1","_GID":"73","MESSAGE":"NOQUEUE: reject: RCPT from unknown[91.92.41.82]: 554 5.7.1 <verify@test.com>: Relay access denied; from=<test@test.com> to=<verify@test.com> proto=ESMTP helo=<test.com>","_TRANSPORT":"syslog","_SYSTEMD_UNIT":"postfix.service","_UID":"73","__SEQNUM":"1182314","_MACHINE_ID":"8c51667e64d4480d81d19a21822e19e6"}`,
			expectedOutput: JournalEntry{
				Hostname:          "andres",
				Message:           JournalMessage("NOQUEUE: reject: RCPT from unknown[91.92.41.82]: 554 5.7.1 <verify@test.com>: Relay access denied; from=<test@test.com> to=<verify@test.com> proto=ESMTP helo=<test.com>"),
				Identifier:        "postfix/smtpd",
				ProcessId:         "314894",
				Priority:          "6",
				RealtimeTimestamp: "1789228152650438",
			},
		},
		{
			input: `{"JOB_RESULT":"done","_SYSTEMD_CGROUP":"/init.scope","SYSLOG_IDENTIFIER":"systemd","_UID":"0","_RUNTIME_SCOPE":"system","JOB_TYPE":"start","_MACHINE_ID":"8c51667e64d4480d81d19a21822e19e6","SYSLOG_FACILITY":"3","MESSAGE":"Started Disk Manager.","_PID":"1","_CMDLINE":"/usr/lib/systemd/systemd --switched-root --system --deserialize=54","__CURSOR":"s=e78b838844e74ae493345c409fcf1038;i=120997;b=008efef50f404b3fabc40080aa3eb46e;m=3995416;t=65b44629d9646;x=d6c17d27f4813d72","__SEQNUM":"1182103","__REALTIME_TIMESTAMP":"1789199130662470","TID":"1","_EXE":"/usr/lib/systemd/systemd","UNIT":"udisks2.service","CODE_FILE":"src/core/job.c","CODE_FUNC":"job_emit_done_message","_BOOT_ID":"008efef50f404b3fabc40080aa3eb46e","_SYSTEMD_SLICE":"-.slice","CODE_LINE":"825","__MONOTONIC_TIMESTAMP":"60380182","_SYSTEMD_UNIT":"init.scope","MESSAGE_ID":"39f53479d3a045ac8e11786248231fbf","_GID":"0","_CAP_EFFECTIVE":"1ffffffffff","PRIORITY":"6","JOB_ID":"2190","INVOCATION_ID":"c7d9efff487c408084b24020e728b547","_COMM":"systemd","_SOURCE_REALTIME_TIMESTAMP":"1789199130662461","_HOSTNAME":"andres","_TRANSPORT":"journal","__SEQNUM_ID":"e78b838844e74ae493345c409fcf1038"}`,
			expectedOutput: JournalEntry{
				Hostname:          "andres",
				Message:           JournalMessage("Started Disk Manager."),
				ProcessId:         "1",
				Priority:          "6",
				Identifier:        "systemd",
				RealtimeTimestamp: "1789199130662470",
			},
		},
		{
			input: `{"_EXE":"/usr/bin/niri","_MACHINE_ID":"8c51667e64d4480d81d19a21822e19e6","_SYSTEMD_USER_UNIT":"niri.service","_SYSTEMD_CGROUP":"/user.slice/user-1000.slice/user@1000.service/session.slice/niri.service","__CURSOR":"s=e78b838844e74ae493345c409fcf1038;i=12099a;b=008efef50f404b3fabc40080aa3eb46e;m=412cc99;t=65b4463170ec8;x=aa76158b529d8309","_STREAM_ID":"3d86e0fa4a11459c86dcb604b96efe0e","_BOOT_ID":"008efef50f404b3fabc40080aa3eb46e","_AUDIT_SESSION":"3","_HOSTNAME":"andres","PRIORITY":"6","_SYSTEMD_INVOCATION_ID":"4ea96ca1b53c4479b96529e17ba1939f","__MONOTONIC_TIMESTAMP":"68340889","_CMDLINE":"niri --session","__REALTIME_TIMESTAMP":"1789199138623176","_SYSTEMD_OWNER_UID":"1000","_SYSTEMD_SLICE":"user-1000.slice","_AUDIT_LOGINUID":"1000","MESSAGE":[101,105,103,104,116,32,49,49,53,53,32,62,32,56,57,52,41],"_CAP_EFFECTIVE":"0","__SEQNUM":"1182106","_GID":"1000","_SYSTEMD_USER_SLICE":"session.slice","_RUNTIME_SCOPE":"system","_UID":"1000","_SYSTEMD_UNIT":"user@1000.service","_COMM":"niri","_TRANSPORT":"stdout","__SEQNUM_ID":"e78b838844e74ae493345c409fcf1038","SYSLOG_IDENTIFIER":"niri","SYSLOG_FACILITY":"3","_PID":"1000"}`,
			expectedOutput: JournalEntry{
				Hostname:          "andres",
				Message:           JournalMessage("eight 1155 > 894)"),
				ProcessId:         "1000",
				Priority:          "6",
				Identifier:        "niri",
				RealtimeTimestamp: "1789199138623176",
			},
		},
	}
}
