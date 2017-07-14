# LaraScale package for Ubuntu 16.04 (14.04)
Simple & high-performance Laravel 5.4 install package (shell script) for Ubuntu 16.04 (14.04)

## Packages

* PHP7 + MySQL 5.5 (Percona XtraDB Server) + Memcached => **install.sh**
* PHP7 + PostgreSQL 9.6 + Memcached => **install-postgresql.sh**
* PHP7 + Memcached => **install-without-db.sh**
* PHP7.1 + Memcached + PostgreSQL 9.6 => **install-php7_1-postgresql.sh**

## Include:

*   Nginx
*   PHP 7 (PHP-FPM) OR PHP 7.1
*   Memcached Server
*   Percona XtraDB Server 5.5 or PostgreSQL 9.6
*   Composer
*   Laravel 5.2 or Laravel 5.4

## Install:

Recomend to install on clean machine!

This package test on DigitalOcean.com, Vscale.io & others VPS.

## Install with MySQL by root user:

```
apt-get update -y && apt-get upgrade -y && apt-get install curl -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install.sh
chmod +x install.sh && bash install.sh

```
## Install with PostgreSQL server by root user:

```
apt-get update -y && apt-get upgrade -y && apt-get install curl -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install-postgresql.sh
chmod +x install-postgresql.sh && bash install-postgresql.sh

```

## Install without any DB server by root user:

```
apt-get update -y && apt-get upgrade -y && apt-get install curl -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install-without-db.sh
chmod +x install-without-db.sh && bash install-without-db.sh

```

## Install PHP7.1 with PostgreSQL server by root user:

```
apt-get update -y && apt-get upgrade -y && apt-get install curl -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install-php7_1-postgresql.sh
chmod +x install-php7_1-postgresql.sh && bash install-php7_1-postgresql.sh

```

After installation you can login to ssh/sftp via user - **larascale**.

Your site placed in **/var/www/larascale/sites**.

More docs coming soon...


## (DEV) Install PHP7.1 + PostgreSQL server + NodeJS + Python Supervisor + Beanstalkd Queques Server by root user:

```
apt-get update -y && apt-get upgrade -y && apt-get install curl -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/new_install.sh
chmod +x new_install.sh && bash new_install.sh

```
