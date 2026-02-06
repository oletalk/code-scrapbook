package main

import (
	"log"
	"os"
	"os/exec"
	"time"
)

// downsample file and replace after successful downsample
func processDownsampleAndReplace(filetype string, filepath string) error {
	if newFileName, err := processDownsample(filetype, filepath); err != nil {
		return err
	} else {
		// replace old with new
		log.Println("replacing with downsampled file")
		cmd := exec.Command("mv", "-f", newFileName, filepath)
		if output, err := cmd.CombinedOutput(); err != nil {
			log.Printf("mv output: %v", output)
			return err
		}

	}
	return nil
}

// downsample file given type (MP3/OGG) and complete file path in filename
func processDownsample(filetype string, filepath string) (string, error) {
	executable := ""
	var outfile string
	var cmd *exec.Cmd
	timestamp := time.Now().Format("150405")

	dsStart := time.Now()
	switch filetype {
	case "MP3":
		executable = os.Getenv("LAME_CMD")
		if executable == "" {
			return "", &ApplicationError{"downsample command not set"}
		}
		outfile = "out." + timestamp + ".mp3"
		cmd = exec.Command(executable, "--nohist", "--mp3input", "-b", "32", filepath, outfile)
	case "OGG":
		executable = os.Getenv("SOX_CMD")
		if executable == "" {
			return "", &ApplicationError{"downsample command not set"}
		}
		outfile = "out." + timestamp + ".ogg"
		cmd = exec.Command(executable, filepath, "-r", "22050", outfile)
	case "TXT": /* here for testing purposes only */
		executable = "/bin/cp"
		outfile = "out.txt"
		cmd = exec.Command(executable, filepath, outfile)
	default:
	}
	if outfile != "" {
		// execute
		if output, err := cmd.CombinedOutput(); err == nil {
			duration := time.Since(dsStart).Milliseconds()
			log.Printf("Downsample took %d milliseconds.\n", duration)
		} else {
			log.Println(string(output))
			return "", err
		}
	}
	return outfile, nil
}
