#!/bin/bash

mkdir -p /dev/shm/GetCams/PushTmp
echo "" > /dev/shm/GetCams/GetCams.lock
unzip /home/astump/Scripts/BootBundle.zip -d /dev/shm/
dos2unix /dev/shm/*.sh
chmod +x /dev/shm/*.sh

while true
do
	flock -n /dev/shm/GetCams/GetCamsUSB.lock bash /dev/shm/GetCams_USB.sh &
	flock -n /dev/shm/GetCams/GetCams.lock bash /dev/shm/GetCams_Main.sh &
	flock -n /dev/shm/GetCams/GetCamsHF.lock bash /dev/shm/GetCams_MainHF.sh &
	wait
	if [ -e "/dev/video"* ]; then
		sleep 0.01
	else
		sleep 0.3
	fi
done
