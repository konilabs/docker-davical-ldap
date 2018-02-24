#!/bin/bash

# Initialize volumes
mv -n /default/config/* /config
mv -n /default/data/* /var/lib/postgresql

# Configure Apache
ln -s /config/davical-apache.conf /etc/apache2/sites-available/davical-apache.conf
a2dissite 000-default
a2ensite davical-apache

# Create symbolid for davical.php configuration file
ln -s /config/davical-config.php /etc/davical/config.php

# Configure Postgresql Database

#Using sed because text has to be insterted at beginning of file
sed -i '1ilocal   davical    davical_app   trust' /etc/postgresql/$PG_VERSION/main/pg_hba.conf
sed -i '1ilocal   davical    davical_dba   trust' /etc/postgresql/$PG_VERSION/main/pg_hba.conf

service postgresql start

#Check if there is a database file to restore
if [ -f /var/lib/postgresql/restore/db.sql.gz ]; then
    echo "Davical database backup file found, restoring it"
    /sbin/db-restore.sh
fi 

if su - postgres -c "psql -lqt | cut -d \| -f 1 | grep -qw davical"; then
    echo "Davical database exists, update it"
    su postgres -c /usr/share/davical/dba/update-davical-database
else
    echo "Davical database does not exist, initialize it"
    service postgresql reload
    su postgres -c "/usr/share/davical/dba/create-database.sh davical 12345"
fi

service postgresql stop

#LAUNCH THE INIT PROCESS
exec /bin/bash
#exec /usr/bin/supervisord -c /config/supervisord.conf

