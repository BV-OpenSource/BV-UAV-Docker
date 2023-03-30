#!/bin/bash

export TODAY=$(date +"%d")
export CPU_AVAILABLE=$(getconf _NPROCESSORS_ONLN)
export CPU_CORE=$(( CPU_AVAILABLE < 4 ? 1 : CPU_AVAILABLE-2 ))

docker-compose up --build 
