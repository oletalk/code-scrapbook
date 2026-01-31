package main

import (
	"os"
	"strings"
)

/*
	  get commands from config
		substitute given file name
		run command and move old file out once command is successful
*/
func getDownsampleCommand(filetype string, filename string) (string, error) {
	cmd := os.Getenv("DOWNSAMPLED_" + filetype)
	if cmd == "" {
		return "", &ApplicationError{"downsample command not set"}
	} else {
		cmd = strings.Replace(cmd, "XXXX", filename, 1)
	}
	return cmd, nil
}
