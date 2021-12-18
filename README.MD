# file created notifier

Small bash script to notify via pushover once a file with byte size > 0 is created in a certain directory.
pushover is a notification service where you can get notifications, e.g. to your smartphone: https://pushover.net/
Nevertheless, the script could be easily adapted to any other notification service which has a https api.
Furthermore, you could change what inotify should watch, e.g. if you only want to get notified when a file has been written to.

## requirements

jq and inotify-tools have to be installed first:

```sudo apt update && sudo apt install jq inotify-tools```

You will need a pushover account. You have to change the conf.json according to your user key and token! The conf.json has to be in the same directory as this script as of now.

## how to run the script

```bash notify_on_new_file_created.sh -d <absolute path to dir to be watched> -t <minimum time in between notifications in seconds>```

example for the current directory:

```bash notify_on_new_file_created.sh -d $(pwd) -t 60```

Since you might not want to get a notification everytime a file is created (e.g. when a bunch of log files are created in a small amount of time), you have to set the parameter "-t" in seconds. This prevents to send out a notification 
should the last notification be not older than the given time. Should you not be interested in that, just use "-t 0". Since one is usually not interested in files with a filesize of 0, this is also checked before sending out a notification.

