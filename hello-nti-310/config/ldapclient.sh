#!/bin/bash
# based off of https://www.tecmint.com/configure-ldap-client-to-connect-external-authentication
# with some additions that make it work, as opposed to not work

if [ -e /etc/ldap.secret]; then
exit 0;
fi

apt-get update
apt-get install -y debconf-utils
export DEBIAN_FRONTEND=noninteractive
apt-get --yes install libnss-ldap libpam-ldap ldap-utils nscd
unset DEBIAN_FRONTEND


echo "ldap-auth-config ldap-auth-config/bindpw password
nslcd nslcd/ldap-bindpw password
ldap-auth-config ldap-auth-config/rootbindpw password
ldap-auth-config ldap-auth-config/move-to-debconf boolean true
nslcd nslcd/ldap-sasl-krb5-ccname string /var/run/nslcd/nslcd.tkt
nslcd nslcd/ldap-starttls boolean false
libpam-runtime libpam-runtime/profiles multiselect unix, ldap, systemd, capability
nslcd nslcd/ldap-sasl-authzid string
ldap-auth-config ldap-auth-config/rootbinddn string cn=ldapadm,dc=nti310,dc=local
nslcd nslcd/ldap-uris string ldap://ldap2
nslcd nslcd/ldap-reqcert select
nslcd nslcd/ldap-sasl-secprops string
ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3
ldap-auth-config ldap-auth-config/binddn string cn=proxyuser,dc=example,dc=net
nslcd nslcd/ldap-auth-type select none
nslcd nslcd/ldap-cacertfile string /etc/ssl/certs/ca-certificates.crt
nslcd nslcd/ldap-sasl-realm string
ldap-auth-config ldap-auth-config/dbrootlogin boolean true
ldap-auth-config ldap-auth-config/override boolean true
nslcd nslcd/ldap-base string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/pam_password select md5
nslcd nslcd/ldap-sasl-mech select
nslcd nslcd/ldap-sasl-authcid string
ldap-auth-config ldap-auth-config/ldapns/base-dn string dc=nti310,dc=local
ldap-auth-config ldap-auth-config/ldapns/ldap-server string ldap://ldap2/
nslcd nslcd/ldap-binddn string
ldap-auth-config ldap-auth-config/dblogin boolean false" >> tempfile

while read line; do echo "$line" | debconf-set-selections; done < tempfile

echo "mypassword" > /etc/ldap.secret

chown 600 /etc/ldap.secret

sudo auth-client-config -t nss -p lac_ldap

echo "account sufficient pam_succeed_if.so uid = 0 use_uid quiet" >> /etc/pam.d/su

sed -i 's/base dc=example,dc=net/base dc=nti310,dc=local/g' /etc/ldap.conf
sed -i 's,uri ldapi:///,uri ldap://ldap2/,g' /etc/ldap.conf
sed -i 's/rootbinddn cn=manager,dc=example,dc=net/rootbinddn cn=ldapadm,dc=nti310,dc=local/g' /etc/ldap.conf

#for servername in $(gcloud compute instances list | awk '{print $1}' | sed "1 d" | grep -v nagios4419 );  do gcloud compute ssh --zone us-east1-b koda@$servername --command='sudo yum -y install wget && sudo wget https://raw.githubusercontent.com/dakoda17/NTI-310/master/hello-nti-310/config/nagiosclient421 && sudo bash nagiosclient421'; done


systemctl restart nscd
systemctl enable nscd
