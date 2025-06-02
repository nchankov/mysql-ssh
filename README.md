# Docker Mysql + SSH server

The image is used to run a MySQL server with an SSH server for remote access. It is based on the official  Ubuntu image
and includes the MySQL server and OpenSSH server. The rationale for this is to provide simple way to test 
mysql-replica-creator script. Read the documentation in mysql-replica-creator how to use this image

To build the image run the following command in the root of the repository:

```bash
./build.sh
```
