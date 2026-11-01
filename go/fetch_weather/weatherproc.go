package main

import (
	"fmt"
	"strings"
	"time"
)

const (
	deg                = "°C"
	ROUNDING           = 0.9
	LARGE_DELTA        = 2.0
	SHOW_TOMORROW_HOUR = 14
	TREND_DAYS         = 3
)

func createForecast(input OneCallResult, lastModifiedTime string) (WaybarOutput, error) {

	now := time.Now()
	var out WaybarOutput
	var tooltip []string
	currWeather := input.Current.Temp
	feelsLike := input.Current.Feels_like

	// CREATE TEXT IN MAIN DISPLAY
	icon := weatherIcon(input.Current.Weather[0].Icon)
	if int64(feelsLike) != int64(currWeather) {
		out.Text = fmt.Sprintf("%s %.0f%s (%.0f%s)", icon, currWeather, deg, feelsLike, deg)
	} else {
		out.Text = fmt.Sprintf("%s %.0f%s", icon, currWeather, deg)
	}

	// CREATE TOOLTIP
	// description e.g. 'broken clouds'
	currWeatherDescrip := input.Current.Weather[0].Description
	windSpeed := input.Current.Wind_speed
	windInfo := fmt.Sprintf("%s %.0f m/s %s", getWindIcon(windSpeed), windSpeed, getDirection(input.Current.Wind_deg))

	firstLine := currWeatherDescrip

	if windSpeed > 0.0 {
		firstLine += " (" + windInfo + " )"
	}
	tooltip = append(tooltip, firstLine)
	// min/max
	tooltip = append(tooltip, fmt.Sprintf("🡙 %.0f / %.0f %s", input.Daily[0].Temp.Min, input.Daily[0].Temp.Max, deg))
	sunrise := input.Current.Sunrise
	sunset := input.Current.Sunset
	if isFuture(int64(sunrise), now) {
		// before sunrise today? show forecast
		tooltip = append(tooltip, fmt.Sprintf("🌄 %s", timeToday(int64(sunrise))))
	} else if isFuture(int64(sunset), now) {
		// before sunset? show its forecast
		tooltip = append(tooltip, fmt.Sprintf("🌇 %s", timeToday(int64(sunset))))
	} else {
		// show tomorrow's sunrise
		sunrise = input.Daily[1].Sunrise
		tooltip = append(tooltip, fmt.Sprintf("🌄 %s", timeToday(int64(sunrise))))
	}
	// display range for tomorrow (if it's late enough)
	if showTomorrowItems(now) {
		// work out trend
		var avgTemp []float32
		for i := 0; i < TREND_DAYS+1; i++ {
			avgTemp = append(avgTemp, (input.Daily[i].Temp.Max+input.Daily[i].Temp.Min)/2)
		}

		weatherTomorrow := input.Daily[1].Weather[0].Description
		if weatherTomorrow == currWeatherDescrip {
			weatherTomorrow = ""
		} else {
			weatherTomorrow = "<i>" + weatherTomorrow + "</i>,"
		}
		tooltip = append(tooltip, fmt.Sprintf("tomorrow %s %.0f-%.0f %s %s", weatherTomorrow, input.Daily[1].Temp.Min, input.Daily[1].Temp.Max, deg, trendIcon(avgTemp)))
	}
	unit := firstDiff(currWeatherDescrip, input.Hourly)
	if unit != nil {
		changeDesc := unit.Weather[0].Description
		changeTime := timeToday(int64(unit.Dt))
		tooltip = append(tooltip, fmt.Sprintf("%s at <b>%s</b>", changeDesc, changeTime))
	}
	// tooltip = append(tooltip, fmt.Sprintf("⌚ upd. %s", timeToday(now.Unix())))
	tooltip = append(tooltip, fmt.Sprintf("⌚ upd. %s", lastModifiedTime))
	// alerts
	if len(input.Alerts) > 0 {
		var allAlerts []AlertInfo
		for _, a := range input.Alerts {
			if isPast(a.Start, time.Now()) && isFuture(a.End, time.Now()) {
				allAlerts = append(allAlerts, a)
			}
		}
		if len(allAlerts) > 0 {
			aldescr := allAlerts[0].Event
			if len(allAlerts) > 1 {
				aldescr = fmt.Sprintf("%s + %d", aldescr, len(allAlerts)-1)
			}
			tooltip = append(tooltip, "⚠️ "+aldescr)
			out.Text += "⚠️"
		}
	}

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
	return now.Hour() >= SHOW_TOMORROW_HOUR
}

func isPast(epochSeconds int64, now time.Time) bool {
	return epochSeconds < now.Unix()
}
func isFuture(epochSeconds int64, now time.Time) bool {
	return epochSeconds > now.Unix()
}
