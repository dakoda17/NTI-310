#!/bin/bash
#named as rsyslogtest.sh
status=$(tail /var/log/messages > grep | date)        # Change the status to test different alert states originally ("0"). 
currentDate=$(date)
if [ "$status" == "$currentDate" ]; then
    echo "STATUS:OK - Syslog is up."
    exit 0;
  elif [ "$status" != "$currentDate" ]; then
    echo "STATUS:CRITICAL - Syslog could not be reached."
    exit 2;
  elif [ "$status" <= "$currentDate" ]; then
    echo "STATUS:WARNING"
    exit 1;
else
   echo "Syslog could not be reached or is not functional."
   exit 3;
fi
