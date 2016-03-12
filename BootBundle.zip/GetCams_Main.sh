#!/bin/bash

SendTo=$(cat /dev/shm/SMS.txt)

LUStatus=$(cat /dev/shm/GetCams/LUStatus.txt)
LCaseTF=$(cat /dev/shm/GetCams/CaseTF.txt)
LCPUTF=$(cat /dev/shm/GetCams/CPUTF.txt)
LOJCTF=$(cat /dev/shm/OJC.txt)

UACam1=$(cat /dev/shm/GetCams/OffCam1.txt)
UACam2=$(cat /dev/shm/GetCams/OffCam2.txt)
UACam3=$(cat /dev/shm/GetCams/OffCam3.txt)
UACam1T=$(cat /dev/shm/GetCams/OffCam1T.txt)
UACam2T=$(cat /dev/shm/GetCams/OffCam2T.txt)
UACam3T=$(cat /dev/shm/GetCams/OffCam3T.txt)

(
curl --max-time 3 "http://192.168.1.5:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=IPCamUser&pwd=IPCamPass" > /dev/shm/GetCams/Xwebc3-temp.jpeg &
curl --max-time 3 "http://192.168.1.6:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=IPCamUser&pwd=IPCamPass" > /dev/shm/GetCams/Xwebc2-temp.jpeg
)

if [ -e "/dev/video"* ]; then
	USBCamRef=$(ls /dev/video*)
	timeout --kill-after=15 15 avconv -f video4linux2 -s 1920x1080 -i $USBCamRef -ss 00:00:01.0 -frames 1 /dev/shm/GetCams/Xwebc1-temp.jpeg
fi

MainLabel="$(date +'%Y-%m-%d %H:%M:%S') -- OJC ${LOJCTF}F -- IN ${LCaseTF}F -- CPU ${LCPUTF}F -- ${LUStatus}"

if [ ! -f /dev/shm/GetCams/Xwebc1-temp.jpeg ]; then
	UACam1=$((UACam1 + 1))
	UACam1T=$((UACam1T + 1))
	if [ $UACam1 -eq 100 ]; then
		echo "Camera 1 offline more than 100 cycles!" | mail -s "Camera 1 offline!" $SendTo
	fi
	convert -size 1920x1080 -gravity center -annotate 0 "Cam1 temporarily unavailable!\n Cycles: ${UACam1}" -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Xwebc1-temp.jpeg
else
		UACam1=0
		UACam1T=$((UACam1T + 0))

fi

if [ ! -s /dev/shm/GetCams/Xwebc2-temp.jpeg ]; then
	UACam2=$((UACam2 + 1))
	UACam2T=$((UACam2T + 1))
	if [ $UACam3 -eq 100 ]; then
		echo "Camera 2 offline more than 100 cycles!" | mail -s "Camera 2 offline!" $SendTo
	fi
	convert -size 954x540 -gravity center -annotate 0 "Cam2 temporarily unavailable!\n Cycles:  ${UACam2}" -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Xwebc2-temp.jpeg
else 
	UACam2=0
	UACam2T=$((UACam2T + 0))
	mogrify -resize 954x540! /dev/shm/GetCams/Xwebc2-temp.jpeg
fi

if [ ! -s /dev/shm/GetCams/Xwebc3-temp.jpeg ]; then
	UACam3=$((UACam3 + 1))
	UACam3T=$((UACam1T + 1))
	if [ $UACam3 -eq 100 ]; then
		echo "Camera 3 offline more than 100 cycles!" | mail -s "Camera 3 offline!" $SendTo
	fi
	convert -size 954x540 -gravity center -annotate 0 "Cam3 temporarily unavailable!\n Cycles: ${UACam3}" -pointsize 48 -fill Yellow xc:navy /dev/shm/GetCams/Xwebc3-temp.jpeg
else	
	UACam3=0
	UACam3T=$((UACam3T + 0))
	mogrify -resize 954x540! /dev/shm/GetCams/Xwebc3-temp.jpeg
fi

convert \( /dev/shm/GetCams/Xwebc1-temp.jpeg +append \) \
 \( /dev/shm/GetCams/Xwebc2-temp.jpeg /dev/shm/GetCams/Xwebc3-temp.jpeg +append \) \
 \( -gravity south -background Black -pointsize 48 -fill Yellow label:"${MainLabel}" +append \) \
 -background Black -append -resize 1152x1006! /dev/shm/GetCams/webcX-temp.jpeg

(
rm /dev/shm/GetCams/Xwebc*-temp.jpeg &
cp /dev/shm/GetCams/webcX-temp.jpeg /dev/shm/GetCams/PushTmp/$(date +'%y%m%d%H%M%S').jpeg
)

rm /dev/shm/GetCams/webcX-temp.jpeg

(
echo $UACam1 > /dev/shm/GetCams/OffCam1.txt &
echo $UACam2 > /dev/shm/GetCams/OffCam2.txt &
echo $UACam3 > /dev/shm/GetCams/OffCam3.txt &
echo $UACam1T > /dev/shm/GetCams/OffCam1T.txt &
echo $UACam2T > /dev/shm/GetCams/OffCam2T.txt &
echo $UACam3T > /dev/shm/GetCams/OffCam3T.txt
)
