#!/bin/bash

CamPath="/dev/shm/GetCams"
CamWebPath="/var/www/Get/Cams"
ramDrive="/dev/shm"
GoogleDrivePath=""

getLockTime=$(date +'%y%m%d%H%M%S')

mkdir $CamPath/DumpTmp
mv $CamPath/PushTmp/*.jpeg $CamPath/DumpTmp
find $CamPath/DumpTmp/ -type f -size 0b -delete
bash $ramDrive/Sequence.sh $CamPath/DumpTmp/ jpeg
cp $CamPath/DumpTmp/00001.jpeg $CamWebPath/_Latest.jpeg
ffmpeg -threads 8 -framerate 12 -i $CamPath/DumpTmp/%05d.jpeg -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -vcodec libx264 -pix_fmt yuv420p $CamWebPath/Archive/push_$getLockTime.mp4 2> $CamWebPath/MakeMP4_GIF.log
mogrify -resize 25% $CamWebPath/_Latest.jpeg
cp $CamWebPath/Archive/push_$getLockTime.mp4 $CamWebPath/_Loop.mp4
gdrive sync upload --keep-local $CamWebPath/Archive/ $GoogleDrivePath
rm -fr $CamPath/DumpTmp
