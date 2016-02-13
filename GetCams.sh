#!/bin/bash
# Save your text messaging address in SMS.txt in BootBundle.zip
SendTo=$(cat /dev/shm/SMS.txt)

echo "System was started up at `date +%H:%M` on `date +%m.%d.%Y`" | mail -s "System reboot detected!" $SendTo
rm -f /var/log/uvcdynctrl-udev.log
mkdir -p /dev/shm/GetCams/PushTmp
#Replace the below with the XML file for your National Weather Service weather station near you - visit weather.gov
curl --retry 5 "http://w1.weather.gov/xml/current_obs/KOJC.xml" > /dev/shm/obs.xml
OJCTF=$(sed -n 's:.*<temp_f>\(.*\).0<\/temp_f>.*:\1:p' /dev/shm/obs.xml)
echo $OJCTF > /dev/shm/OJC.txt
echo "" > /dev/shm/GetCams/GetCams.lock
unzip /home/astump/Scripts/BootBundle.zip -d /dev/shm/
chmod +x /dev/shm/*.sh
while true
do 
	flock -n /dev/shm/GetCams/GetCams.lock bash /dev/shm/GetCams_Main.sh
	sleep 0.1
done
