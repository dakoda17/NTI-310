#!/bin/bash
#-v removes anything that matches nagios 
for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v nagios4419 );  do 
    echo $servername;
    serverip=$( gcloud compute instances list | grep $servername | awk '{print $4}');
    echo $serverip ;
    bash scp_to_nagios.sh $servername $serverip
done
gcloud compute ssh --zone us-east1-c koda@nagios4419 --command='sudo systemctl restart nagios'
