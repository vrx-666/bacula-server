#!/bin/bash
: ${SD_Host:=""}
: ${DB_User:=""}
: ${DB_Password:=""}
: ${DB_Host:=""}
: ${DB_Port:="3306"}
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

if [ ! -f /etc/bacula/bacula-sd.conf ];then
	echo "==> Creating Storage daemon config..."
	cp -rp /opt/bacula/bacula-sd.conf /etc/bacula/bacula-sd.conf
	chown bacula /etc/bacula/bacula-sd.conf
	chmod g+w /etc/bacula/bacula-sd.conf
	check=$((check+1))
fi
if [ ! -f /etc/bacula/bacula-fd.conf ];then
	echo "==> Creating File daemon config..."
	cp -rp /opt/bacula/bacula-fd.conf /etc/bacula/bacula-fd.conf
	chmod g+w /etc/bacula/bacula-fd.conf
	check=$((check+1))
fi
if [ ! -f /etc/bacula/bacula-dir.conf ];then
	echo "==> Creating Bacula Director config..."
	cp -rp /opt/bacula/bacula-dir.conf /etc/bacula/bacula-dir.conf
	cp -rp /opt/bacula/bconsole.conf /etc/bacula/bconsole.conf
	chown bacula /etc/bacula/bacula-dir.conf
	chmod g+w /etc/bacula/bacula-dir.conf
	check=$((check+1))
fi
if [ ! -f /etc/bacula/bconsole.conf ];then
	cp -rp /opt/bacula/bconsole.conf /etc/bacula/bconsole.conf
	check=$((check+1))
fi
cp -rup /opt/bacula/scripts /etc/bacula/

for c in ${CONFIG_VARS[@]}; do
  sed -i "s,@${c}@,$(eval echo \$$c)," /etc/bacula/bacula-fd.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /etc/bacula/bacula-sd.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /etc/bacula/bacula-dir.conf
  sed -i "s,@${c}@,$(eval echo \$$c)," /etc/bacula/bconsole.conf
done

if [ ! -d /etc/baculum/Config-api-apache ];then
	echo "==> Creating Baculum API config..."
	cp -rp /opt/baculum/Config-api-apache /etc/baculum/
	chown -R www-data:www-data /etc/baculum/Config-api-apache
fi
if [ ! -d /etc/baculum/Config-web-apache ];then
	echo "==> Creating Baculum Web config..."
	cp -rp /opt/baculum/Config-web-apache /etc/baculum/
	chown -R www-data:www-data /etc/baculum/Config-web-apache
fi

for d in ${DB_VARS[@]}; do
  sed -i "s,@${d}@,$(eval echo \$$d)," /etc/bacula/bacula-dir.conf
  sed -i "s,@${d}@,$(eval echo \$$d)," /etc/baculum/Config-api-apache/api.conf
done

check_conf=$(/usr/sbin/bacula-dir -t)
echo "==> Checking DB..."
check_db=$(echo $check_conf | grep -i "Unable to connect" | wc -l)
check_tb=$(echo $check_conf | grep -i "Could not open Catalog" | wc -l)
if [ $check_db -gt 0 ];then
	echo "==> Could not connect to database. Please check DB Settings: Host, User, Password, Port. exiting"
	exit 1
elif [ $check_tb -gt 0 ];then
	if [ $check -eq 13 ] || [ $check -eq 14 ]; then
		echo "==> Catalog database empty. Structure creating..."
		mysql -u ${DB_User} -h ${DB_Host} -p"${DB_Password}" -P ${DB_Port} bacula < /opt/bacula.db
		sleep 5s
	else
		echo "==> It looks like You run bacula-server before. Configuration files are set, but database is empty. Make sure everything going right."
		echo "===== You can ommit this check by setting ENV 'check=0', but this will cause importing clean database, clean schema without history of backups done in the past"
		exit 1
	fi
	counter=0
	while [ $(/usr/sbin/bacula-dir -t | grep -i "Could not open Catalog" | wc -l) -gt 0 ]; do
		sleep 5s
		counter=$((counter+1))
		if [ $counter -gt 20 ];then
			echo "==> Probably there is problem with Your Catalog database... Exiting"
			exit 1
		fi
	done
	echo "" > /var/log/bacula/bacula.log
fi

chown bacula:tape /var/lib/bacula
chown bacula:tape /mnt/bacula
chown bacula:tape /var/log/bacula

htpasswd -nbm ${WEB_User} ${WEB_Password} > /etc/baculum/Config-web-apache/baculum.users
sed -i "s/^\[.*\]$/\[${WEB_User}\]/g" /etc/baculum/Config-web-apache/users.conf
sed -i "s/^username =.*$/username = \"${WEB_User}\"/g" /etc/baculum/Config-web-apache/users.conf

echo "==> Starting..."
echo "==> .......Storage Daemon..."
/etc/init.d/bacula-sd start
echo "==> .......File Daemon..."
/etc/init.d/bacula-fd start
echo "==> .......Bacula Director..."
/etc/init.d/bacula-director start
echo "==> .......Bacula Web..."
/usr/bin/supervisord -n -c /etc/supervisord.conf
