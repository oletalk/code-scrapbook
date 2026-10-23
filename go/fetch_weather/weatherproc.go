package main

import (
	"cmp"
	"fmt"
	"math"
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
	sunset := input.Current.Sunset
	if !isPast(int64(sunset), now) {
		// before sunset? show its forecast
		tooltip = append(tooltip, fmt.Sprintf("🌇 %s", timeToday(int64(sunset))))
	} else {
		// sunrise tomorrow
		sunrise := input.Daily[1].Sunrise
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
		aldescr := allAlerts[0].Event
		if len(allAlerts) > 1 {
			aldescr = fmt.Sprintf("%s + %d", aldescr, len(allAlerts)-1)
		}
		tooltip = append(tooltip, "⚠️ "+aldescr)
		out.Text += "⚠️"
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
func getWindIcon(msec float32) string {
	switch {
	case msec > 0 && msec <= 5:
		return "🍃"
	case msec > 5 && msec <= 10:
		return "🪁"
	case msec > 10 && msec <= 15:
		return "🌬️"
	case msec < 15 && msec <= 20:
		return "💨"
	case msec > 20 && msec <= 30:
		return "🌪️"
	default:
		return ""

	}
}
func getDirection(deg int) string {
	switch {
	case deg >= 0 && deg <= 22:
		return "N"
	case deg > 22 && deg <= 67:
		return "NE"
	case deg > 67 && deg <= 112:
		return "E"
	case deg > 112 && deg <= 157:
		return "SW"
	case deg > 157 && deg <= 202:
		return "S"
	case deg > 202 && deg <= 247:
		return "SE"
	case deg > 247 && deg <= 292:
		return "W"
	case deg > 292 && deg <= 337:
		return "NW"
	case deg > 337 && deg <= 360:
		return "N"
	default:
		return "Unknown"
	}
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

func roundTo(v float32, step float32) float32 {
	return float32(math.Round(float64(v/step))) * step
}

// return icon for temp trend
func trendIcon(avgTemps []float32) string {
	// TODO: way to signal one of the temp differences is much larger than the other
	var retStr string
	for i := 0; i < len(avgTemps)-1; i++ {
		retStr += changeIcon(avgTemps[i], avgTemps[i+1])
	}

	// if retStr == "➡️➡️" {
	// 		return ""
	// 	}
	return retStr
}

func changeIcon(first float32, second float32) string {
	ra := roundTo(first, ROUNDING)
	rb := roundTo(second, ROUNDING)
	delta1 := math.Abs(float64(rb - ra))
	switch cmp.Compare(ra, rb) {
	case -1:
		if delta1 >= LARGE_DELTA {
			return "⤴️"
		} else {
			return "↗️"
		}
	case 1:
		if delta1 >= LARGE_DELTA {
			return "⤵️"
		} else {
			return "↘️"
		}
	default:
		return "➡️"
	}
}

func isPast(epochSeconds int64, now time.Time) bool {
	return epochSeconds < now.Unix()
}
func isFuture(epochSeconds int64, now time.Time) bool {
	return epochSeconds > now.Unix()
}
func weatherIcon(iconName string) string {
	switch iconName {
	case "01d":
		return "" // clear day
	case "01n":
		return "" // clear night
	case "02d", "02n", "03d", "03n", "04d", "04n":
		return "☁️" // cloudy
	case "09d", "09n":
		return "☔" // shower rain
	case "10d", "10n":
		return "🌧️" // rain
	case "11d", "11n":
		return "⛈️" // thunderstorm
	case "13d", "13n":
		return "❄️" // snow
	case "50d", "50n":
		return "🌫️" // mist
	default:
		return ""
	}
}
