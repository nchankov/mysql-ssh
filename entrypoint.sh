#!/bin/bash

set -e

# Trap termination signals to cleanly stop services
trap 'echo "Stopping MySQL and SSH..."; service mysql stop; service ssh stop; exit 0' SIGTERM SIGINT

init="0"

# Ensure MySQL directory permissions (only if needed)
#if [ ! -d /var/lib/mysql/mysql ]; then
    chown mysql:mysql /var/lib/mysql -Rf
    chmod 700 /var/lib/mysql -Rf
#fi

# Add the server id into the mysql cnf file if it's not already there
if ! grep -q "^\s*server_id\s*=" /etc/mysql/my.cnf; then
    awk -v server_id="$MYSQL_SERVER_ID" '/\[mysqld\]/{print; print "server_id = " server_id; next}1' /etc/mysql/my.cnf > /tmp/my.cnf && mv /tmp/my.cnf /etc/mysql/my.cnf
    init="1"
fi

# Start SSH and MySQL services
service ssh start
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

# Keep container running, forwarding signals
echo "Services started. Container running."

# Wait forever but let trap handle SIGTERM
tail -f /dev/null &
wait $!