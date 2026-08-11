package main

import (
	"time"
)

func dayofweek(datestr string, now time.Time) (string, error) {
	// input format should be yyyy-mm-dd
	t, err := time.Parse("2006-01-02", datestr)
	if err != nil {
		return "", err
	}
	// if today, tomorrow...
	y1, m1, d1 := t.Date()
	y2, m2, d2 := now.Date()
	y3, m3, d3 := now.AddDate(0, 0, 1).Date()
	if y1 == y2 && m1 == m2 && d1 == d2 {
		return "Today", nil
	} else if y1 == y3 && m1 == m3 && d1 == d3 {
		return "Tomorrow", nil
	}

	return t.Weekday().String(), nil
}
