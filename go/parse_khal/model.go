package main

import (
	"fmt"
	"strings"
)

type Event struct {
	Title        string
	StartDate    string `json:"start-date"`
	StartTime    string `json:"start-time"`
	EndDate      string `json:"end-date"`
	EndTime      string `json:"end-time"`
	Location     string
	Duration     string
	RepeatSymbol string `json:"repeat-symbol"`
	AllDay       string `json:"all-day"`
}

type WaybarOutput struct {
	Text    string `json:"text"`
	Tooltip string `json:"tooltip"`
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
