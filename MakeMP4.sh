mkdir -p /dev/shm/mp4tmp
unzip -j /var/www/Get/Cams/Archive/"*.zip" -d /dev/shm/mp4tmp/
rm /var/www/Get/Cams/Archive/*.zip
CamImgQty=$(ls -l /dev/shm/mp4tmp/*.jpeg | wc -l)
CamSizeSum=$(du -c /dev/shm/mp4tmp/*.jpeg | sed -n "\$s/\\t.*//p")
sh /home/USER/Scripts/Sequence.sh /dev/shm/mp4tmp/ jpeg
avconv -framerate 24 -i /dev/shm/mp4tmp/%05d.jpeg -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" /var/www/Get/Cams/MP4/$(date -d "yesterday 12:00" +'%y%m%d').mp4 2> /dev/shm/mp4tmp/avconv.log
CamMP4Size=$(du -c /var/www/Get/Cams/MP4/$(date -d "yesterday 12:00" +'%y%m%d').mp4 | sed -n "\$s/\\t.*//p")
(ls /var/www/Get/Cams/MP4/*.mp4 -t | head -n 365; ls /var/www/Get/Cams/MP4/*.mp4)|sort|uniq -u|xargs rm
chown -R www-data /var/www/Get/Cams/MP4/
mysql -u SQLUSER -pSQLPASS DATABASE << EOF
insert into Log_CamsMP4 (Date,ImgCount,TotSize,MP4Size) values (CURDATE()-1,'$CamImgQty','$CamSizeSum','$CamMP4Size');
EOF
MP4Listing=$(ls -s /var/www/Get/Cams/MP4)
echo "AVConv Log Attached! \n $MP4Listing" | mail -s "AVConv nightly logfile." -a /dev/shm/mp4tmp/avconv.log EMAIL@ADDRESS.COM
rm -fr /dev/shm/mp4tmp
