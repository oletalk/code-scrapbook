package main

import (
	"cmp"
	"math"
)

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
