# LaraScale package for Ubuntu 14.04
Simple & high-performance Laravel 5.2 install package (shell script) for Ubuntu 14.04

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

## Install without any DB server by root user:

```
apt-get update -y && apt-get upgrade -y
curl -O https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/install.sh
chmod +x install.sh && bash install.sh

```

After installation you can login to ssh/sftp via user - **larascale**.

Your site placed in **/var/www/larascale/sites**.

More docs coming soon...
