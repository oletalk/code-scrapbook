package main

import (
	"fmt"
	"strings"
	"time"
)

const (
	deg = "°C"
)

func createForecast(input OneCallResult) (WaybarOutput, error) {

	now := time.Now()
	var out WaybarOutput
	var tooltip []string
	currWeather := input.Current.Temp
	feelsLike := input.Current.Feels_like

	// CREATE TEXT IN MAIN DISPLAY
	icon := weatherIcon(input.Current.Weather[0].Icon)
	if feelsLike != currWeather {
		out.Text = fmt.Sprintf("%s %.0f%s (%.0f%s)", icon, currWeather, deg, feelsLike, deg)
	} else {
		out.Text = fmt.Sprintf("%s %.0f%s", icon, currWeather, deg)
	}

	// CREATE TOOLTIP
	// description e.g. 'broken clouds'
	currWeatherDescrip := input.Current.Weather[0].Description
	tooltip = append(tooltip, currWeatherDescrip)
	// min/max
	tooltip = append(tooltip, fmt.Sprintf("🡙 %.0f / %.0f %s", input.Daily[0].Temp.Min, input.Daily[0].Temp.Max, deg))
	sunset := input.Current.Sunset
	if !isPast(int64(sunset), now) {
		tooltip = append(tooltip, fmt.Sprintf("🌇 %s", timeToday(int64(sunset))))
	}
	// display range for tomorrow (if it's late enough)
	if showTomorrowItems(now) {
		tooltip = append(tooltip, fmt.Sprintf("tomorrow %.0f-%.0f %s", input.Daily[1].Temp.Min, input.Daily[1].Temp.Max, deg))
	}
	unit := firstDiff(currWeatherDescrip, input.Hourly)
	if unit != nil {
		changeDesc := unit.Weather[0].Description
		changeTime := timeToday(int64(unit.Dt))
		tooltip = append(tooltip, fmt.Sprintf("%s at <b>%s</b>", changeDesc, changeTime))
	}
	tooltip = append(tooltip, fmt.Sprintf("⌚ upd. %s", timeToday(now.Unix())))
	// join them all
	out.Tooltip = strings.Join(tooltip, "\n")
	return out, nil
}

// first hourly forecast where the description of the weather is different
func firstDiff(description string, hours []HourlyForecastUnit) *HourlyForecastUnit {
	now := time.Now()
	changehour, ok := Find(hours, func(h HourlyForecastUnit) bool {
		return h.Weather[0].Description != description && !isPast(int64(h.Dt), now)
	})
	if ok {
		return &changehour
	}
	return nil
}
func Find[T any](slice []T, predicate func(T) bool) (T, bool) {
	for _, item := range slice {
		if predicate(item) {
			return item, true
		}
	}
	var zero T
	return zero, false
}

// given an epochSeconds value, show it in the form HH:MM
func timeToday(epochSeconds int64) string {
	t := time.Unix(epochSeconds, 0)
	return t.Format("15:04")
}

// show items for tomorrow after 2pm
func showTomorrowItems(now time.Time) bool {
	return now.Hour() >= 14
}

func isPast(epochSeconds int64, now time.Time) bool {
	return epochSeconds < now.Unix()
}
func weatherIcon(iconName string) string {
	switch iconName {
	case "01d":
		return "" // clear day
	case "01n":
		return "" // clear night
	case "02d", "02n", "03d", "03n", "04d", "04n":
		return "" // cloudy
	case "09d", "09n":
		return "" // shower rain
	case "10d", "10n":
		return "" // rain
	case "11d", "11n":
		return "" // thunderstorm
	case "13d", "13n":
		return "" // snow
	case "50d", "50n":
		return "" // mist
	default:
		return ""
	}
}
