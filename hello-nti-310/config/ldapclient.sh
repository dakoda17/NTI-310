#!/bin/bash
#this is my file for the document ldapclient.sh with some additions
# this doesn't reallly work it has some fixes to it: https://www.tecmint.com/configure-ldap-client-to-connect-external-authentication/ 
# it requires that my ldapc server is running

#in the client
apt-get update
apt-get install -y debconf-utils
export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nscd
unset DEBIAN_FRONTEND

#cd to root to make a tempfile like this: cd ~ : then
#vim /tempfile: copied over the ldap carrot text without a carrot into the tempfile
#now: while read line; do echo "$line" | debconf-set-selections; done < /tempfile
#now: echo "password > /etc/ldap.secret we still have to echho the root passwd into root/etc/password echo passoword into ldap secret

#not sure if i still need this: sudo apt update && sudo apt install -y libnss-ldap libpam-ldap ldap-utils nscd


#format of sed: sed -i 's/thing1/thing2/g' OR
#sed -i(insert) 's(search)$(for)thing1&
#we used this line: apt-get install debconf-utils
#we used this line: debconf-get-selections | grep ^ldap


#get rid of the i in ladpi add the name of my server: ldap://ldapc/
#next screen: dc-nti310,dc=local , 3, yes, no 

#in the sever
#for manager account go to https on the ldap server go to the ip, remove the s /phpldapadmin - take the entire line from the login and paste it
#sudo su into the server cat /root/ldap_admin_pass copy the password into the client and OK

#in the client
#paste in password for the manager account
#from the linked file (name server switch) paste in:
sudo auth-client-config -t nss -p lac_ldap 
sudo pam-auth-update 

# 1-3 and 5 are already starred by default are therefore we dont' need line 11

sudo systemctl restart nscd
sudo systemctl enable nscd

#vim /etc/pam.d/su - then paste: account sufficient pam_succeed_if.so uid = 0 use_uid quiet - as line 7 under line 6 
# or echo " sufficient pam_succeed_if.so uid = 0 use_uid quiet" >> /etc/pam.d/su
# vim /etc/ldap/ldap.conf
#uncomment BASE and URI
# make this change: BASE    dc=nti310,dc=local  and URI     ldap://ldapc
#getent passwd - this will show us the uses we created
#now test loging in to one of the users via su like this: su - Person1
#the result should be: No directoryy, loggin in with HOME=/
#exit to return to cl
