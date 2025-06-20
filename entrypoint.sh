#!/bin/bash

chown mysql:mysql /var/lib/mysql -Rf
chmod 700 /var/lib/mysql -Rf

# Add the server id into the mysql cnf file by awk
awk -v server_id="$MYSQL_SERVER_ID" '/\[mysqld\]/{print; print "server_id = " server_id; next}1' /etc/mysql/my.cnf > /tmp/my.cnf && mv /tmp/my.cnf /etc/mysql/my.cnf

# Start MySQL server
service mysql start

# Create root user to access the database from any host
mysql -u root -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -e "FLUSH PRIVILEGES;"
#mysql -u root -e "SET GLOBAL server_id = $MYSQL_SERVER_ID;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"

# Add also replica_user
mysql -u root -e "CREATE USER IF NOT EXISTS 'replica_user'@'%' IDENTIFIED WITH mysql_native_password  BY 'replica_pass';"
mysql -u root -e "FLUSH PRIVILEGES;"
#mysql -u root -e "SET GLOBAL server_id = $MYSQL_SERVER_ID;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'replica_user'@'%' WITH GRANT OPTION;"

# Start SSH server
/usr/sbin/sshd -D