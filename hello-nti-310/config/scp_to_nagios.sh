#!/bin/bash
bash generate_config.sh $1 $2
gcloud compute scp --zone us-east4-c $1.cfg koda@nagios4419:/etc/nagios/servers
# Note: I had to add user nicolebade to group nagios using usermod -a -G nagios nicolebade
# I also had to chmod 775 /etc/nagios/conf.d
#usermod -a -G nagios nicolebade
gcloud compute ssh --zone us-east4-c koda@nagios4419 --command='sudo /usr/sbin/nagios -v /etc/nagios/nagios.cfg'
