#!/bin/bash

source .env

go build . && ./mp3server
