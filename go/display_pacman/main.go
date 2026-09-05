package main

import (
	"encoding/json"
	"fmt"
	"os/exec"
	"slices"
	"strconv"
	"strings"
)

const (
	PACKAGE_ICON      = "📦"
	errorTemplate     = "{ 'text': '📦 ?', 'tooltip': 'error: %v' }"
	sourceCommand     = "checkupdates"
	MAX_LINES_TOOLTIP = 4
)

func SpecialPackages() []string {
	return []string{"linux", "linux-lts", "amd-ucode", "mkinitcpio"}
}

func main() {
	var waybarOutput WaybarOutput
	var tooltipLines []string
	packages := 0
	highlight := false
	out, err := exec.Command(sourceCommand).Output()
	if err != nil {
		fmt.Printf(errorTemplate, err)
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
		waybarOutput.Tooltip = strings.Join(tooltipLines[:], "\n")
	}

	// spit out output
	var outStr strings.Builder
	enc := json.NewEncoder(&outStr)
	enc.SetEscapeHTML(false) // not printing out to web so we're fine
	eerr := enc.Encode(waybarOutput)
	if eerr != nil {
		fmt.Printf(errorTemplate, "json error")
	} else {
		fmt.Print(outStr.String())
	}
}
