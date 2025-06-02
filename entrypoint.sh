#!/bin/bash

chown mysql:mysql /var/lib/mysql -Rf
chmod 700 /var/lib/mysql -Rf

# Start MySQL server
service mysql start

# Create root user to access the database from any host
mysql -u root -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root -e "ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'";
mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root -e "SET GLOBAL server_id = $MYSQL_SERVER_ID;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"

# Start SSH server
/usr/sbin/sshd -D