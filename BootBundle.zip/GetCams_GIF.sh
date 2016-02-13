#!/bin/bash

snmpwalk localhost . > /dev/shm/snmpwalk.txt
if [ -f "/dev/shm/snmpwalk.txt" ]; then
	CaseT32=$(sed -n "/.*lmTempSensorsValue\.29/p" /dev/shm/snmpwalk.txt | sed 's/.*Gauge32\: //')
	CPUT32=$(sed -n '/.*lmTempSensorsValue\.3 \=/p' /dev/shm/snmpwalk.txt | sed 's/.*Gauge32\: //')
	if [ -z "$CaseT32" ]; then
		CaseTF="EMPTY"
	else
		CaseTF=$(((($CaseT32/1000)*9/5+32)-6))
	fi
	if [ -z "$CPUT32" ]; then
		CPUTF="EMPTY"
	else
		CPUTF=$(((($CPUT32/1000)*9/5+32)-6))
	fi
else
	CaseTF="DOWN"
	CPUTF="DOWN"
fi

UStatus=$(curl "http://127.0.0.1/cgi-bin/apcupsd/upsstats.cgi" 2>&1 /dev/null/ | sed -n 's/.*Status:\ //p')

if [ -z "$UStatus" ]; then
	UStatus="ERROR"
fi

echo $CaseTF > /dev/shm/GetCams/CaseTF.txt
echo $CPUTF > /dev/shm/GetCams/CPUTF.txt
echo $UStatus > /dev/shm/GetCams/LUStatus.txt

convert -delay 15 -loop 0 -resize 25% /dev/shm/GetCams/PushTmp/*.jpeg /var/www/Get/Cams/_Loop.gif
zip -9 /var/www/Get/Cams/Archive/push_$(date +'%y%m%d%H%M%S').zip /dev/shm/GetCams/PushTmp/*.jpeg
chown -R WEBUSER /var/www/Get/Cams/

rm /dev/shm/GetCams/PushTmp/*.jpeg
