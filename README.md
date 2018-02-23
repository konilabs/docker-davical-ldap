# docker-davical-ldap
Davical + Apache + Postgresql with LDAP auth support based on Debian Stretch

## Features
This Docker container is based on Debian Stretch.
- **Apache 2** is used as webserver
- **Postgresql** stores the Davical database
- **Php7** is installed with LDAP auth support
- **Davical** packages comes from backport because version available in stable repository has an LDAP auth bug
- **Supervisord** manages services and ensure that everything starts and runs fine.

### Startup
During container startup, `docker-entrypoint.sh` script check if davical database already exists.
If it exists, it runs davical database script, otherwise it runs davical init script.

### Database backup
A cron script creates a backup of the davical database everyday at 3am.
It rotates backup to keep 7 daily, 5 weekly and 12 monthly backups.
Backups are stored in `/var/lib/postgresql/backups`

### Database restore
Container contains a database restore script.
To restore a copy of the database, put the backup file in `/var/lib/postgresql/restore/` and name it `db.sql.gz`

At next startup, current davical database will be replaced by provided database dump.
When data has been restored, `db.sql.gz` is renamed `db-restored.sql.gz`

## Installation
This container requires two docker volumes :
- `/config/` contains configuration files
- `/var/lib/postgresql/` contains Postgresql data files, backups, and restore

Port `80` is exposed

By default davical administrator credentials are the following :
- user : `admin`
- password : `12345`

**This MUST be changed using Web interface !**

## Feedback
This is my first attempt to create a Docker container. Please provide your feedback if there is something wrong or good.
