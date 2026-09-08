package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

const (
	errorTemplate = "{ \"text\": \"📦 ?\", \"tooltip\": \"error: %v\" }\n"
	noUpdates     = "{ \"text\": \"📦 ✅\", \"tooltip\": \"system up-to-date!\", \"class\": \"updates-none\" }"
	sourceCommand = "checkupdates"
)

func SpecialPackages() []string {
	return []string{"linux", "linux-lts", "amd-ucode", "mkinitcpio"}
}

func main() {
	out, err := exec.Command(sourceCommand).Output()
	if err != nil {
		// if exit status 2 use empty template
		if exitErr, ok := err.(*exec.ExitError); ok {
			switch exitErr.ExitCode() {
			case 2:
				fmt.Println(noUpdates)
			default:
				fmt.Printf(errorTemplate, err)
			}
		}
		os.Exit(0)
	}
	cuOut := strings.Split(string(out), "\n")
	waybarOutput := createWaybarOutput(cuOut)

	// spit out output
	json, eerr := waybarOutput.ToJson()
	if eerr != nil {
		fmt.Printf(errorTemplate, "json error")
	} else {
		fmt.Print(json)
	}
}
