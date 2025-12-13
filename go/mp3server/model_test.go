package main

import (
	"testing"
)

func TestM3uLine(t *testing.T) {
	s := Song{filepath: "/path/to/foo.mp3", hash: "foeijflk", secs: 222, artist: "Me", title: "My Song"}
	hh := "http://bar.org:2222"
	expected := "#EXTINF:222,Me - My Song\nhttp://bar.org:2222/member/play/foeijflk\n"
	if str := s.m3uline(hh); str != expected {
		t.Errorf(`m3uline() = %q, want %q , error`, str, expected)
	}
}
