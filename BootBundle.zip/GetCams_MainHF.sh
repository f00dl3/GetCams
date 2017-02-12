#!/bin/bash

Cam1IP=""
Cam2IP=""
Cam2IPWiFi=""
ipCamUser=""
ipCamPass=""
mTrigger=250

sleep 0.5

(
curl --max-time 3 "http://"$Cam1IP":88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$ipCamUser&pwd=$ipCamPass" > /dev/shm/GetCams/Ywebc3-temp.jpeg &
curl --max-time 3 "http://"$Cam2IP":88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$ipCamUser&pwd=$ipCamPass" > /dev/shm/GetCams/Ywebc2-temp.jpeg
)

if [ ! -s /dev/shm/GetCams/Ywebc3-temp.jpeg ]; then
	curl --max-time 3 "http://"$Cam2IPWiFi":88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$ipCamUser&pwd=$ipCamPass" > /dev/shm/GetCams/Ywebc3-temp.jpeg
fi

Nanos=$(date +'%N')
ShortNanos=${Nanos:0:1}
MainLabel=$(date +'%Y-%m-%d %H:%M:%S')"."$ShortNanos

if [ ! -f /dev/shm/GetCams/Xwebc1-temp.jpeg ]; then
	convert -size 1920x1080 -gravity center -annotate 0 "Cam1 temporarily unavailable!\n Cycles: ${UACam1}" -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Ywebc1-temp.jpeg
fi

if [ ! -s /dev/shm/GetCams/Ywebc2-temp.jpeg ]; then
	convert -size 954x540 -gravity center -annotate 0 "Cam2 temporarily unavailable!\n Cycles:  ${UACam2}" -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Ywebc2-temp.jpeg
else 
	mogrify -resize 954x540! /dev/shm/GetCams/Ywebc2-temp.jpeg
fi

if [ ! -s /dev/shm/GetCams/Ywebc3-temp.jpeg ]; then
	convert -size 954x540 -gravity center -annotate 0 "Cam3 temporarily unavailable!\n Cycles: ${UACam3}" -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Ywebc3-temp.jpeg
else	
	mogrify -resize 954x540! /dev/shm/GetCams/Ywebc3-temp.jpeg
fi

convert \( /dev/shm/GetCams/Xwebc1-temp.jpeg +append \) \
 \( /dev/shm/GetCams/Ywebc2-temp.jpeg /dev/shm/GetCams/Ywebc3-temp.jpeg +append \) \
 \( -gravity south -background Black -pointsize 48 -fill Yellow label:"${MainLabel}" +append \) \
 -background Black -append -resize 1152x1006! /dev/shm/GetCams/webcY-temp.jpeg

(
rm /dev/shm/GetCams/Ywebc*-temp.jpeg &
cp /dev/shm/GetCams/webcY-temp.jpeg /dev/shm/GetCams/PushTmp/$(date +'%y%m%d-%H%M%S-%N').jpeg
)

rm /dev/shm/GetCams/webcY-temp.jpeg
