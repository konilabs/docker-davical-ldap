#Use Debian Stretch (stable) as base Image
FROM debian:stretch

ENV PG_VERSION 9.6

#Add Backports
RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

# Install Davical from backports to avoid LDAP auth bug
# Install ldap support
RUN apt-get update && apt-get install -y postgresql-"$PG_VERSION" supervisor \ 
	&& apt-get install -t stretch-backports -y davical \
	&& apt-get install -y php-ldap \
	&& rm -rf /var/lib/apt/lists/*

COPY ./db-backup.sh /sbin/db-backup.sh
COPY ./docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY ./supervisord.conf /default/config/supervisord.conf
COPY ./davical-apache.conf /default/config/davical-apache.conf
COPY ./db-backup-cron /etc/cron.d/db-backup-cron
COPY ./db-restore.sh /sbin/db-restore.sh

RUN crontab /etc/cron.d/db-backup-cron \
	&& chmod 0755 /sbin/docker-entrypoint.sh \
	&& chmod 0755 /sbin/db-backup.sh \
	&& chmod 0755 /sbin/db-restore.sh \
	&& mkdir /var/lib/postgresql/backups \
	&& mkdir /var/lib/postgresql/restore
RUN chown postgres:postgres /var/lib/postgresql/backups
RUN chown postgres:postgres /var/lib/postgresql/restore
RUN mv /etc/davical/config.php /default/config/davical-config.php 
RUN mv /var/lib/postgresql /default/data/

EXPOSE 80

VOLUME ["/var/lib/postgresql/","/config"]
ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
