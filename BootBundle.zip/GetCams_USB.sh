#!/bin/bash

if [ -e "/dev/video"* ]; then
	USBCamRef=$(ls /dev/video*)
	timeout --kill-after=15 15 ffmpeg -f video4linux2 -s 1920x1080 -i $USBCamRef -ss 00:00:00.2 -frames 1 /dev/shm/GetCams/Xwebc1-temp-A.jpeg
fi

mv /dev/shm/GetCams/Xwebc1-temp-A.jpeg /dev/shm/GetCams/Xwebc1-temp.jpeg
