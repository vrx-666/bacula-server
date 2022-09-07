#!/bin/bash
: ${SD_Host:=""}
: ${DB_User:=""}
: ${DB_Password:=""}
: ${DB_Host:=""}
: ${DB_Port:="5432"}
: ${WEB_User:="admin"}
: ${WEB_Password:="difficult"}
: ${SMTP_Host:=""}
: ${SMTP_Port:="587"}
: ${SMTP_User:="root"}
: ${SMTP_Password:=""}
: ${EMAIL_Recipient:="root"}
: ${SD_Password:="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c24)"}
: ${Console_Password:="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c24)"}
: ${FD_Password:="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c24)"}
: ${SD_Mon:="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c24)"}
: ${FD_Mon:="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c24)"}
: ${DIR_Mon:="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c24)"}

if [ -z ${SD_Host} ];then
	echo "==> SD_Host must be set, exiting"
	exit 1
fi

if [ -z ${DB_Host} ];then
	echo "==> DB_Host must be set, exiting"
	exit 1
fi

if [ -z ${DB_User} ];then
	echo "==> DB_User must be set, exiting"
	exit 1
fi

if [ -z ${DB_Password} ];then
	echo "==> DB_Password must be set, exiting"
	exit 1
fi

CONFIG_VARS=(
  SD_Host
  SD_Password
  Console_Password
  FD_Password
  SD_Mon
  FD_Mon
  DIR_Mon
)

DB_VARS=(
  DB_User
  DB_Password
  DB_Host
  DB_Port
)

SMTP_VARS=(
  SMTP_Host
  SMTP_Port
)

AUTH_VARS=(
  SMTP_User
  SMTP_Password
)

: ${check:=10}

if [ ! -f /opt/bacula/etc/bacula-sd.conf ];then
	echo "==> Creating Storage daemon config..."
	cp -rp /home/bacula/etc/bacula-sd.conf /opt/bacula/etc/bacula-sd.conf
	chown bacula:tape /opt/bacula/etc/bacula-sd.conf
	chmod g+w /opt/bacula/etc/bacula-sd.conf
	check=$((check+1))
fi
if [ ! -f /opt/bacula/etc/bacula-fd.conf ];then
	echo "==> Creating File daemon config..."
	cp -rp /home/bacula/etc/bacula-fd.conf /opt/bacula/etc/bacula-fd.conf
	chown bacula:bacula /opt/bacula/etc/bacula-fd.conf
	chmod g+w /opt/bacula/etc/bacula-fd.conf
	check=$((check+1))
fi
if [ ! -f /opt/bacula/etc/bacula-dir.conf ];then
	echo "==> Creating Bacula Director config..."
	cp -rp /home/bacula/etc/bacula-dir.conf /opt/bacula/etc/bacula-dir.conf
	cp -rp /home/bacula/etc/bconsole.conf /opt/bacula/etc/bconsole.conf
	chown bacula:bacula /opt/bacula/etc/bacula-dir.conf
	chmod g+w /opt/bacula/etc/bacula-dir.conf
	check=$((check+1))
fi
if [ ! -f /opt/bacula/etc/bconsole.conf ];then
	cp -rp /home/bacula/etc/bconsole.conf /opt/bacula/etc/bconsole.conf
	check=$((check+1))
fi

chmod +rx /opt/bacula/bin/*
for file in $(ls -la /opt/bacula/scripts | grep "\-rwx" | awk '{print $NF}'); do 
	chmod +x /opt/bacula/scripts/$file
done
chown -R bacula:bacula /opt/bacula/working
chown -R bacula:tape /mnt/bacula
chown bacula:tape /opt/bacula/log

for c in ${CONFIG_VARS[@]}; do
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bacula-fd.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bacula-sd.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bacula-dir.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bconsole.conf
done

sed -i "s,@SMTP_User@,${SMTP_User}," /opt/bacula/etc/bacula-dir.conf
sed -i "s,@EMAIL_Recipient@,${EMAIL_Recipient}," /opt/bacula/etc/bacula-dir.conf

if [ ! -d /etc/baculum/Config-api-apache ];then
	echo "==> Creating Baculum API config..."
	cp -rp /home/baculum/Config-api-apache /etc/baculum/
	chown -R www-data:www-data /etc/baculum/Config-api-apache
fi
if [ ! -d /etc/baculum/Config-web-apache ];then
	echo "==> Creating Baculum Web config..."
	cp -rp /home/baculum/Config-web-apache /etc/baculum/
	chown -R www-data:www-data /etc/baculum/Config-web-apache
fi

for d in ${DB_VARS[@]}; do
  sed -i "s,@${d}@,$(eval echo \$$d)," /opt/bacula/etc/bacula-dir.conf
  sed -i "s,@${d}@,$(eval echo \$$d)," /etc/baculum/Config-api-apache/api.conf
done


check_conf=$(/opt/bacula/bin/bacula-dir -t)
echo "==> Checking DB..."
check_db=$(echo $check_conf | grep -i "Unable to connect" | wc -l)
check_tb=$(echo $check_conf | grep -i "Could not open Catalog" | wc -l)

if [ $check_db -gt 0 ];then
	echo "==> Could not connect to database. Please check DB Settings: Host, User, Password, Port. exiting"
	exit 1
elif [ $check_tb -gt 0 ];then
	if [ $check -eq 13 ] || [ $check -eq 14 ]; then
		echo "==> Catalog database empty. Structure creating..."
		sed -i 's/pre_command="su - postgres -c"/pre_command=""/' /opt/bacula/scripts/create_bacula_database
		sed -i 's/pre_command="su - postgres -c"/pre_command=""/' /opt/bacula/scripts/make_bacula_tables
		sed -i "s/CREATE DATABASE.*$//" /opt/bacula/scripts/create_postgresql_database
		sed -i 's/^bindir.*//' /opt/bacula/scripts/make_postgresql_tables
		sed -i "s/psql /PGPASSWORD=${DB_Password} psql -h ${DB_Host} -p ${DB_Port} -U ${DB_User} /g" /opt/bacula/scripts/create_postgresql_database
		sed -i "s/psql /PGPASSWORD=${DB_Password} psql -h ${DB_Host} -p ${DB_Port} -U ${DB_User} /g" /opt/bacula/scripts/make_postgresql_tables
		/opt/bacula/scripts/create_bacula_database
		/opt/bacula/scripts/make_bacula_tables
		sleep 5s
	else
		echo "==> It looks like You run bacula-server before. Configuration files are set, but database is empty. Make sure everything going right."
		echo "===== You can ommit this check by setting ENV 'check=0', but this will cause importing clean database, clean schema without history of backups done in the past"
		exit 1
	fi
	counter=0
	while [ $(/opt/bacula/bin/bacula-dir -t | grep -i "Could not open Catalog" | wc -l) -gt 0 ]; do
		sleep 5s
		counter=$((counter+1))
		if [ $counter -gt 20 ];then
			echo "==> Probably there is problem with Your Catalog database... Exiting"
			exit 1
		fi
	done
	echo "" > /opt/bacula/log/bacula.log
