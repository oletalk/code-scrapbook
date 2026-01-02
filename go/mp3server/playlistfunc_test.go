package main

import (
	"testing"
)

func TestSongFromPath(t *testing.T) {
	cases := []TestCase{
		{in: "/path/to/mysong.mp3", out: "mysong"},
		{in: "/another/path/this_other.ogg", out: "this_other"},
		{in: "/ogg/files/coolsong.MP3", out: "coolsong"},
		{in: "/some/more/songs/another.m4a", out: "another.m4a"},
	}

	for _, c := range cases {
		if str := songfrompath(c.in, true); str != c.out {
			t.Errorf(`songfrompath(%q) = %q, want %q , error`, c.in, str, c.out)
		}
	}

}

func TestRemovedSuffix(t *testing.T) {
	if str := removedSuffix("foo.mp3", ".mp3"); str != "foo" {
		t.Errorf(`removedSuffix("foo.mp3") = %q, want "foo" , error`, str)
	}
}

func TestMakeFilename(t *testing.T) {
	cases := []TestCase{
		{in: "/path/to/mysong.mp3", out: "9ed192_mysong.mp3"},
		{in: "/another/path/this_other.ogg", out: "c263f7_this_other.ogg"},
		{in: "/ogg/files/coolsong.MP3", out: "cf424b_coolsong.MP3"},
	}

	for _, c := range cases {
		if str := filenameForCache(c.in); str != c.out {
			t.Errorf(`cachedFilename(%s) = %q, want %s `, c.in, str, c.out)
		}
	}
}
