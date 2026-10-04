package main

import (
	"testing"
)

type JournalEntryTestCase struct {
	jentry         JournalEntry
	expectedResult string
}

func TestProcessDisplay(t *testing.T) {
	testcases := []JournalEntryTestCase{
		{
			jentry: JournalEntry{
				Identifier: "kernel",
				Message:    "a kernel message",
			},
			expectedResult: "kernel",
		},
		{
			jentry: JournalEntry{
				CommandLine: "cat /etc/fstab",
				Message:     "some nonsense",
			},
			expectedResult: "cat",
		},
		{
			jentry: JournalEntry{
				Message: "worst case",
			},
			expectedResult: "❔",
		},
	}

	for n, testcase := range testcases {
		if actualName := testcase.jentry.processDisplay(); actualName != testcase.expectedResult {
			t.Errorf(`TestProcessDisplay#%d = %q, want %q, error`, n, actualName, testcase.expectedResult)
		}
	}
}

func TestCompileStats(t *testing.T) {
	js := new(JournalStats)
	e1 := JournalEntry{
		Identifier: "kernel",
		Message:    JournalMessage("Blacklist DROP: IN eth0 ..."),
	}
	e2 := JournalEntry{
		Identifier: "postfix",
		Message:    JournalMessage("NOQUEUE: rejected!"),
	}
	e3 := JournalEntry{
		Identifier: "postfix",
		Message:    JournalMessage("disconnect from spammer.com"),
	}
	js.processEntry(e1)
	js.processEntry(e2)
	js.processEntry(e3)
	if actual := js.currNameCount; actual != 2 {
		t.Errorf(`CompileStats#1 = %d, want 2, error`, actual)
	}
	if actualName := js.currName; actualName != "postfix" {
		t.Errorf(`CompileStats#2 = %q, want 'postfix', error`, actualName)
	}
	expectedFlags := "(recently:ip-blacklist)"
	if actualFlags := js.artifacts.getFlags(); actualFlags != expectedFlags {
		t.Errorf(`CompileStats#3 = %q, want '%q', error`, actualFlags, expectedFlags)
	}
}
