package main

import (
	"os"
	"testing"
)

type DownsampleCase struct {
	downsample_type string
	envvar_value    string
	filename        string
	expected_result string
}

func TestDownsample1(t *testing.T) {
	for i := range testcases() {
		currCase := testcases()[i]
		if serr := os.Setenv("DOWNSAMPLED_"+currCase.downsample_type, currCase.envvar_value); serr != nil {
			t.Errorf(`Unable to set env var for test: %v`, serr)
		}
		actual, err := getDownsampleCommand(currCase.downsample_type, currCase.filename)
		if err != nil {
			t.Errorf(`TestDownsample1 error (case %d): %v`, i, err)
		} else {
			if actual != currCase.expected_result {
				t.Errorf(`(case %d) oldestFile() = %q, want %q `, i, actual, currCase.expected_result)
			}
		}
	}
}

func testcases() []DownsampleCase {
	return []DownsampleCase{
		{ /* very simple command / name */
			downsample_type: "MP3",
			envvar_value:    "cat XXXX",
			filename:        "myfile.mp3",
			expected_result: "cat myfile.mp3",
		},
		{
			downsample_type: "MP3",
			envvar_value:    "/usr/bin/lame --nohist --mp3input -b 32 XXXX out.mp3",
			filename:        "some_mp3_filename_1.mp3",
			expected_result: "/usr/bin/lame --nohist --mp3input -b 32 some_mp3_filename_1.mp3 out.mp3",
		},
		{ /* filename with spaces.
			   TODO: does os.Exec handle this for you? */
			downsample_type: "OGG",
			envvar_value:    "/usr/bin/sox XXXX -r 22050 out.ogg",
			filename:        "play my song.ogg",
			expected_result: "/usr/bin/sox play my song.ogg -r 22050 out.ogg",
		},
	}
}
