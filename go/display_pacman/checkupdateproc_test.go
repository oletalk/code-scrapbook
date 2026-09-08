package main

import (
	"testing"
)

func TestWaybarFromLinux(t *testing.T) {
	s := []string{"awk 3.33 -> 3.34", "linux 3.2 -> 3.3", "pkgconf 1.1 -> 1.2"}
	expected := "<b>linux</b> 3.2 -> 3.3\nawk 3.33 -> 3.34\npkgconf 1.1 -> 1.2"

	if actual := createWaybarOutput(s); actual.Tooltip != expected {
		t.Errorf(`TestWaybarFromLinux() = %q, want %q, error`, actual.Tooltip, expected)
	}

}

func TestLongList(t *testing.T) {
	s := []string{"awk 3.33 -> 3.34", "grep 5.5 -> 5.6", "less 1.22 -> 1.23", "bat 3.56 -> 4.0", "pkgconf 1.1 -> 1.2"}
	expected := "awk 3.33 -> 3.34\ngrep 5.5 -> 5.6\nless 1.22 -> 1.23\nbat 3.56 -> 4.0\n ... more ... "

	if actual := createWaybarOutput(s); actual.Tooltip != expected {
		t.Errorf(`TestWaybarFromLinux() = %q, want %q, error`, actual.Tooltip, expected)
	}

}
