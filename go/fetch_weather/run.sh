#!/usr/bin/env bash
source .env
go build
./fetch_openweather
