package main

import (
	"fmt"
	"time"
)

type EventProcessor struct {
	noEvents     bool
	appointments int
	dispText     string
	isToday      bool
	eventInText  string
	tooltipDay   TooltipDetail
}

func (ep *EventProcessor) init() {
	ep.noEvents = true
	ep.appointments = 0
}

func (ep *EventProcessor) initDay() {
	// these below are probably unnecessary
	// ep.eventInText = ""
	ep.tooltipDay = TooltipDetail{}
}

// TODO: can't call this with an empty bunch of events btw
func (ep *EventProcessor) process(dayNum int, events []Event) {
	now := time.Now()
	dte := now.AddDate(0, 0, dayNum)
	dayofwk, _ := dayofweek_time(dte, now)
	ep.isToday = (dayofwk == "Today")
	ep.tooltipDay.heading(fmt.Sprintf("%s, %s", dayofwk, events[len(events)-1].StartDate))
	for _, event := range events {
		ep.noEvents = false
		if event.AllDay != "True" {
			ep.appointments += 1
			// dispText := fmt.Sprintf("%s-%s %s", event.StartTime, event.EndTime, event.Title)
			dispText := fmt.Sprintf("%s %s %s", event.StartEndTimeStyle, event.Title, event.RepeatSymbol)
			if ep.isToday && ep.eventInText == "" {
				ep.eventInText = dispText
			}
			ep.tooltipDay.add_entry(dispText)
		} else {
			// dispText := fmt.Sprintf("%s (All Day)", event.Title)
			dispText := fmt.Sprintf("%s %s %s", event.StartEndTimeStyle, event.Title, event.RepeatSymbol)
			if ep.isToday && ep.eventInText == "" {
				ep.eventInText = dispText
			}
			ep.tooltipDay.add_entry(dispText)
		}
	}
}
