#!/bin/bash

getYesterday=$(date -d "yesterday 12:00" +'%y%m%d')
camPath="/var/www/Get/Cams"

SourceFolder="/var/www/Get/Cams/Archive"
UnpackFolder="/dev/shm/mp4tmp"
mkdir -p $UnpackFolder
mv $SourceFolder/* $UnpackFolder
bash /dev/shm/Sequence.sh $UnpackFolder/ mp4
for filename in $UnpackFolder/*.mp4; do
	echo "file '$filename'" >> $UnpackFolder/Listing.txt
done
ffmpeg -threads 8 -safe 0 -f concat -i $UnpackFolder/Listing.txt -c copy $camPath/MP4/$getYesterday.mp4 2> $camPath/MakeMP4_Last.log
(ls $camPath/MP4/*.mp4 -t | head -n 14; ls $camPath/MP4/*.mp4)|sort|uniq -u|xargs rm
chown -R www-data $camPath/MP4/
rm -fr $UnpackFolder
