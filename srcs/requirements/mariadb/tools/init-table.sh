#!/bin/bash

service mariadb start

echo "Waiting for MariaDB to start..."
while ! mysqladmin ping --silent; do
    sleep 1
done
echo "MariaDB is up and running."

mysql -e "CREATE DATABASE IF NOT EXISTS $SQL_DATABASE;"
mysql -e "CREATE USER IF NOT EXISTS '$SQL_USER'@'%' IDENTIFIED BY '$SQL_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $SQL_DATABASE.* TO '$SQL_USER'@'%' IDENTIFIED BY '$SQL_PASSWORD';"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin shutdown

exec mariadbd-safe --port=3306 --bind-address=0.0.0.0 --datadir=/var/lib/mysql
