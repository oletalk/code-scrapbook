package main

import (
	"fmt"
	"strconv"
	"testing"
	"time"
)

type DirectionTestCase struct {
	input  int
	output string
}

type DaysTestCase struct {
	today    float32
	tomorrow float32
	dayafter float32
	output   string
}

func TestTrendIcons(t *testing.T) {
	cases := []DaysTestCase{
		{today: 20.0, tomorrow: 20.0, dayafter: 20.0, output: "➡️➡️"},
		{today: 20.0, tomorrow: 21.0, dayafter: 22.0, output: "↗️↗️"},
		{today: 20.0, tomorrow: 20.0, dayafter: 21.0, output: "➡️↗️"},
		{today: 23.0, tomorrow: 20.0, dayafter: 21.0, output: "⤵️↗️"},
		{today: 24.0, tomorrow: 23.0, dayafter: 26.0, output: "↘️⤴️"},
	}
	for _, c := range cases {
		if actual := trendIcon(c.today, c.tomorrow, c.dayafter); actual != c.output {
			testname := fmt.Sprintf("%.1f-%.1f-%.1f", c.today, c.tomorrow, c.dayafter)
			throwError(t, "TestTrendIcons", testname, c.output, actual)
		}
	}

}

func TestTimeToday(t *testing.T) {
	if actual := timeToday(1788101075); actual != "15:44" {
		throwError(t, "TestTimeToday", "15:44 PM BST", "15:44", actual)
	}
}

func TestFirstDiff(t *testing.T) {
	now := uint64(time.Now().Unix())
	units := []HourlyForecastUnit{
		{
			Dt:   now,
			Temp: 13.0,
			Weather: []WeatherDisplay{
				{
					Description: "few clouds",
				},
			},
		},
		{
			Dt:   now + 3600,
			Temp: 13.0,
			Weather: []WeatherDisplay{
				{
					Description: "few clouds",
				},
			},
		},
		{
			Dt:   now + 7200,
			Temp: 16.0,
			Weather: []WeatherDisplay{
				{
					Description: "sunny",
				},
			},
		},
		{
			Dt:   now + 10800,
			Temp: 18.0,
			Weather: []WeatherDisplay{
				{
					Description: "sunny",
				},
			},
		},
	}
	if actual := firstDiff("few clouds", units); actual.Temp != 16.0 {
		throwError(t, "TestFirstDiff", "post-few clouds diff", "16.0", fmt.Sprintf("%.1f", actual.Temp))
	}
	if actual := firstDiff("overcast", units); actual.Temp != 13.0 {
		throwError(t, "TestFirstDiff", "post-overcast diff", "16.0", fmt.Sprintf("%.1f", actual.Temp))
	}
}

func TestGetDirection(t *testing.T) {
	cases := []DirectionTestCase{
		{55, "NE"},
		{270, "W"},
		{36, "NE"},
		{0, "N"},
		{242, "SE"},
		{343, "N"},
		{155, "SW"},
	}
	for _, c := range cases {
		if actual := getDirection(c.input); actual != c.output {
			throwError(t, "TestGetDirection", strconv.Itoa(c.input), c.output, actual)
		}
	}
}

func throwError(t *testing.T, testname, input, expected, actual string) {
	t.Errorf(`Test %q Failed: input %q expected: %q, actual: %q`, testname, input, expected, actual)
}
