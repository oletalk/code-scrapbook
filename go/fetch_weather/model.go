package main

type Measurements struct {
	Day   float32
	Min   float32
	Max   float32
	Night float32
	Eve   float32
	Morn  float32
}

type WeatherDisplay struct {
	Id          int
	Main        string
	Description string
	Icon        string
}

type OneCallResult struct {
	Lat             float32
	Lon             float32
	Timezone        string
	Timezone_offset int64
	Current         CurrentForecast
	Daily           []DailyForecastUnit
	Hourly          []HourlyForecastUnit
}
type CurrentForecast struct {
	Dt         uint64
	Sunrise    uint64
	Sunset     uint64
	Temp       float32
	Feels_like float32
	Pressure   uint64
	Humidity   int
	Uvi        float32
	Clouds     int
	Visibility uint64
	Wind_speed float32
	Weather    []WeatherDisplay
}

type HourlyForecastUnit struct {
	Dt         uint64
	Sunrise    uint64
	Sunset     uint64
	Moonrise   uint64
	Moonset    uint64
	Summary    string
	Temp       float32
	Feels_like float32
	Wind_speed float32
	Wind_deg   int
	Wind_gust  float32
	Weather    []WeatherDisplay
	Clouds     int
	Uvi        float32
}
type DailyForecastUnit struct {
	Dt         uint64
	Sunrise    uint64
	Sunset     uint64
	Moonrise   uint64
	Moonset    uint64
	Summary    string
	Temp       Measurements
	Feels_like Measurements
	Wind_speed float32
	Wind_deg   int
	Wind_gust  float32
	Weather    []WeatherDisplay
	Clouds     int
	Uvi        float32
}
