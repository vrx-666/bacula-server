FROM debian:bullseye

ARG BACULAV

LABEL maintainer="developer@s.vrx.pl"
LABEL version="2.2"
LABEL description="Bacula Server ${BACULAV}"

ARG DEBIAN_FRONTEND=noninteractive
ARG DB

RUN echo "path-exclude /usr/share/doc/*" > /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-include /usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/groff/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/info/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/lintian/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/linda/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc&& \
    apt update && apt install -y gnupg2 gpg curl sudo && \
    echo "deb [signed-by=/usr/share/keyrings/bacularis-archive-keyring.gpg] https://pkgs.bacularis.app/stable/debian bullseye main" > /etc/apt/sources.list.d/bacularis.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/bacularis-archive-keyring.gpg] https://pkgs.bacularis.app/stable/debian bullseye main" >> /etc/apt/sources.list.d/bacularis.list && \
    curl -s https://pkgs.bacularis.app/bacularis.pub | gpg --dearmor > /usr/share/keyrings/bacularis-archive-keyring.gpg && \
    if [ "$DB" = "postgresql" ] ; then sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt update && apt -y upgrade && apt install -y --no-install-recommends postgresql-client-16 lsscsi fuse procinfo pv mbuffer supervisor apache2 bacularis bacularis-apache2 php7.4-pgsql libncurses-dev libpq-dev g++ make exim4-base exim4-config exim4-daemon-light ; fi && \
    if [ "$DB" = "sqlite3" ] ; then apt update && apt -y upgrade && apt install -y --no-install-recommends lsscsi fuse procinfo pv mbuffer supervisor apache2 bacularis bacularis-apache2 libncurses-dev  libsqlite3-dev sqlite3 php7.4-sqlite3 g++ make exim4-base exim4-config exim4-daemon-light ; fi && \
    mkdir -p /var/www/bacula && \
    chown www-data:www-data /var/www/bacula && \
    mv /etc/bacularis /home/ && \
    mkdir -p /opt/bacula && \
    a2enmod proxy_fcgi && \
    a2enmod rewrite && \
    a2enconf php7.4-fpm && \
    a2ensite bacularis && \
    sed -i '/ServerName localhost/a ErrorLog \/dev/\stdout' /etc/apache2/sites-available/bacularis.conf && \
    sed -i '/ServerName localhost/a CustomLog \/dev\/stdout combined env=!dontlog' /etc/apache2/sites-available/bacularis.conf && \
    rm -f /etc/apache2/sites-enabled/000-default.conf && \
    useradd -M -d /opt/bacula -s /bin/bash bacula && \
    usermod -aG tape www-data && \
    usermod -aG bacula www-data && \ 
    mkdir /opt/bacula_src && \
    curl -s $(curl -s https://www.bacula.org/source-download-center/ | grep -B1 -i -E "Bacula ${BACULAV}[0-9\.]* Source Files.* downloads" | grep href | sed -e 's/^.*href="//' -e 's/" rel.*$//') -o /opt/bacula_src/bacula_src.tgz && \
    cd /opt/bacula_src && tar -zxvf bacula_src.tgz && \
    mv $(find -maxdepth 1 -type d -name "bacula*") bacula_src && \
    cd /opt/bacula_src/bacula_src && CFLAGS="-g -O2"    ./configure --sbindir=/opt/bacula/bin --sysconfdir=/opt/bacula/etc --with-scriptdir=/opt/bacula/scripts --with-pid-dir=/opt/bacula/working --with-subsys-dir=/opt/bacula/working --enable-smartalloc --with-${DB} --with-working-dir=/opt/bacula/working --with-dump-email=root --with-job-email=root --with-smtp-host=localhost --disable-ipv6 --enable-conio --with-aws && \
    make && \
    make install && \
    rm -rf /opt/bacula_src && \
    mkdir -p /opt/vchanger_src  && \
    curl -s -L $(curl -s https://sourceforge.net/projects/vchanger/files/vchanger/$(curl -s https://sourceforge.net/projects/vchanger/files/vchanger/ | grep folder | grep href | grep files_name_h | head -1 | sed -e 's/.*a href="\/projects\/vchanger\/files\/vchanger\///g' -e 's/" title.*//g') |  grep href | grep tar.gz | grep files_name_h | sed -e 's/.*a href="//g' -e 's/\/download" title.*//g') > /opt/vchanger_src/vchanger.tgz && \
    cd /opt/vchanger_src && tar -zxf vchanger.tgz && \
    cd /opt/vchanger_src/vchanger && ./configure && make && make install-strip && \
    rm -rf /opt/vchanger_src && \
    mkdir /home/bacula && \
    mv /opt/bacula/etc /home/bacula/ && \
    mkdir /mnt/bacula && \
    chown bacula:tape /mnt/bacula && \
    ln -s /opt/bacula/bin/bconsole /usr/bin/bconsole && \
    ln -s /usr/lib /opt/bacula/plugins && \
    echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf && \
    echo 'SetEnvIf Remote_Addr "127\.0\.0\.1" dontlog' >> /etc/apache2/apache2.conf && \
    sed -i 's/^DIR_USER=/DIR_USER="bacula"/' /opt/bacula/scripts/bacula-ctl-dir && \
    sed -i 's/^DIR_GROUP=/DIR_GROUP="bacula"/' /opt/bacula/scripts/bacula-ctl-dir && \
    sed -i 's/^SD_USER=/SD_USER="bacula"/' /opt/bacula/scripts/bacula-ctl-sd && \
    sed -i 's/^SD_GROUP=/SD_GROUP="tape"/' /opt/bacula/scripts/bacula-ctl-sd && \
    ln -s /opt/bacula/scripts/bacula-ctl-dir /etc/init.d/bacula-dir && \
    ln -s /opt/bacula/scripts/bacula-ctl-sd /etc/init.d/bacula-sd && \
    ln -s /opt/bacula/scripts/bacula-ctl-fd /etc/init.d/bacula-fd && \
    apt --purge remove -y gnupg2 gpg make g++ && \
    apt -y autoremove && apt clean all && \
    rm -rf /var/cache/apt/* && \
    mkdir /opt/exim-default-conf

COPY conf/${BACULAV}/bacula-sd.conf /home/bacula/etc/bacula-sd.conf
COPY conf/${BACULAV}/bacula-fd.conf /home/bacula/etc/bacula-fd.conf
COPY conf/${BACULAV}/${DB}/bacula-dir.conf /home/bacula/etc/bacula-dir.conf
COPY conf/bconsole.conf /home/bacula/etc/bconsole.conf
COPY conf/${BACULAV}/sudoers /etc/sudoers
COPY conf/${BACULAV}/${DB}/bacularis /home/bacularis
COPY conf/supervisord.conf /etc/supervisord.conf
COPY scripts/${BACULAV}/${DB}/entrypoint.sh /usr/sbin/entrypoint.sh
COPY scripts/${BACULAV}/healthcheck /usr/bin/healthcheck
COPY conf/update-exim4.conf.conf /opt/exim-default-conf/update-exim4.conf.conf
COPY conf/exim4.conf.template /opt/exim-default-conf/exim4.conf.template
COPY conf/passwd.client /opt/exim-default-conf/passwd.client

RUN mkdir /run/php && \
    chgrp bacula /home/bacula/etc/bacula-fd.conf && \
    chgrp bacula /home/bacula/etc/bacula-sd.conf && \
    chgrp bacula /home/bacula/etc/bacula-dir.conf 
    
VOLUME ["/opt/bacula/etc", "/opt/bacula/working", "/opt/bacula/log", "/etc/bacularis", "/var/log/apache2", "/var/log/exim4"]

EXPOSE 9101/tcp 9103/tcp 9097/tcp

HEALTHCHECK --interval=120s --timeout=10s --start-period=60s \  
    CMD bash healthcheck

ENTRYPOINT ["entrypoint.sh"]
CMD ["supervisord","-n","-c","/etc/supervisord.conf"]