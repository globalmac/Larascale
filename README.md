# LaraScale package for Ubuntu 14.04
Simple & high-performance Laravel 5.2 install package (shell script) for Ubuntu 14.04

## Packages

* PHP7 + MySQL 5.5 (Percona XtraDB Server) + Memcached => **install.sh**
* PHP7 + PostgreSQL 9.6 + Memcached => **install-postgresql.sh**
* PHP7 + Memcached => **install-without-db.sh**

## Include:

*   Nginx
*   PHP 7 (PHP-FPM)
*   Memcached Server
*   Percona XtraDB Server
*   Composer
*   Laravel 5.2

## Install with MySQL by root user:

```
apt-get update -y && apt-get upgrade -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install.sh
chmod +x install.sh && bash install.sh

```
## Install with PostgreSQL server by root user:

```
apt-get update -y && apt-get upgrade -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install-postgresql.sh
chmod +x install-postgresql.sh && bash install-postgresql.sh

```

## Install without any DB server by root user:

```
apt-get update -y && apt-get upgrade -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install-without-db.sh
chmod +x install-without-db.sh && bash install-without-db.sh

```

After installation you can login to ssh/sftp via user - **larascale**.

Your site placed in **/var/www/larascale/sites**.

More docs coming soon...