else
	sed -i 's/pre_command="su - postgres -c"/pre_command=""/' /opt/bacula/scripts/update_bacula_tables
	sed -i "s/psql /PGPASSWORD=${DB_Password} psql -h ${DB_Host} -p ${DB_Port} -U ${DB_User} /g" /opt/bacula/scripts/update_postgresql_tables
	/opt/bacula/scripts/update_bacula_tables
fi

chown -R bacula:bacula /opt/bacula/working
chown -R bacula:tape $(grep -E "Archive.*Device.*=" /opt/bacula/etc/bacula-sd.conf|grep -v "/dev/"|awk -F "=" '{print $2}'|sort -u|tr "\n" " "|tr -d '"')
chmod 777 /opt/bacula/log /opt/bacula/etc
chown bacula:tape /opt/bacula/log
chown -R bacula:bacula /opt/bacula/etc

htpasswd -bm /etc/baculum/Config-web-apache/baculum.users ${WEB_User} ${WEB_Password}
if [ `grep "\[${WEB_User}\]" /etc/baculum/Config-web-apache/users.conf | wc -l` -lt 1 ];then
        echo "" >> /etc/baculum/Config-web-apache/users.conf
        echo -e "[${WEB_User}]\nlong_name = \"\"\ndescription = \"\"\nemail = \"\"\nroles = \"admin\"\nenabled = \"1\"\nips = \"\"\nusername = \"${WEB_User}\"" >> /etc/baculum/Config-web-apache/users.conf
fi

cp /opt/exim-default-conf/update-exim4.conf.conf /etc/exim4/
chown root:root /etc/exim4/update-exim4.conf.conf
chmod 644 /etc/exim4/update-exim4.conf.conf
cp /opt/exim-default-conf/passwd.client /etc/exim4/
chown root:Debian-exim /etc/exim4/passwd.client
chmod 640 /etc/exim4/passwd.client
cp /opt/exim-default-conf/exim4.conf.template /etc/exim4/exim4.conf.template
chown Debian-exim /var/log/exim4

for c in ${SMTP_VARS[@]}; do
  sed -i "s,@${c}@,$(eval echo \$$c)," /etc/exim4/update-exim4.conf.conf
done

for a in ${AUTH_VARS[@]}; do
  sed -i "s,@${a}@,$(eval echo \$$a)," /etc/exim4/passwd.client
  sed -i "s,@${a}@,$(eval echo \$$a)," /etc/exim4/exim4.conf.template
done

domain=$(echo "${SMTP_User}" | sed -e 's/.*@//g')
sed -i "s,@domain@,$domain," /etc/exim4/update-exim4.conf.conf
sed -i "s,@SMTP_User@,${SMTP_User}," /opt/bacula/etc/bacula-dir.conf
sed -i "s,@EMAIL_Recipient@,${EMAIL_Recipient}," /opt/bacula/etc/bacula-dir.conf
update-exim4.conf

if [ ! -z ${SMTP_Host} ];then
	sed -i '/;\[program:mailserver/,/;autorestart/{s/;//g}' /etc/supervisord.conf
fi

echo "==> Starting..."
echo "==> .......Storage Daemon..."
/etc/init.d/bacula-sd start
echo "==> .......File Daemon..."
/etc/init.d/bacula-fd start
echo "==> .......Bacula Director..."
/etc/init.d/bacula-dir start
echo "==> .......Bacula Web..."
exec "$@"
