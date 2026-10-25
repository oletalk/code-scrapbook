package main

import (
	"strings"
	"testing"
	"time"
)

const (
	LOOP = "🔁"
)

type EventTestCase struct {
	events          []Event
	expectedText    string
	expectedTooltip string
}
type EventDay struct {
	dayNum int
	event  Event
}

// each of these EventDay objects should have a different dayNum
type EventDayTestCase struct {
	eventDays           []EventDay
	expectedText        string
	expectedTooltip     string
	expectedAppoinments int
	expectedNoEvents    bool
}

// TODO: will these fail if i run them on a different day of the week??
func TestProcess(t *testing.T) {
	testcases := []EventTestCase{
		{
			events: []Event{
				{
					AllDay:            "False",
					Title:             "Test Event",
					RepeatSymbol:      "",
					StartEndTimeStyle: "13:00 - 13:30",
					StartDate:         "2026-02-03",
				},
			},
			expectedText:    "13:00 - 13:30 Test Event ",
			expectedTooltip: "<b>Today, 2026-02-03</b>\n13:00 - 13:30 Test Event \n",
		},
		{
			events: []Event{
				{
					AllDay:            "True",
					Title:             "Halloween",
					RepeatSymbol:      "",
					StartEndTimeStyle: "",
					StartDate:         "2026-02-03",
				},
				{
					AllDay:            "False",
					Title:             "Electrician",
					RepeatSymbol:      "",
					StartEndTimeStyle: "14:00 - 15:00",
					StartDate:         "2026-02-03",
				},
				{
					AllDay:            "False",
					Title:             "Tai Chi",
					RepeatSymbol:      LOOP,
					StartEndTimeStyle: "18:00 - 19:30",
					StartDate:         "2026-02-03",
				},
			},
			expectedText:    " Halloween ",
			expectedTooltip: "<b>Today, 2026-02-03</b>\n Halloween \n14:00 - 15:00 Electrician \n18:00 - 19:30 Tai Chi 🔁\n",
		},
		{
			events: []Event{
				{
					AllDay:            "True",
					Title:             "Hogmanay",
					RepeatSymbol:      "",
					StartEndTimeStyle: "",
					StartDate:         "2025-11-31",
				},
			},
			expectedText:    " Hogmanay ",
			expectedTooltip: "<b>Today, 2025-11-31</b>\n Hogmanay \n",
		},
	}
	for n, testcase := range testcases {
		ep := EventProcessor{}
		ep.init()
		ep.initDay()
		ep.process(0, testcase.events)
		actualText := ep.eventInText
		actualTooltip := ep.tooltipDay.stringify()
		if testcase.expectedText != actualText {
			t.Errorf(`TestProcess text #%d = %q, want %q, error`, n, actualText, testcase.expectedText)
		}
		if testcase.expectedTooltip != actualTooltip {
			t.Errorf(`TestProcess tooltip  #%d = %q, want %q, error`, n, actualTooltip, testcase.expectedTooltip)
		}
	}

}

