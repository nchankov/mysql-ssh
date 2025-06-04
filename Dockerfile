FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Update the system, install OpenSSH Server, and set up users
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y openssh-server mysql-server rsync

# Create user and set password for user and root user
RUN  echo 'ubuntu:secret' | chpasswd && \
    echo 'root:secret' | chpasswd

# Set up configuration for SSH
RUN mkdir /var/run/sshd && \
    echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

RUN usermod -d /var/lib/mysql/ mysql

COPY my.cnf /etc/mysql/my.cnf

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY id_rsa /root/.ssh/id_rsa
COPY authorized_keys /root/.ssh/authorized_keys
COPY id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/id_rsa.pub && \
    chown -R root:root /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

EXPOSE 3306 22

CMD ["/entrypoint.sh"]
