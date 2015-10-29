#!/bin/sh
echo "System was started up at `date +%H:%M` on `date +%m.%d.%Y`" | mail -s "System reboot detected!" CELLNUMBER@CARRIER.COM
mkdir -p /dev/shm/GetCams/PushTmp
curl --retry 5 "http://w1.weather.gov/xml/current_obs/KOJC.xml" > /dev/shm/obs.xml
OJCTF=$(sed -n 's:.*<temp_f>\(.*\).0<\/temp_f>.*:\1:p' /dev/shm/obs.xml)
echo $OJCTF > /dev/shm/OJC.txt
echo "" > /dev/shm/GetCams/GetCams.lock
while true
do 
	flock -n /dev/shm/GetCams/GetCams.lock sh /home/USER/Scripts/GetCams_Main.sh
	sleep 0.1
done
