# GetCams

IP/USB Camera shell script

Main Revision 4

Updated 2017-02-12

Captures camera still shots every 0.5 seconds, writes them to disk every 2 minutes as a MP4, and creates an animated GIF you can display in a web interface. All scripts are stored in memory to increase performance and reduce disk wear. 

Syncs to Google Drive for added cloud backup.

This will require a few additional packages -

 avconv, imagemagick, postfix, gdrive.
 
 You can also implement apcupsd, snmpd, and other packages if you wish. I removed hooks to "keep it simple."

User names, passwords, and email addresses have been edited out of the scripts. Adjust the scripts as you wish.

- Booter.sh should be set to run on Boot in crontab.
- GetCams_GIF.sh should be set to run every 2 minutes in crontab.
- MakeMP4.sh should be set to run once daily in crontab anytime you choose.
