#!/bin/bash

EMail=
SourceFolder="/var/www/Get/Cams/Archive"
UnpackFolder="/dev/shm/mp4tmp"
getYesterday=$(date -d "yesterday 12:00" +'%y%m%d')

mkdir -p $UnpackFolder
#zip -9rv /home/User/Desktop/CamBack-$(date -d "yesterday 12:00" +'%y%m%d').zip $SourceFolder/*
mv $SourceFolder/* $UnpackFolder
bash /dev/shm/Sequence.sh $UnpackFolder/ mp4
for filename in $UnpackFolder/*.mp4; do
	echo "file '$filename'" >> $UnpackFolder/Listing.txt
done
ffmpeg -threads 8 -f concat -i $UnpackFolder/Listing.txt -c copy /var/www/Get/Cams/MP4/$getYesterday.mp4 2> /var/www/Get/Cams/MakeMP4_Last.log
CamImgQty=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 /var/www/Get/Cams/MP4/$getYesterday.mp4)
CamMP4Size=$(du -c /var/www/Get/Cams/MP4/$getYesterday.mp4 | sed -n "\$s/\\t.*//p")
(ls /var/www/Get/Cams/MP4/*.mp4 -t | head -n 60; ls /var/www/Get/Cams/MP4/*.mp4)|sort|uniq -u|xargs rm
chown -R www-data /var/www/Get/Cams/MP4/
mysql Core << EOF
insert into Log_CamsMP4 (Date,ImgCount,MP4Size) values (CURDATE()-1,'$CamImgQty','$CamMP4Size');
EOF
rm -fr $UnpackFolder
