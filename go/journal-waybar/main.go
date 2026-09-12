package main

import (
	"fmt"
	"github.com/oletalk/code-scrapbook/waybarutil"
	"os"
	"os/exec"
)

const (
	sourceCommand = "journalctl"
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
	out, err := exec.Command(sourceCommand, "-n", "1", "-o", "json").Output()
	if err != nil {
		fmt.Printf(errorTemplate, err)
		os.Exit(0)
	}
	entry, eerr := getJournalEntry(string(out))
	if eerr != nil {
		fmt.Printf(errorTemplate, eerr)
		os.Exit(0)
	}
	wout, werr := getWaybarOutput(entry)
	if werr != nil {
		fmt.Printf(errorTemplate, werr)
		os.Exit(0)
	}
	fmt.Print(wout.ToJson())
}
