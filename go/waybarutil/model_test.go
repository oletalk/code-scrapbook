package waybarutil

import (
	"testing"
)

func TestSimple(t *testing.T) {
	var w WaybarOutput
	w.Text = "hello world"
	s := []string{"one", "two", "three"}
	expected := "one\ntwo\nthree"
	w.setTooltip(s)
	if str := w.Tooltip; str != expected {
		t.Errorf(`TestSimple() = %q, want %q, error`, str, expected)
	}
}

func TestJson(t *testing.T) {
	var w WaybarOutput
	w.Text = "this is fun"
	w.setTooltip([]string{"first line", "last line!"})
	expected := "{\"text\":\"this is fun\",\"tooltip\":\"first line\\nlast line!\"}\n"
	if str, _ := w.toJson(); str != expected {
		t.Errorf(`TestSimple() = %q, want %q, error`, str, expected)
	}
}
