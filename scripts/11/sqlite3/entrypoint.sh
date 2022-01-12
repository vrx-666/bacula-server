#!/bin/bash
: ${SD_Host:=""}
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

CONFIG_VARS=(
  SD_Host
  SD_Password
  Console_Password
  FD_Password
  SD_Mon
  FD_Mon
  DIR_Mon
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
if [ ! -f /opt/bacula/working/bacula.db ];then
	echo "==> Catalog database missing. Creating..."
	cp -rp /home/bacula.db /opt/bacula/working/bacula.db
fi

check_conf=$(/opt/bacula/bin/bacula-dir -t)
check_tb=$(echo $check_conf | grep -i "Could not open Catalog" | wc -l)
if [ $check_tb -gt 0 ];then
			echo "==> Probably there is problem with Your Catalog database... Exiting"
			exit 1
fi


chown -R bacula:bacula /opt/bacula/working
chown bacula:tape /mnt/bacula
chown bacula:tape /opt/bacula/log
chown bacula:bacula /opt/bacula/working/bacula.db

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