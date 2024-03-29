# Bacula Server with Baculum App (web Interface)
Bacula Client configured to backup database by default. Could be reconfigured to backup config files.<br>
Bacula 11 version.<br>
Allows to use the postgresql or sqlite3 database.<br>
Sqlite3 version creates db locally, for mysql or postgresql need to have separate db server working.<br>
For postgresql create db named "bacula" with coresponding user, use SQL_ASCII encoding and postgres<=14 to avoid application warnings.<br>
Added vchanger tool: https://www.bacula.org/vchanger-release-1-0-0-is-out/<br>

# How to build
Pull this repository and run "build.sh"
```
./build.sh
```

# ENV
postgreSQL & mySQL versions:
```
DB_Host - database ip
DB_Port - database port (could be omitted if default)
DB_User - database user
DB_Password - database user password
```

common:
```
TZ - timezone
SD_Host - most cases host IP Address should be set
        (the IP address where the bacula will be reachable by clients/computers)
WEB_User - bacula app username (default: admin)
WEB_Password - bacula app password (default: difficult)
EMAIL_Recipient - email address where You want bacula send notifications
SMTP_Host - address of Your email provider's smtp server
SMTP_User - Email sender login (could be: user@domain or user, check Your email provider documentation)
SMTP_Password - Password for email sender account
SMTP_Port - smtp port for Your email provider smtp server (check provider documentation) - Yes this is ENV Variable not Docker Port
```
If You want to send email notification, You should set container hostname as Your Reverse DNS (Public). Some email providers could Reject email without propper hostname

# Ports
```
9095 - Bacula Web
9103 - Bacula Storage
9096 - Bacula API (could be omitted, local Web App use localhost)
9101 - Bacula Director (could be omitted if no remote management is needed)
```
# Mounts
version 11:
```
/opt/bacula/etc - bacula configuration files
/etc/baculum - baculum app configuration
/mnt/bacula - storage for backups
/opt/bacula/working - bacula working directory (sqlite db, bacula db dump for backups)
/opt/bacula/log - bacula logs
/var/log/apache2 - baculum logs
```

version 9.6:
```
/etc/bacula - bacula configuration
/etc/baculum - baculum app configuration
/var/lib/bacula - bacula working directory
/var/log/bacula - bacula logs
/var/log/apache2 - baculum app logs
```

# Exaple run command
```
docker run -d --name='Bacula Server' \
-e TZ="America/Los_Angeles" \
-e 'SD_Host'='192.168.1.101' \
-e 'DB_Host'='192.168.1.100' -e 'DB_User'='username' -e 'DB_Password'='password' \
-e 'WEB_User'='admin' -e 'WEB_Password'='difficult' \
-p '9103:9103' -p '9095:9095' \
-v '/mnt/docker/bacula-server/working':'/var/lib/bacula' \
-v '/mnt/docker/bacula-server/etc':'/etc/bacula' \
-v '/mnt/docker/bacula-server/storage':'/mnt/bacula' \
-v '/mnt/docker/bacula-server/log/bacula':'/var/log/bacula' \
-v '/mnt/docker/bacula-server/log/apache2':'/var/log/apache2' \
-v '/mnt/docker/bacula-server/baculum':'/etc/baculum' \
pwa666/bacula-server:11-postgresql-latest
```

# End of development for Bacula9.6
