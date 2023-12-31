#!/bin/bash
: ${SD_Host:=""}
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

chown bacula /home/bacula

CONFIG_VARS=(
  SD_Host
  SD_Password
  Console_Password
  FD_Password
  SD_Mon
  FD_Mon
  DIR_Mon
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
chmod -R g+w /opt/bacula/working
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

echo "==> Checking Bacularis config..."
cp -rpn /home/bacularis /etc/
chown -R www-data:www-data /etc/bacularis

if [ ! -f /opt/bacula/working/bacula.db ];then
	echo "==> Catalog database missing. Creating..."
	sed -i 's/^echo .*$//g' /opt/bacula/scripts/make_sqlite3_tables
	sudo -u bacula /opt/bacula/scripts/create_bacula_database
	sudo -u bacula /opt/bacula/scripts/make_bacula_tables
else
	sudo -u bacula /opt/bacula/scripts/update_bacula_tables
fi

check_conf=$(/opt/bacula/bin/bacula-dir -t)
check_tb=$(echo $check_conf | grep -i "Could not open Catalog" | wc -l)
if [ $check_tb -gt 0 ];then
			echo "==> Probably there is problem with Your Catalog database... Exiting"
			exit 1
fi

chown -R bacula:bacula /opt/bacula/working
chown -R bacula:tape $(grep -E "Archive.*Device.*=" /opt/bacula/etc/bacula-sd.conf|grep -v "/dev/"|awk -F "=" '{print $2}'|sort -u|tr "\n" " "|tr -d '"')
chmod 777 /opt/bacula/log /opt/bacula/etc
chown -R bacula:tape /opt/bacula/log
chown -R bacula:bacula /opt/bacula/etc
chown bacula:bacula /opt/bacula/working/bacula.db

htpasswd -bm /etc/bacularis/API/bacularis.users ${WEB_User} ${WEB_Password}
htpasswd -bm /etc/bacularis/Web/bacularis.users ${WEB_User} ${WEB_Password}
if [ `grep "\[${WEB_User}\]" /etc/bacularis/Web/users.conf | wc -l` -lt 1 ];then
        echo "" >> /etc/bacularis/Web/users.conf
        echo -e "[${WEB_User}]\nlong_name = \"\"\ndescription = \"\"\nemail = \"\"\nroles = \"admin\"\nenabled = \"1\"\nips = \"\"\nusername = \"${WEB_User}\"" >> /etc/bacularis/Web/users.conf
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
