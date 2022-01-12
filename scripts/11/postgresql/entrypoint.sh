#!/bin/bash
: ${SD_Host:=""}
: ${DB_User:=""}
: ${DB_Password:=""}
: ${DB_Host:=""}
: ${DB_Port:="5432"}
: ${WEB_User:="admin"}
: ${WEB_Password:="difficult"}
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

: ${check:=10}

if [ ! -f /opt/bacula/etc/bacula-sd.conf ];then
	echo "==> Creating Storage daemon config..."
	cp -rp /home/bacula/etc/bacula-sd.conf /opt/bacula/etc/bacula-sd.conf
	cp -rp /home/bacula/working /opt/bacula/
	chown bacula:bacula /opt/bacula/etc/bacula-sd.conf
	chmod g+w /opt/bacula/etc/bacula-sd.conf
	check=$((check+1))
fi
if [ ! -f /opt/bacula/etc/bacula-fd.conf ];then
	echo "==> Creating File daemon config..."
	cp -rp /home/bacula/etc/bacula-fd.conf /opt/bacula/etc/bacula-fd.conf
	cp -rp /home/bacula/working /opt/bacula/
	chown bacula:bacula /opt/bacula/etc/bacula-fd.conf
	chmod g+w /opt/bacula/etc/bacula-fd.conf
	check=$((check+1))
fi
if [ ! -f /opt/bacula/etc/bacula-dir.conf ];then
	echo "==> Creating Bacula Director config..."
	cp -rp /home/bacula/etc/bacula-dir.conf /opt/bacula/etc/bacula-dir.conf
	cp -rp /home/bacula/etc/bconsole.conf /opt/bacula/etc/bconsole.conf
	cp -rp /home/bacula/scripts /opt/bacula/
	cp -rp /home/bacula/working /opt/bacula/
	chown bacula:bacula /opt/bacula/etc/bacula-dir.conf
	chmod g+w /opt/bacula/etc/bacula-dir.conf
	check=$((check+1))
fi
if [ ! -f /opt/bacula/etc/bconsole.conf ];then
	cp -rp /home/bacula/etc/bconsole.conf /opt/bacula/etc/bconsole.conf
	check=$((check+1))
fi
cp -rup /home/bacula/scripts /opt/bacula/

for c in ${CONFIG_VARS[@]}; do
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bacula-fd.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bacula-sd.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bacula-dir.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /opt/bacula/etc/bconsole.conf
done

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

sed -i "s/Owner: bacula/Owner: $DB_User/g" /home/bacula.db
sed -i "s/OWNER TO bacula/OWNER TO $DB_User/g" /home/bacula.db

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
		PGPASSWORD=${DB_Password} psql -h ${DB_Host} -p ${DB_Port} bacula ${DB_User} < /home/bacula.db
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
fi

chown -R bacula:bacula /opt/bacula/working
chown bacula:tape /mnt/bacula
chown bacula:tape /opt/bacula/log

htpasswd -nbm ${WEB_User} ${WEB_Password} > /etc/baculum/Config-web-apache/baculum.users
sed -i "s/^\[.*\]$/\[${WEB_User}\]/g" /etc/baculum/Config-web-apache/users.conf
sed -i "s/^username =.*$/username = \"${WEB_User}\"/g" /etc/baculum/Config-web-apache/users.conf

echo "==> Starting..."
echo "==> .......Storage Daemon..."
/etc/init.d/bacula-sd start
echo "==> .......File Daemon..."
/etc/init.d/bacula-fd start
echo "==> .......Bacula Director..."
/etc/init.d/bacula-dir start
echo "==> .......Bacula Web..."
/usr/bin/supervisord -n -c /etc/supervisord.conf