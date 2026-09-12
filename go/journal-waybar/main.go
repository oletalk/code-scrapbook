package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"

	"github.com/oletalk/code-scrapbook/waybarutil"
)

const (
	sourceCommand = "journalctl"
	EXTRACT_SIZE  = "15"
	widgetIcon    = "🪵"
	errorTemplate = "{ \"text\": \"🪵 ?\", \"tooltip\": \"error: %v\" }\n"
)

func getWaybarOutput(entry JournalEntry) (waybarutil.WaybarOutput, error) {
	var waybarOutput waybarutil.WaybarOutput
	if logtime, terr := unixMicroTimestamptostring(entry.RealtimeTimestamp); terr != nil {
		return waybarOutput, terr
	} else {
		waybarOutput.Text = fmt.Sprintf("%s %s", widgetIcon, entry.processDisplay())
		waybarOutput.Tooltip = fmt.Sprintf("%s %s", logtime, entry.Message)
		// the serious ones are 0..3 (emergency, alert, critical, error)
		waybarOutput.Class = "priority-" + entry.Priority
		return waybarOutput, nil
	}
}

func main() {
	lines, err := exec.Command(sourceCommand, "-n", EXTRACT_SIZE, "-o", "json").Output()
	if err != nil {
		fmt.Printf(errorTemplate, err)
		os.Exit(0)
	}

	var artifacts EventFlags
	currName := ""
	currNameCount := 0
	journalLines := strings.Split(string(lines), "\n")
	var lastEntry JournalEntry
	for _, line := range journalLines {
		if line != "" {
			entry, eerr := getJournalEntry(line)
			if eerr != nil {
				fmt.Printf(errorTemplate, eerr)
				os.Exit(0)
			} else {
				// keep count of number of consecutive lines with the same process
				if currName != entry.Identifier {
					currNameCount = 0
					currName = entry.Identifier
				} else {
					currNameCount++
				}
				// scan entry for any interesting artifacts
				findArtifacts(entry, &artifacts)
				lastEntry = entry
			}
		}

	}

	wout, werr := getWaybarOutput(lastEntry)
	if currNameCount > 1 {
		wout.Text = wout.Text + " " + strconv.Itoa(currNameCount) + "x,"
	}
	if artifacts.display() != "" {
		wout.Text = wout.Text + artifacts.display()
	}
	if werr != nil {
		fmt.Printf(errorTemplate, werr)
		os.Exit(0)
	}
	fmt.Print(wout.ToJson())
}
