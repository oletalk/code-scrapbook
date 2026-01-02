package main

import (
	"testing"
	"time"
)

func TestGetFileInfos(t *testing.T) {
	actual, err := getFileInfos("./testdata/")
	if err != nil {
		t.Errorf(`getFileInfos error %v`, err)
	}
	if len(actual) != 2 {
		t.Errorf(`getFileInfos() = %d, want %d , error`, len(actual), 2)
	}
	expNames := []string{"data.csv", "words.txt"}
	expSizes := []int64{2, 2}
	for i := range expNames {
		if expNames[i] != actual[i].name {
			t.Errorf(`getFileInfos(%d) = %s, want %s , error`, i, actual[i].name, expNames[i])
		}
	}

	for i := range expSizes {
		if expSizes[i] != actual[i].size {
			t.Errorf(`getFileInfos(%d) = %d, want %d , error`, i, actual[i].size, expSizes[i])
		}
	}
}

func TestOldest(t *testing.T) {
	//		t.Errorf(`m3uline() = %q, want %q , error`, str, expected)
	fs := testData1()
	f := FileCache{
		cacheDir: "/var/tmp",
		maxSize:  100000,
		files:    fs,
	}
	exp := "mysterious.txt"
	act, _ := f.oldestFile()
	if act.name != exp {
		t.Errorf(`oldestFile() = %q, want %q `, act.name, exp)
	}
}

func testData1() []FileInfo {
	return []FileInfo{
		{
			name:       "document.pdf",
			size:       204,
			accessTime: time.Date(2024, 12, 15, 10, 30, 0, 0, time.UTC),
		},
		{
			name:       "mysterious.txt",
			size:       4,
			accessTime: time.Date(2024, 2, 10, 10, 30, 0, 0, time.UTC),
		},
		{
			name:       "data.csv",
			size:       99,
			accessTime: time.Date(2025, 12, 15, 11, 31, 0, 0, time.UTC),
		},
		{
			name:       "tune.mp3",
			size:       1234,
			accessTime: time.Date(2025, 12, 3, 22, 3, 0, 0, time.UTC),
		},
	}
}
