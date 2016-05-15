#!/bin/bash
tA=0.98
CamPath="/dev/shm/GetCams"

if [ -f "/dev/shm/snmpwalk.txt" ]; then
	CaseT32=$(sed -n "/.*lmTempSensorsValue\.29/p" /dev/shm/snmpwalk.txt | sed 's/.*Gauge32\: //')
	CPUT32=$(sed -n '/.*lmTempSensorsValue\.3 \=/p' /dev/shm/snmpwalk.txt | sed 's/.*Gauge32\: //')
	if [ -z "$CaseT32" ]; then
		CaseT32=$(sed -n '/.*SYSTIN\:\,+/p' /dev/shm/sensors.txt | cut -d ',' -f 2 | sed 's/[^0-9]*//g')
		if [ -z "$CaseT32" ]; then
			CaseTF="NA"
		fi
		CaseAdj=$(echo "$CaseT32"*"$tA" | bc)
		CaseAdj=${CaseAdj%.*}
		CaseTF=$(((($CaseAdj/10)*9/5+32)-6))
	else
		CaseTF=$(((($CaseT32/1000)*9/5+32)-6))
	fi
	if [ -z "$CPUT32" ]; then
		CPUT32=$(sed -n '/.*Physical\,id\,0\:\,+/p' /dev/shm/sensors.txt | cut -d ',' -f 4 | sed 's/[^0-9]*//g')
		if [ -z "$CPUT32" ]; then
			CPUTF="NA"
		fi
		CPUAdj=$(echo "$CPUT32"*"$tA" | bc)
		CPUAdj=${CPUAdj%.*}
		CPUTF=$(((($CPUAdj/10)*9/5+32)-6))
	else
		CPUTF=$(((($CPUT32/1000)*9/5+32)-6))
	fi
else
	CaseTF="ERR"
	CPUTF="ERR"
fi

UStatus=$(curl "http://127.0.0.1/cgi-bin/apcupsd/upsstats.cgi" 2>&1 /dev/null/ | sed -n 's/.*Status:\ //p')

if [ -z "$UStatus" ]; then
	UStatus="ERROR"
fi

echo $CaseTF > $CamPath/CaseTF.txt
echo $CPUTF > $CamPath/CPUTF.txt
echo $UStatus > $CamPath/LUStatus.txt

getLockTime=$(date +'%y%m%d%H%M%S')

mkdir $CamPath/DumpTmp
mv $CamPath/PushTmp/*.jpeg $CamPath/DumpTmp
find $CamPath/DumpTmp/ -type f -size 0b -delete
convert -delay 15 -loop 0 -resize 25% $CamPath/DumpTmp/*.jpeg +dither -colors 52 -layers OptimizeTransparency /var/www/Get/Cams/_Loop.gif
bash /dev/shm/Sequence.sh $CamPath/DumpTmp/ jpeg
ffmpeg -threads 8 -framerate 24 -i $CamPath/DumpTmp/%05d.jpeg -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -vcodec libx264 -pix_fmt yuv420p /var/www/Get/Cams/Archive/push_$getLockTime.mp4 2> /var/www/Get/Cams/MakeMP4_GIF.log
rm -fr $CamPath/DumpTmp
