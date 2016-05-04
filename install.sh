#!/bin/bash
# LaraScale package for Ubuntu 14.04

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
    echo
    echo "================ Error ================="
    echo 'This script can only be executed by root'
    echo "========================================"
    echo
    exit 1
fi

# Check OS
if [ "$(head -n1 /etc/issue | cut -f 1 -d ' ')" != 'Ubuntu' && "$(head -n1 /etc/issue | cut -f 2 -d ' ')" != '14.04.4']; then
    echo
    echo "================== Error ====================="
    echo "This script may be run only on Ubuntu 14.04.4"
    echo "=============================================="
    echo
    exit 1
fi

clear
echo
echo '  ██╗      █████╗ ██████╗  █████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗ '
echo '  ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝ '
echo '  ██║     ███████║██████╔╝███████║███████╗██║     ███████║██║     █████╗   '
echo '  ██║     ██╔══██║██╔══██╗██╔══██║╚════██║██║     ██╔══██║██║     ██╔══╝   '
echo '  ███████╗██║  ██║██║  ██║██║  ██║███████║╚██████╗██║  ██║███████╗███████╗ '
echo '  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝ '
echo
echo '                                        LaraScale package for Ubuntu 14.04 '
echo -e "\n\n"

echo
echo "=========== Install overview ==========="
echo
echo '- Nginx (stable >= 1.8)'
echo '- PHP 7 with PHP7-FPM (php7.0-fpm, php7.0-cli, php7.0-mysql, php7.0-mcrypt, php7.0-mbstring, php7.0-json, php7.0-zip)'
echo '- Percona XtraDB Server (fork MySQL 5.5)'
echo '- Composer + Laravel 5.2'
echo

read -p 'Ok, install right now? [y/n]): ' answer
if [ "$answer" != 'y' ] && [ "$answer" != 'Y'  ]; then
    clear
    echo 'Goodbye my friend!'
    exit 1
fi

echo
echo "- Checking system updates, please wait..."
apt-get update -y --force-yes -qq > /dev/null 2>&1
echo "- System update, please wait..."
apt-get upgrade -y --force-yes -qq > /dev/null 2>&1

echo "- System utils installing..."
apt-get install mc zip unzip htop python-software-properties software-properties-common build-essential -y > /dev/null 2>&1

echo
echo "=========== Setting up PHP7 ==========="
echo


add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
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
echo "PHP7 installed succesful!"
echo

echo
echo "=========== Install Nginx ==========="
echo

add-apt-repository ppa:nginx/stable -y > /dev/null 2>&1
apt-get update -y --force-yes -qq > /dev/null 2>&1
apt-get install nginx -y --force-yes -qq > /dev/null 2>&1

rm /etc/nginx/sites-available/default > /dev/null 2>&1
wget https://raw.githubusercontent.com/globalmac/LaraScale-Ubuntu/master/nginx/default -O /etc/nginx/sites-available/default > /dev/null 2>&1

echo
echo "Nginx installed succesful!"
echo

echo
echo "=========== Install Percona XtraDB Server ==========="
echo

apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A > /dev/null 2>&1
echo "deb http://repo.percona.com/apt `lsb_release -cs` main" >> /etc/apt/sources.list.d/percona.list > /dev/null 2>&1
echo "deb-src http://repo.percona.com/apt `lsb_release -cs` main" >> /etc/apt/sources.list.d/percona.list > /dev/null 2>&1

apt-get update -y --force-yes -qq > /dev/null 2>&1

#echo percona-server-5.5 percona-server/root_password password 123 | debconf-set-selections
#echo percona-server-5.5 percona-server/root_password_again password 123 | debconf-set-selections
apt-get install percona-server-server-5.5 percona-server-client-5.5 -y

mysql -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'" -u root -p123
mysql -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'" -u root -p123
mysql -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'" -u root -p123

echo
echo "=========== Attention! MySQL root user password is: 123 ==========="
echo

mysql_secure_installation

echo
echo "MySQL (Percona XtraDB Server) installed succesful!"
echo

echo
echo "=========== Adding larascale user ==========="
echo

useradd -g sudo -d /var/www/larascale -m -s /bin/bash larascale
echo
echo "Please enter larascale user password"
echo

passwd larascale

mkdir -p /var/www/larascale/sites
chown -R larascale:www-data /var/www/larascale


echo
echo "larascale user added succesful!"
echo

echo
echo "=========== Installing Composer & Laravel 5.2 ==========="
echo

cd /var/www/larascale
curl -sS https://getcomposer.org/installer | php > /dev/null 2>&1
mv composer.phar /usr/local/bin/composer > /dev/null 2>&1 > /dev/null 2>&1
composer create-project --prefer-dist laravel/laravel sites > /dev/null 2>&1
chown -R larascale:www-data /var/www/larascale > /dev/null 2>&1
cd sites
chmod -R o+w storage > /dev/null 2>&1
chmod -R o+w bootstrap/cache > /dev/null 2>&1

service php7.0-fpm restart > /dev/null 2>&1
service nginx restart > /dev/null 2>&1
service mysql restart > /dev/null 2>&1

echo "==========="
echo "Installation complete succesful! Your new Laravel is ready!"
echo "==========="

exit
