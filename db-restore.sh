#!/bin/sh
su - postgres -c 'psql -c "drop database davical;"'
su - postgres -c 'createdb --owner davical_dba --encoding UTF8 --template template0 davical'
su postgres -c 'gunzip -c  /var/lib/postgresql/restore/db.sql.gz | psql davical'
mv /var/lib/postgresql/restore/db.sql.gz /var/lib/postgresql/restore/db-restored.sql.gz
