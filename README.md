# GetCams

IP/USB Camera shell script
-revision 2013-03-12

Captures camera still shots every 2 seconds, writes them to disk every 2 minutes, and creates an animated GIF you can display in a web interface. All scripts are stored in memory to increase performance and reduce disk wear.

This will require a few additional packages -

 avconv, imagemagick, postfix, snmpd, apcupsd, lmsensors, possibly others. 

User names, passwords, and email addresses have been edited out of the scripts. Adjust the scripts as you wish.

- GetCams.sh should be set to run on boot in crontab.
- GetCams_GIF.sh should be set to run every 2 minutes in crontab.
- MakeMP4.sh should be set to run once daily in crontab anytime you choose.
