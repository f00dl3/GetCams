CaseTC=$(sensors | sed -n 's/.*SYSTIN:\ //p' | sed 's/[^0-9]//g' | sed 's/0000//g')
CaseTF=$(((($CaseTC/10)*9/5+32)-7))

CPUTC=$(sensors | sed -n 's/.*Physical id 0:\ //p' | sed 's/[^0-9]//g' | sed 's/8001000//g')
CPUTF=$((($CPUTC/10)*9/5+32))

UStatus=$(curl "http://127.0.0.1/cgi-bin/apcupsd/upsstats.cgi" 2>&1 /dev/null/ | sed -n 's/.*Status:\ //p')

if [ -z "$UStatus" ]; then
	UStatus="Unknown"
fi 

echo $CaseTF > /dev/shm/GetCams/CaseTF.txt
echo $CPUTF > /dev/shm/GetCams/CPUTF.txt
echo $UStatus > /dev/shm/GetCams/LUStatus.txt

convert -delay 15 -loop 0 -resize 25% /dev/shm/GetCams/PushTmp/*.jpeg /var/www/Get/Cams/_Loop.gif
zip -9 /var/www/Get/Cams/Archive/push_$(date +'%y%m%d%H%M%S').zip /dev/shm/GetCams/PushTmp/*.jpeg
chown -R www-data /var/www/Get/Cams/

rm /dev/shm/GetCams/PushTmp/*.jpeg