func TestAcrossDays(t *testing.T) {
	// need name for day-after-tomorrow...
	twodays := time.Now().AddDate(0, 0, 2)
	dayName := twodays.Weekday().String()

	testcases := []EventDayTestCase{
		{ /* two regular events, one today */
			eventDays: []EventDay{
				{
					dayNum: 0,
					event: Event{
						AllDay:            "False",
						Title:             "Lunch date",
						RepeatSymbol:      "",
						StartEndTimeStyle: "13:00 - 13:30",
						StartDate:         "2026-02-03",
					},
				},
				{
					dayNum: 1,
					event: Event{
						AllDay:            "False",
						Title:             "Movie night",
						RepeatSymbol:      "",
						StartEndTimeStyle: "19:00 - 21:30",
						StartDate:         "2026-02-04",
					},
				},
			},
			expectedText:        "13:00 - 13:30 Lunch date ",
			expectedTooltip:     "<b>Today, 2026-02-03</b>\n13:00 - 13:30 Lunch date \n\n<b>Tomorrow, 2026-02-04</b>\n19:00 - 21:30 Movie night \n",
			expectedAppoinments: 2,
			expectedNoEvents:    false,
		},
		{ /* two regular events, tomorrow and the next day */
			eventDays: []EventDay{
				{
					dayNum: 1,
					event: Event{
						AllDay:            "False",
						Title:             "Lunch date",
						RepeatSymbol:      "",
						StartEndTimeStyle: "13:00 - 13:30",
						StartDate:         "2026-02-03",
					},
				},
				{
					dayNum: 2,
					event: Event{
						AllDay:            "False",
						Title:             "Movie night",
						RepeatSymbol:      "",
						StartEndTimeStyle: "19:00 - 21:30",
						StartDate:         "2026-02-04",
					},
				},
			},
			expectedText:        "",
			expectedTooltip:     "<b>Tomorrow, 2026-02-03</b>\n13:00 - 13:30 Lunch date \n\n<b>" + dayName + ", 2026-02-04</b>\n19:00 - 21:30 Movie night \n",
			expectedAppoinments: 2,
			expectedNoEvents:    false,
		},
		{ /* two all-day events, first one today */
			eventDays: []EventDay{
				{
					dayNum: 0,
					event: Event{
						AllDay:            "True",
						Title:             "Seminar",
						RepeatSymbol:      "",
						StartEndTimeStyle: " |-->",
						StartDate:         "2026-02-03",
					},
				},
				{
					dayNum: 1,
					event: Event{
						AllDay:            "True",
						Title:             "Seminar",
						RepeatSymbol:      "",
						StartEndTimeStyle: "--|",
						StartDate:         "2026-02-04",
					},
				},
			},
			expectedText:        " |--> Seminar ",
			expectedTooltip:     "<b>Today, 2026-02-03</b>\n |--> Seminar \n\n<b>Tomorrow, 2026-02-04</b>\n--| Seminar \n",
			expectedAppoinments: 0,
			expectedNoEvents:    false,
		},
		{ /* two all-day events, first one in future
			    this should trigger the "all day events" message
					(not tested here, but see main.go) */
			eventDays: []EventDay{
				{
					dayNum: 1,
					event: Event{
						AllDay:            "True",
						Title:             "Seminar",
						RepeatSymbol:      "",
						StartEndTimeStyle: " |-->",
						StartDate:         "2026-02-07",
					},
				},
				{
					dayNum: 2,
					event: Event{
						AllDay:            "True",
						Title:             "Seminar",
						RepeatSymbol:      "",
						StartEndTimeStyle: "--|",
						StartDate:         "2026-02-08",
					},
				},
			},
			expectedText:        "",
			expectedTooltip:     "<b>Tomorrow, 2026-02-07</b>\n |--> Seminar \n\n<b>" + dayName + ", 2026-02-08</b>\n--| Seminar \n",
			expectedAppoinments: 0,
			expectedNoEvents:    false,
		},
	}
	for n, testcase := range testcases {
		ep := EventProcessor{}
		var tooltipText []string
		ep.init()
		for _, eventDayPair := range testcase.eventDays {
			// just 1 event in here
			eventsInDay := []Event{eventDayPair.event}
			ep.initDay()
			ep.process(eventDayPair.dayNum, eventsInDay)
			tooltipText = append(tooltipText, ep.tooltipDay.stringify())
		}
		actualText := ep.eventInText
		if testcase.expectedText != actualText {
			t.Errorf(`TestProcess text #%d = %q, want %q, error`, n, actualText, testcase.expectedText)
		}
		actualTooltip := strings.Join(tooltipText[:], "\n")
		if testcase.expectedTooltip != actualTooltip {
			t.Errorf(`TestProcess tooltip  #%d = %q, want %q, error`, n, actualTooltip, testcase.expectedTooltip)
		}
		if testcase.expectedAppoinments != ep.appointments {
			t.Errorf(`TestProcess appts  #%d = %d, want %d, error`, n, ep.appointments, testcase.expectedAppoinments)
		}
		if testcase.expectedNoEvents != ep.noEvents {
			t.Errorf(`TestProcess noEvents  #%d = %t, want %t, error`, n, ep.noEvents, testcase.expectedNoEvents)
		}
	}
}

func TestNoEvents(t *testing.T) {
	ep := EventProcessor{}
	ep.init()
	if !ep.noEvents {
		t.Errorf(`TestNoEvents noEvents should be true if no events processed at all, error`)
	}
}
