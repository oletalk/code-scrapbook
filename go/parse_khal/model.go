package main

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
