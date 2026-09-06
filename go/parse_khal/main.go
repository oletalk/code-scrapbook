package main

import (
	"encoding/json"
	"fmt"
	"github.com/oletalk/code-scrapbook/waybarutil"
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
	eventInText := ""
	var waybarOutput waybarutil.WaybarOutput
	var tooltipText []string
	appointments := 0

	fields := khalJSONFields(Event{})
	args := []string{"list", "now", "8days"}
	for _, f := range fields {
		args = append(args, "--json", f)
	}

	out, err := exec.Command("khal", args...).Output()
	if err == nil {
		for dayNum, output := range strings.Split(string(out), "\n") {
			// khal output is a sequential list of json arrays
			// 1 per day
			dte := time.Now().AddDate(0, 0, dayNum)
			if strings.Contains(output, "{") {
				var events []Event
				var tooltipDay TooltipDetail
				err := json.Unmarshal([]byte(output), &events)
				if err == nil {
					// fmt.Printf("Parsed events: %+v\n", events)
					// TODO: error handling?
					// dayofwk, _ := dayofweek(events[len(events)-1].StartDate, now)
					dayofwk, _ := dayofweek_time(dte, now)
					isToday = (dayofwk == "Today")
					tooltipDay.heading(fmt.Sprintf("%s, %s", dayofwk, events[len(events)-1].StartDate))
					for _, event := range events {
						if event.AllDay != "True" {
							appointments += 1
							// dispText := fmt.Sprintf("%s-%s %s", event.StartTime, event.EndTime, event.Title)
							dispText := fmt.Sprintf("%s %s %s", event.StartEndTimeStyle, event.Title, event.RepeatSymbol)
							if isToday && eventInText == "" {
								eventInText = dispText
							}
							tooltipDay.add_entry(dispText)
						} else {
							// dispText := fmt.Sprintf("%s (All Day)", event.Title)
							dispText := fmt.Sprintf("%s %s %s", event.StartEndTimeStyle, event.Title, event.RepeatSymbol)
							if isToday && eventInText == "" {
								eventInText = dispText
							}
							tooltipDay.add_entry(dispText)
						}
					}
				} else {
					fmt.Printf(errorTemplate, err)
				}
				tooltipText = append(tooltipText, tooltipDay.stringify())
			}
		}
		waybarOutput.SetTooltip(tooltipText)

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
	outStr, eerr := waybarOutput.ToJson()
	if eerr != nil {
		fmt.Printf(errorTemplate, "json error")
	} else {
		fmt.Print(outStr)
	}
}
