FROM debian:13

ARG BACULAV
ARG BACULARISVER=6.3.0

LABEL maintainer="developer@s.vrx.pl"
LABEL version="3.0"
LABEL description="Bacula Server ${BACULAV} with Bacularis ${BACULARISVER}"
LABEL org.opencontainers.image.source="https://github.com/vrx-666/bacula-server"

ARG DEBIAN_FRONTEND=noninteractive
ARG DB

RUN echo "path-exclude /usr/share/doc/*" > /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-include /usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/groff/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/info/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/lintian/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo "path-exclude /usr/share/linda/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    apt update && apt install -y --no-install-recommends \
        less groff unzip gnupg2 gpg curl wget ca-certificates file sudo mtx mt-st expect \
        lsscsi fuse procinfo pv mbuffer supervisor apache2 apache2-utils \
        exim4-base exim4-config exim4-daemon-light \
        libncurses-dev g++ make \
        php8.4-fpm php8.4-cli php8.4-bcmath php8.4-curl php8.4-xml php8.4-ldap php8.4-intl php8.4-mbstring && \
    if [ "$DB" = "postgresql" ] ; then \
        curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg && \
        echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
        apt update && apt install -y --no-install-recommends postgresql-client-16 libpq-dev php8.4-pgsql ; \
    fi && \
    if [ "$DB" = "sqlite3" ] ; then \
        apt install -y --no-install-recommends sqlite3 libsqlite3-dev php8.4-sqlite3 ; \
    fi && \
    apt -y upgrade && \
    mkdir -p /opt/bacula && \
    useradd -M -d /opt/bacula -s /bin/bash bacula && \
    usermod -aG tape www-data && \
    usermod -aG bacula www-data && \
    usermod -aG tape bacula && \
    mkdir /opt/aws_cli_src && \
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/opt/aws_cli_src/awscliv2.zip" && \
    cd /opt/aws_cli_src && unzip awscliv2.zip && \
    /opt/aws_cli_src/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update && \
    rm -rf /opt/aws_cli_src && \
    mkdir /opt/bacula_src && \
    curl -s $(curl -s https://www.bacula.org/source-download-center/ | grep -B1 -i -E "Bacula ${BACULAV}[0-9\.]* Source Files.* downloads" | grep href | sed -e 's/^.*href="//' -e 's/" rel.*$//') -o /opt/bacula_src/bacula_src.tgz && \
    cd /opt/bacula_src && tar -zxvf bacula_src.tgz && \
    mv $(find -maxdepth 1 -type d -name "bacula*") bacula_src && \
    cd /opt/bacula_src/bacula_src && CFLAGS="-g -O2"    ./configure --sbindir=/opt/bacula/bin --sysconfdir=/opt/bacula/etc --with-scriptdir=/opt/bacula/scripts --with-plugindir=/opt/bacula/plugins --with-pid-dir=/opt/bacula/working --with-subsys-dir=/opt/bacula/working --enable-smartalloc --with-${DB} --with-working-dir=/opt/bacula/working --with-dump-email=root --with-job-email=root --with-smtp-host=localhost --disable-ipv6 --enable-conio --with-aws && \
    make && \
    make install && \
    ./libtool --finish /usr/lib && \
    cp scripts/aws_cloud_driver /opt/bacula/plugins/ && \
    chmod +x /opt/bacula/plugins/aws_cloud_driver && \
    chmod o+rx /opt/bacula/plugins/* && \
    rm -rf /opt/bacula_src && \
    mkdir -p /opt/vchanger_src  && \
    curl -s -L $(curl -s https://sourceforge.net/projects/vchanger/files/vchanger/$(curl -s https://sourceforge.net/projects/vchanger/files/vchanger/ | grep href | grep files_name_h | head -1 | sed -e 's/.*a href="\/projects\/vchanger\/files\/vchanger\///g' -e 's/"//g') |  grep href | grep tar.gz | grep files_name_h | sed -e 's/.*a href="//g' -e 's/\/download"//g') > /opt/vchanger_src/vchanger.tgz && \
    cd /opt/vchanger_src && tar -zxf vchanger.tgz && \
    cd /opt/vchanger_src/vchanger && ./configure && make && make install-strip && \
    rm -rf /opt/vchanger_src && \
    # ---------- Bacularis (manual install from public sources) ----------
    mkdir -p /var/www/bacularis && \
    cd /var/www/bacularis && \
    wget -q -O bacularis-api.tar.gz https://github.com/bacularis/bacularis-api/archive/refs/tags/${BACULARISVER}.tar.gz && \
    wget -q -O bacularis-common.tar.gz https://github.com/bacularis/bacularis-common/archive/refs/tags/${BACULARISVER}.tar.gz && \
    wget -q -O bacularis-web.tar.gz https://github.com/bacularis/bacularis-web/archive/refs/tags/${BACULARISVER}.tar.gz && \
    wget -q -O bacularis-app.tar.gz https://github.com/bacularis/bacularis-app/archive/refs/tags/${BACULARISVER}.tar.gz && \
    wget -q -O bacularis-external.tar.gz https://bacularis.app/downloads/bacularis-external-${BACULARISVER}.tar.gz && \
    tar --strip-components 1 -zxf bacularis-app.tar.gz && \
    tar --strip-components 1 -C protected -zxf bacularis-external.tar.gz && \
    mkdir -p protected/vendor/bacularis/bacularis-common protected/vendor/bacularis/bacularis-api protected/vendor/bacularis/bacularis-web && \
    tar --strip-components 1 -C protected/vendor/bacularis/bacularis-common -zxf bacularis-common.tar.gz && \
    tar --strip-components 1 -C protected/vendor/bacularis/bacularis-api -zxf bacularis-api.tar.gz && \
    tar --strip-components 1 -C protected/vendor/bacularis/bacularis-web -zxf bacularis-web.tar.gz && \
    cp -rf protected/vendor/bacularis/bacularis-common/project/* ./ && \
    ln -s vendor/bacularis/bacularis-common/Common protected/Common && \
    ln -s vendor/bacularis/bacularis-api/API protected/API && \
    ln -s vendor/bacularis/bacularis-web/Web protected/Web && \
    cp protected/vendor/npm-asset/fortawesome--fontawesome-free/css/all.min.css htdocs/themes/Baculum-v2/fonts/css/fontawesome-all.min.css && \
    cp -r protected/vendor/npm-asset/fortawesome--fontawesome-free/webfonts/* htdocs/themes/Baculum-v2/fonts/webfonts/ && \
    cp -r protected/vendor/npm-asset/fontsource--inter/files/* htdocs/themes/Baculum-v2/fonts/webfonts/ && \
    rm -f bacularis-api.tar.gz bacularis-common.tar.gz bacularis-web.tar.gz bacularis-app.tar.gz bacularis-external.tar.gz && \
    # Bacularis config lives in /etc/bacularis (the persistent volume); the app
    # reads it through symlinks, mirroring how the .deb package wired things up.
    mkdir -p /etc/bacularis/API /etc/bacularis/Web && \
    cp protected/vendor/bacularis/bacularis-common/project/protected/samples/webserver/bacularis.users.sample /etc/bacularis/API/bacularis.users && \
    cp protected/vendor/bacularis/bacularis-common/project/protected/samples/webserver/bacularis.users.sample /etc/bacularis/Web/bacularis.users && \
    rm -rf protected/API/Config protected/Web/Config && \
    ln -s /etc/bacularis/API protected/API/Config && \
    ln -s /etc/bacularis/Web protected/Web/Config && \
    chown -R www-data:www-data /var/www/bacularis && \
    # install.sh runs non-interactively: -s silent, -w apache, -u www-data.
    # It generates bacularis-apache.conf (already contains "Listen 0.0.0.0:9097").
    protected/tools/install.sh -s -w apache -u www-data -p /run/php/php8.4-fpm.sock && \
    mv /var/www/bacularis/bacularis-apache.conf /etc/apache2/sites-available/bacularis.conf && \
    # move the generated/sample config out of /etc so the entrypoint can seed it
    # from the project templates on first start (cp -rpn won't clobber otherwise)
    mv /etc/bacularis /home/bacularis && \
    # -------------------------------------------------------------------
    a2enmod proxy_fcgi && \
    a2enmod rewrite && \
    a2enconf php8.4-fpm && \
    a2ensite bacularis && \
    sed -i '/ServerName localhost/a ErrorLog \/dev/\stdout' /etc/apache2/sites-available/bacularis.conf && \
    sed -i '/ServerName localhost/a CustomLog \/dev\/stdout combined env=!dontlog' /etc/apache2/sites-available/bacularis.conf && \
    rm -f /etc/apache2/sites-enabled/000-default.conf && \
    mkdir /home/bacula && \
    mv /opt/bacula/etc /home/bacula/ && \
    mkdir /mnt/bacula /mnt/cloud && \
    chown bacula:tape /mnt/bacula /mnt/cloud && \
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
    rm -rf /etc/apt/sources.list.d/pgdg.list /var/cache/apt/* /var/lib/apt/lists/* && \
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

RUN mkdir -p /run/php && \
    chgrp bacula /home/bacula/etc/bacula-fd.conf && \
    chgrp bacula /home/bacula/etc/bacula-sd.conf && \
    chgrp bacula /home/bacula/etc/bacula-dir.conf

VOLUME ["/mnt/bacula","/mnt/cloud","/opt/bacula/etc", "/opt/bacula/working", "/opt/bacula/log", "/etc/bacularis", "/var/log/apache2", "/var/log/exim4"]

EXPOSE 9101/tcp 9103/tcp 9097/tcp

HEALTHCHECK --interval=120s --timeout=10s --start-period=60s \
    CMD bash healthcheck

ENTRYPOINT ["entrypoint.sh"]
CMD ["supervisord","-n","-c","/etc/supervisord.conf"]
