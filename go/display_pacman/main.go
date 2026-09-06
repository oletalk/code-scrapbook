package main

import (
	"fmt"
	"github.com/oletalk/code-scrapbook/waybarutil"
	"os"
	"os/exec"
	"slices"
	"strconv"
	"strings"
)

const (
	PACKAGE_ICON      = "📦"
	errorTemplate     = "{ \"text\": \"📦 ?\", \"tooltip\": \"error: %v\" }\n"
	noUpdates         = "{ \"text\": \"📦 ✅\", \"tooltip\": \"system up-to-date!\" }"
	sourceCommand     = "checkupdates"
	MAX_LINES_TOOLTIP = 4
)

func SpecialPackages() []string {
	return []string{"linux", "linux-lts", "amd-ucode", "mkinitcpio"}
}

func main() {
	var waybarOutput waybarutil.WaybarOutput
	var tooltipLines []string
	packages := 0
	highlight := false
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
	} else {
		cuOut := strings.Split(string(out), "\n")
		for lineNum, output := range cuOut {
			if lineNum < MAX_LINES_TOOLTIP {
				packageName, details, found := strings.Cut(output, " ")
				if found && slices.Contains(SpecialPackages(), packageName) {
					newStr := fmt.Sprintf("<b>%s</b> %s", packageName, details)
					tooltipLines = append(tooltipLines, newStr)
					highlight = true
				} else {
					tooltipLines = append(tooltipLines, output)
				}
			}
			if lineNum == MAX_LINES_TOOLTIP {
				tooltipLines = append(tooltipLines, " ... more ...")
			}
			if strings.TrimSpace(output) != "" {
				packages++
			}
		}
		if highlight {
			waybarOutput.Text = PACKAGE_ICON + " <b>" + strconv.Itoa(packages) + "</b>"
		} else {
			waybarOutput.Text = PACKAGE_ICON + " " + strconv.Itoa(packages)
		}
		waybarOutput.SetTooltip(tooltipLines)
	}

	// spit out output
	json, eerr := waybarOutput.ToJson()
	if eerr != nil {
		fmt.Printf(errorTemplate, "json error")
	} else {
		fmt.Print(json)
	}
}
