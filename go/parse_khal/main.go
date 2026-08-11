package main

import (
	"encoding/json"
	"fmt"
	"os/exec"
	"strings"
	"time"
)

const (
	errorTemplate = "{ 'text': '⏰ ?', 'tooltip': 'error: %v' }"
	calendarIcon  = "📆"
)

func main() {
	now := time.Now()
	isToday := false
	var eventInText string
	var waybarOutput WaybarOutput
	var tooltipText []string
	appointments := 0

	// TODO: tidier!
	out, err := exec.Command("khal", "list", "now", "8days",
		"--json", "title",
		"--json", "start-date",
		"--json", "start-time",
		"--json", "end-date",
		"--json", "end-time",
		"--json", "location",
		"--json", "duration",
		"--json", "all-day",
		"--json", "repeat-symbol",
		"--json", "end").Output()
	if err == nil {
		for output := range strings.SplitSeq(string(out), "\n") {

			if strings.Contains(output, "{") {
				var events []Event
				var tooltipDay TooltipDetail
				err := json.Unmarshal([]byte(output), &events)
				if err == nil {
					// fmt.Printf("Parsed events: %+v\n", events)
					// TODO: error handling?
					dayofwk, _ := dayofweek(events[0].StartDate, now)
					isToday = (dayofwk == "Today")
					tooltipDay.heading(fmt.Sprintf("%s, %s", dayofwk, events[0].StartDate))
					for _, event := range events {
						if event.AllDay != "True" {
							appointments += 1
							dispText := fmt.Sprintf("%s-%s %s", event.StartTime, event.EndTime, event.Title)
							if isToday && eventInText == "" {
								eventInText = dispText
							}
							tooltipDay.add_entry(dispText)
						} else {
							tooltipDay.add_entry(fmt.Sprintf("%s (All Day)", event.Title))
						}
					}
				} else {
					fmt.Printf(errorTemplate, err)
				}
				tooltipText = append(tooltipText, tooltipDay.stringify())
			}
		}
		waybarOutput.Tooltip = strings.Join(tooltipText[:], "\n")

	} else {
		fmt.Printf("Error occurred: %v\n", err)
	}

	// finally put together the text
	// if a today event...
	if eventInText != "" {
		waybarOutput.Text = fmt.Sprintf("%s %s", calendarIcon, eventInText)
	} else if appointments > 0 {
		// else if at least one appointment...
		waybarOutput.Text = fmt.Sprintf("%s (%d)", calendarIcon, appointments)
	}
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
