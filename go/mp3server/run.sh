#!/bin/bash

source .env

go build . && ./mp3server; rm -v ./mp3server
