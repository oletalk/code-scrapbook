package main

import (
	"encoding/json"
	"fmt"
	"github.com/oletalk/code-scrapbook/waybarutil"
	"os/exec"
	"strings"
)

const (
	errorTemplate = "{ 'text': '⏰ ?', 'tooltip': 'error: %v' }"
	calendarIcon  = "📆"
	DAYS          = "8"
)

func main() {
	var waybarOutput waybarutil.WaybarOutput
	var tooltipText []string

	fields := khalJSONFields(Event{})
	args := []string{"list", "now", DAYS + "days"}
	for _, f := range fields {
		args = append(args, "--json", f)
	}

	out, err := exec.Command("khal", args...).Output()
	ep := EventProcessor{}
	ep.init()
	if err == nil {
		for dayNum, output := range strings.Split(string(out), "\n") {
			// khal output is a sequential list of json arrays
			// 1 per day
			if strings.Contains(output, "{") {
				var events []Event
				err := json.Unmarshal([]byte(output), &events)
				if err == nil {
					// fmt.Printf("Parsed events: %+v\n", events)
					ep.initDay()
					ep.process(dayNum, events)
				} else {
					fmt.Printf(errorTemplate, err)
				}
				tooltipText = append(tooltipText, ep.tooltipDay.stringify())
			}
		}
		waybarOutput.SetTooltip(tooltipText)

	} else {
		fmt.Printf(errorTemplate, err)
	}

	// finally put together the text
	// if a today event...
	if ep.eventInText != "" {
		waybarOutput.Text = fmt.Sprintf("%s %s", calendarIcon, ep.eventInText)
	} else if ep.appointments > 0 {
		// else if at least one appointment...
		waybarOutput.Text = fmt.Sprintf("%s (%d)", calendarIcon, ep.appointments)
	} else {
		if ep.noEvents {
			var noevents []string
			noevents = append(noevents, "No upcoming events in the next "+DAYS+" days")
			waybarOutput.SetTooltip(noevents)
			waybarOutput.Text = "🧺 <i>clear</i>"
		} else {
			// if noEvents is false but we still have no event text,
			// there *were* events, but none with times,
			// i.e. only 'All Day' events
			waybarOutput.Text = "🔛 <i>all day events</i>"
		}
	}

	outStr, eerr := waybarOutput.ToJson()
	if eerr != nil {
		fmt.Printf(errorTemplate, "json error")
	} else {
		fmt.Print(outStr)
	}
}
