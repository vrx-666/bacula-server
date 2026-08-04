#!/bin/bash
# Values substituted into the config can come from the operator (database
# password, notification recipient), not only from the password generator with
# its fixed character set. So we escape whatever is special in sed's
# replacement part when "," is the separator: comma, ampersand and backslash.
esc() {
	# Returns the value ready for sed's replacement part, or 1 when the
	# substitution would not be safe. The caller MUST check the status.
	# A CR comes from .env files written on Windows and would land in the
	# config verbatim -- drop it silently, it is an artefact of the encoding.
	# Done with parameter expansion rather than $(... | tr -d): a command
	# substitution strips trailing newlines, so a value ending in one -- or
	# consisting of nothing else -- reached the check below already trimmed and
	# passed it. A lone newline then became an empty string and was written to
	# the config as a blank value, which is exactly what this guard prevents.
	local value=${1//$'\r'/}
	# A newline breaks the sed expression ("unterminated `s' command"), and a
	# multi-line value makes no sense in these files anyway.
	case "$value" in
		*$'\n'*) return 1 ;;
	esac
	# Escape what is special in sed's replacement part with "," as the
	# separator: comma, ampersand (the whole match) and backslash.
	printf '%s' "$value" | sed -e 's/[&,\\]/\\&/g'
}

# Substitutes @NAME@ in the given files with the value of the variable of that
# name.
#
# The esc status has to be checked here, not inside esc itself: esc is called in
# a command substitution, and exiting a subshell only ends the subshell. Without
# this check sed was handed an empty string, reported success and wrote an empty
# value into the config while the entrypoint carried on.
substitute() {
	local name=$1; shift
	local value file
	if ! value=$(esc "${!name}"); then
		echo "==> Value of ${name} contains a newline and cannot be substituted. Check your environment variables." >&2
		exit 1
	fi
	for file in "$@"; do
		sed -i "s,@${name}@,${value}," "$file"
	done
}

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
chown -R bacula:tape /opt/bacula/scripts
chmod -R +rx /opt/bacula/scripts/*
chown -R bacula:bacula /opt/bacula/working
chmod -R g+w /opt/bacula/working
chown -R bacula:tape /mnt/bacula
chown bacula:tape /opt/bacula/log

for c in "${CONFIG_VARS[@]}"; do
  substitute "$c" /opt/bacula/etc/bacula-fd.conf /opt/bacula/etc/bacula-sd.conf \
    /opt/bacula/etc/bacula-dir.conf /opt/bacula/etc/bconsole.conf
done

substitute SMTP_User /opt/bacula/etc/bacula-dir.conf
substitute EMAIL_Recipient /opt/bacula/etc/bacula-dir.conf

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
chmod +w /opt/bacula/working

htpasswd -cbm /etc/bacularis/API/bacularis.users ${WEB_User} ${WEB_Password}
echo -e "[${WEB_User}]\nbconsole_cfg_path = \"\"\n" > /etc/bacularis/API/basic.conf
htpasswd -cbm /etc/bacularis/Web/bacularis.users ${WEB_User} ${WEB_Password}
sed -i "s/^login =.*$/login = \"$WEB_User\"/g" /etc/bacularis/Web/hosts.conf
sed -i "s/^password =.*$/password = \"$WEB_Password\"/g" /etc/bacularis/Web/hosts.conf
echo -e "[${WEB_User}]\nlong_name = \"\"\ndescription = \"\"\nemail = \"\"\nroles = \"admin\"\nenabled = \"1\"\nips = \"\"\nusername = \"${WEB_User}\"" > /etc/bacularis/Web/users.conf

cp /opt/exim-default-conf/update-exim4.conf.conf /etc/exim4/
chown root:root /etc/exim4/update-exim4.conf.conf
chmod 644 /etc/exim4/update-exim4.conf.conf
cp /opt/exim-default-conf/passwd.client /etc/exim4/
chown root:Debian-exim /etc/exim4/passwd.client
chmod 640 /etc/exim4/passwd.client
cp /opt/exim-default-conf/exim4.conf.template /etc/exim4/exim4.conf.template
chown -R Debian-exim:Debian-exim /var/log/exim4

for c in "${SMTP_VARS[@]}"; do
  substitute "$c" /etc/exim4/update-exim4.conf.conf
done

for a in "${AUTH_VARS[@]}"; do
  substitute "$a" /etc/exim4/passwd.client /etc/exim4/exim4.conf.template
done

domain=$(echo "${SMTP_User}" | sed -e 's/.*@//g')
substitute domain /etc/exim4/update-exim4.conf.conf
substitute SMTP_User /opt/bacula/etc/bacula-dir.conf
substitute EMAIL_Recipient /opt/bacula/etc/bacula-dir.conf
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
