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

func main() {
	var waybarOutput waybarutil.WaybarOutput
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
	logtime, terr := unixMicroTimestamptostring(entry.RealtimeTimestamp)
	if terr != nil {
		fmt.Printf(errorTemplate, terr)
		os.Exit(0)
	}
	waybarOutput.Text = fmt.Sprintf("%s %s [%s]", widgetIcon, entry.Identifier, entry.ProcessId)
	waybarOutput.Tooltip = fmt.Sprintf("%s %s", logtime, entry.Message)
	// the serious ones are 0..3 (emergency, alert, critical, error)
	waybarOutput.Class = "priority-" + entry.Priority
	fmt.Print(waybarOutput.ToJson())
}
