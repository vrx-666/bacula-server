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
if [ ! -f /var/lib/bacula/bacula.db ];then
	echo "==> Catalog database missing. Creating..."
	cp -rp /opt/bacula.db /var/lib/bacula/bacula.db
fi
check_conf=$(/usr/sbin/bacula-dir -t)
check_tb=$(echo $check_conf | grep -i "Could not open Catalog" | wc -l)
if [ $check_tb -gt 0 ];then
			echo "==> Probably there is problem with Your Catalog database... Exiting"
			exit 1
fi


chown bacula:tape /var/lib/bacula
chown bacula:tape /mnt/bacula
chown bacula:tape /var/log/bacula
chown bacula:bacula /var/lib/bacula/bacula.db

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
