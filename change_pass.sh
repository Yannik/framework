#!/bin/bash

if [ "$1" == "-h" ]
then
	echo "Usage: "
	echo "   "$0" [config]"
	echo
	echo "If config file is not specified, default is /etc/amportal.conf"
	echo
	exit
fi

if [ -n "$1" ]
then
	AMPCONFIG=$1
else
	AMPCONFIG=/etc/amportal.conf
fi

if [ ! -e $AMPCONFIG ]
then
	echo "Cannot find $AMPCONFIG"
	exit
fi

# include config file
echo "Reading $AMPCONFIG"
source $AMPCONFIG


echo "Updating configuration..."

echo "/etc/asterisk/cdr_mysql.conf"
sed -r -i "s/username=[a-zA-Z0-9]*/username=$AMPDBUSER/" /etc/asterisk/cdr_mysql.conf
sed -r -i "s/password=[a-zA-Z0-9]*/password=$AMPDBPASS/" /etc/asterisk/cdr_mysql.conf

echo $AMPWEBROOT"/admin/cdr/lib/defines.php"
sed -r -i "s/define \(\"USER\", \"[a-zA-Z0-9]*\"\);/define \(\"USER\", \"$AMPDBUSER\"\);/" $AMPWEBROOT/admin/cdr/lib/defines.php
sed -r -i "s/define \(\"PASS\", \"[a-zA-Z0-9]*\"\);/define \(\"PASS\", \"$AMPDBPASS\"\);/" $AMPWEBROOT/admin/cdr/lib/defines.php
sed -r -i "s/define \(\"WEBROOT\", \"[a-zA-Z0-9_-\.\/\\]*\"\);/define \(\"WEBROOT\", \"http:\/\/$AMPWEBADDRESS\/admin\/cdr\/\"\);/" $AMPWEBROOT/admin/cdr/lib/defines.php
sed -r -i "s!define \(\"FSROOT\", \"[a-zA-Z0-9_-\.\/\\]*\"\);!define \(\"FSROOT\", \"$AMPWEBROOT\/admin\/cdr\/\"\);!" $AMPWEBROOT/admin/cdr/lib/defines.php

# do a bunch at once here
find /var/www/html/admin/ -name retrieve\*.pl
sed -r -i "s/username = \"[a-zA-Z0-9]*\";/username = \"$AMPDBUSER\";/" `find /var/www/html/admin/ -name retrieve\*.pl`
sed -r -i "s/password = \"[a-zA-Z0-9]*\";/password = \"$AMPDBPASS\";/" `find /var/www/html/admin/ -name retrieve\*.pl`
sed -r -i "s!sip_conf = \"[a-zA-Z0-9_-\.\/\\]*\";!sip_conf = \"$AMPWEBROOT\/panel\/op_buttons_additional.cfg\";!" `find /var/www/html/admin/ -name retrieve\*.pl`

echo "/var/www/html/admin/common/db_connect.php"
sed -r -i "s/db_user = '[a-zA-Z0-9]*';/db_user = '$AMPDBUSER';/" /var/www/html/admin/common/db_connect.php
sed -r -i "s/db_pass = '[a-zA-Z0-9]*';/db_pass = '$AMPDBPASS';/" /var/www/html/admin/common/db_connect.php

echo "/etc/asterisk/manager.conf"
sed -r -i "s/secret = [a-zA-Z0-9]*/secret = $AMPMGRPASS/" /etc/asterisk/manager.conf
sed -r -i "/\[general\]/!s/\[[a-zA-Z0-9]+\]/[$AMPMGRUSER]/" /etc/asterisk/manager.conf

echo "/var/lib/asterisk/agi-bin/dialparties.agi"
sed -r -i "s/mgrUSERNAME='[a-zA-Z0-9]*';/mgrUSERNAME='$AMPDBUSER';/" /var/lib/asterisk/agi-bin/dialparties.agi
sed -r -i "s/mgrSECRET='[a-zA-Z0-9]*';/mgrSECRET='$AMPDBPASS';/" /var/lib/asterisk/agi-bin/dialparties.agi

echo $AMPWEBROOT"/panel/op_server.cfg"
sed -r -i "s/manager_user=[a-zA-Z0-9]*/manager_user=$AMPMGRUSER/" $AMPWEBROOT/panel/op_server.cfg
sed -r -i "s/manager_secret=[a-zA-Z0-9]*/manager_secret=$AMPMGRPASS/" $AMPWEBROOT/panel/op_server.cfg
sed -r -i "s/web_hostname=[a-zA-Z0-9_-\.]*/web_hostname=$AMPWEBADDRESS/" $AMPWEBROOT/panel/op_server.cfg
sed -r -i "s/security_code=[a-zA-Z0-9]*/security_code=$FOPPASSWORD/" $AMPWEBROOT/panel/op_server.cfg
sed -r -i "s!flash_dir=[a-zA-Z0-9_-\.\/\\]*!flash_dir=$AMPWEBROOT\/panel!" $AMPWEBROOT/panel/op_server.cfg
sed -r -i "s!web_hostname=[a-zA-Z0-9\.]*!web_hostname=$AMPWEBADDRESS!" $AMPWEBROOT/panel/op_server.cfg
sed -r -i "s!web_hostname=[a-zA-Z0-9\.]*!web_hostname=$AMPWEBADDRESS!" $AMPWEBROOT/panel/op_server.cfg

echo "/etc/asterisk/vm_email.inc (may require manual check)"
sed -i -e "s/AMPWEBADDRESS/$AMPWEBADDRESS/g" /etc/asterisk/vm_email.inc

echo "Done"
echo

exit

