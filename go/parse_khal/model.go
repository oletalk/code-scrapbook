package main

import (
	"fmt"
	"reflect"
	"strings"
)

type Event struct {
	Title             string `json:"title"`
	StartDate         string `json:"start-date"`
	StartTime         string `json:"start-time"`
	EndDate           string `json:"end-date"`
	EndTime           string `json:"end-time"`
	StartEndTimeStyle string `json:"start-end-time-style"`
	Location          string `json:"location"`
	Duration          string `json:"duration"`
	RepeatSymbol      string `json:"repeat-symbol"`
	AllDay            string `json:"all-day"`
}

type TooltipDetail struct {
	Heading string
	Entries []string
}

func (t *TooltipDetail) heading(h string) {
	t.Heading = h
}
func (t *TooltipDetail) add_entry(e string) {
	t.Entries = append(t.Entries, e)
}

func (t TooltipDetail) stringify() string {
	var sb strings.Builder
	fmt.Fprintf(&sb, "<b>%s</b>\n", t.Heading)
	if len(t.Entries) == 0 {
		fmt.Fprintln(&sb, " * No Events * ")
	} else {
		for _, s := range t.Entries {
			fmt.Fprintf(&sb, "%s\n", s)
		}
	}
	return sb.String()
}

// Build a JSON argument list for the khal command. The Event struct lists all possible args (look at the json tags)
func khalJSONFields(v any) []string {
	t := reflect.TypeOf(v)
	fields := make([]string, 0, t.NumField())
	for f := range t.Fields() {
		//f := t.Field(i)
		name := f.Tag.Get("json")
		if name == "" {
			name = strings.ToLower(f.Name)
		}
		fields = append(fields, name)
	}
	return fields
}
