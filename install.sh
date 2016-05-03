#!/bin/sh

echo
echo "LaraScale package for Ubuntu 14.04"
echo

if [ "x$(id -u)" != 'x0' ]; then
    echo "Error! You need a root privilegies for run this script. Try to use: sudo -i"
    exit 1
fi

echo
echo "=========== Install overview ==========="
echo '- Nginx (stable >= 1.8)'
echo '- PHP 7 with PHP7-FPM'
echo '- Percona XtraDB Server (MySQL fork 5.5)'


read -p 'Ready to go? [y/n]): ' answer
if [ "$answer" != 'y' ] && [ "$answer" != 'Y'  ]; then
    echo 'Goodbye my friend!'
    exit 1
fi


echo
echo "=========== LaraScale prebuild ==========="
echo

echo "- Check system updates"
apt-get update -y --force-yes -qq > /dev/null 2>&1

echo "- System updating, plese wait..."
apt-get upgrade -y --force-yes -qq > /dev/null 2>&1

echo "- System utils installing..."
apt-get install mc zip curl unzip htop python-software-properties software-properties-common build-essential -y > /dev/null 2>&1

echo
echo "=========== Setting up PHP7 ==========="
echo

add-apt-repository ppa:ondrej/php -y --force-yes -qq > /dev/null 2>&1
apt-get update -y --force-yes -qq > /dev/null 2>&1

echo
echo "=========== Install PHP7 with modules: ==========="
echo

echo "1) php7.0-fpm"
echo "2) php7.0-common"
echo "3) php7.0-gd"
echo "4) php7.0-mysql"
echo "5) php7.0-curl"
echo "6) php7.0-cli"
echo "7) php-pear"
echo "8) php7.0-dev"
echo "9) php7.0-imap"
echo "10) php7.0-mcryp"
echo "11) php7.0-readline"
echo "12) php7.0-mbstring"
echo "13) php7.0-json"
echo "14) php7.0-zip"

apt-get install php7.0-fpm php7.0-common php7.0-gd php7.0-mysql php7.0-curl php7.0-cli php-pear php7.0-dev php7.0-imap php7.0-mcrypt php7.0-readline php7.0-mbstring php7.0-json php7.0-zip -y --force-yes -qq > /dev/null 2>&1

echo
echo "=========== Install Nginx ==========="
echo

add-apt-repository ppa:nginx/stable -y --force-yes -qq > /dev/null 2>&1
apt-get update -y --force-yes -qq > /dev/null 2>&1
apt-get install nginx -y --force-yes -qq > /dev/null 2>&1

rm /etc/nginx/sites-available/default
wget https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/nginx/default -O /etc/nginx/sites-available/default


echo
echo "=========== Install Percona XtraDB Server ==========="
echo

apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
echo "deb http://repo.percona.com/apt `lsb_release -cs` main" >> /etc/apt/sources.list.d/percona.list
echo "deb-src http://repo.percona.com/apt `lsb_release -cs` main" >> /etc/apt/sources.list.d/percona.list

apt-get update -y --force-yes -qq > /dev/null 2>&1
apt-get install percona-server-server-5.5 percona-server-client-5.5 -y

mysql -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'" -u root -p123
mysql -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'" -u root -p123
mysql -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'" -u root -p123

echo
echo "=========== Please setting up MySQL installation... ==========="
echo

mysql_secure_installation

echo
echo "=========== Please setting up MySQL installation... ==========="
echo

sudo useradd -g sudo -d /var/www/larascale -m -s /bin/bash larascale
passwd larascale

mkdir -p /var/www/larascale
echo "<?php phpinfo(); ?>" >> /var/www/larascale/index.php
chown -R larascale:www-data /var/www/larascale

service php7.0-fpm restart > /dev/null 2>&1
service nginx restart > /dev/null 2>&1
service mysql restart > /dev/null 2>&1

echo
echo "=========== Install complete success! ==========="
echo
echo
echo "=========== Please login via user larascale and install Composer ==========="
echo

exit
