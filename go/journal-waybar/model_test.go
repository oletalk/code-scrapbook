package main

import (
	"testing"
)

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
