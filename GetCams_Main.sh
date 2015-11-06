#!/bin/bash

LUStatus=$(cat /dev/shm/GetCams/LUStatus.txt)
LCaseTF=$(cat /dev/shm/GetCams/CaseTF.txt)
LCPUTF=$(cat /dev/shm/GetCams/CPUTF.txt)
LOJCTF=$(cat /dev/shm/OJC.txt)

(
curl "http://CAMIP:PORT/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=USER&pwd=PASSWORD" > /dev/shm/GetCams/Xwebc3-temp.jpeg &
curl "http://CAMIP:PORT/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=USER&pwd=PASSWORD" > /dev/shm/GetCams/Xwebc2-temp.jpeg)
timeout --kill-after=15 15 avconv -f video4linux2 -s 1920x1080 -i /dev/video0 -ss 00:00:02 -frames 1 /dev/shm/GetCams/Xwebc1-temp.jpeg

MainLabel="$(date +'%Y-%m-%d %H:%M:%S') -- OJC ${LOJCTF}F -- IN ${LCaseTF}F -- CPU ${LCPUTF}F -- ${LUStatus}"

if [ ! -f /dev/shm/GetCams/Xwebc1-temp.jpeg ]; then
	UACam1=$((UACam1 + 1))
	convert -size 1920x1080 -gravity center -annotate 0 'Cam1 temporarily unavailable!' -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Xwebc1-temp.jpeg
	else UACam1=0
fi

if [ ! -f /dev/shm/GetCams/Xwebc2-temp.jpeg ]; then
	UACam2=$((UACam2 + 1))
	convert -size 954x540 -gravity center -annotate 0 'Cam2 temporarily unavailable!' -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Xwebc2-temp.jpeg
	else  UACam2=0 &mogrify -resize 954x540! /dev/shm/GetCams/Xwebc2-temp.jpeg
fi

if [ ! -f /dev/shm/GetCams/Xwebc3-temp.jpeg ]; then
	UACam3=$((UACam3 + 1))
	convert -size 954x540 -gravity center -annotate 0 'Cam3 temporarily unavailable!' -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Xwebc3-temp.jpeg
	else UACam3=0 & mogrify -resize 954x540! /dev/shm/GetCams/Xwebc3-temp.jpeg
fi

if [ $UACam1 = 6 ]; then
	echo "Camera 1 offline more than 6 intervals!" | mail -s "Camera 1 offline!" EMAIL@ADDRESS.COM
fi

if [ $UACam2 = 6 ]; then
	echo "Camera 2 offline more than 6 intervals!" | mail -s "Camera 2 offline!" EMAIL@ADDRESS.COM
fi

if [ $UACam3 = 6 ]; then
	echo "Camera 3 offline more than 6 intervals!" | mail -s "Camera 3 offline!" EMAIL@ADDRESS.COM
fi

convert \( /dev/shm/GetCams/Xwebc1-temp.jpeg +append \) \
 \( /dev/shm/GetCams/Xwebc2-temp.jpeg /dev/shm/GetCams/Xwebc3-temp.jpeg +append \) \
 \( -gravity south -background Black -pointsize 48 -fill Yellow label:"${MainLabel}" +append \) \
 -background Black -append -resize 75% /dev/shm/GetCams/webcX-temp.jpeg

(
rm /dev/shm/GetCams/Xwebc*-temp.jpeg &
cp /dev/shm/GetCams/webcX-temp.jpeg /dev/shm/GetCams/PushTmp/$(date +'%y%m%d%H%M%S').jpeg
)

rm /dev/shm/GetCams/webcX-temp.jpeg
