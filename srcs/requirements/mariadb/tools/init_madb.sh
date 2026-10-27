#!/bin/bash

set -e

echo "starting MaraiDB initialization..."
# ensure the directory exist and correct permissions,even changes
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chmod 755 /var/run/mysqld

chown -R mysql:mysql /var/lib/mysql
#check for required environment variables
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ]; then
    echo "Error: mysql_database or mysql_user are missing."
    exit 1
fi

# check for docker secrets
if [ ! -f "/run/secrets/db_root_password" ] || [ ! -f "/run/secrets/db_password" ]; then
    echo "Error: secret files not found"
    exit 1
fi

ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

#setup logic
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First run detected initializing  data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "starting temporary mariaDB for setup... "
    mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock --user=mysql &
    pid="$!"

    echo "Temporary mariaDB is ready"

    echo "Running setup SQL"
    mysql --socket=/var/run/mysqld/mysqld.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    echo "shutting down mariadb"
    mysqladmin \
        --socket=/var/run/mysqld/mysqld.sock \
        -u root \
        -p"${ROOT_PASSWORD}" \
        shutdown
    wait "$pid" || true
else
    echo "database directory already exists"
fi

echo "starting mariaDB in the foreground..."
#remove old socket file
rm -f /var/run/mysqld/mysqld.sock
rm -f /var/run/mysqld/mysqld.pid


#check data directory exit after finish initializing
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Error:mysql data directory not initialized"
    exit 1
fi

echo "mariaDB ready to start..."

exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock --bind-address=0.0.0.0
