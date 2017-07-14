#!/bin/bash

export PATH=$PATH:/sbin

os='Ubuntu'
release="$(lsb_release -s -r)"
codename="$(lsb_release -s -c)"

# Check for root
if [ "x$(id -u)" != 'x0' ]; then
    echo
    echo "Error! This script can only be executed by root"
    echo
    exit 1
fi

# Check larascale user account
if [ ! -z "$(grep ^larascale: /etc/passwd)" ] && [ -z "$1" ]; then
    echo
    echo "Error! User - larascale - exists! Please remove larascale user account before proceeding."
    echo
    exit 1
fi

# Defining return code check function
check_result() {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        exit $1
    fi
}

gen_pass() {
    MATRIX='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    LENGTH=16
    while [ ${n:=1} -le $LENGTH ]; do
        PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
    done
    echo "$PASS"
}

clear
echo
echo
echo '  ██╗      █████╗ ██████╗  █████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗ '
echo '  ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝ '
echo '  ██║     ███████║██████╔╝███████║███████╗██║     ███████║██║     █████╗   '
echo '  ██║     ██╔══██║██╔══██╗██╔══██║╚════██║██║     ██╔══██║██║     ██╔══╝   '
echo '  ███████╗██║  ██║██║  ██║██║  ██║███████║╚██████╗██║  ██║███████╗███████╗ '
echo '  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝ '
echo
echo "                    LaraScale package for $os $codename $release"
echo -e "\n\n"                                             


echo
echo "=========== Install overview ==========="
echo
echo "- Packages: mc, zip, unzip, htop, software-properties-common, build-essential, python-software-properties, python-pip, fail2ban, gcc, libmcrypt4, libpcre3-dev, ufw, unattended-upgrades & whois"
echo "- Nginx (stable)"
echo "- PHP 7.1 with PHP-FPM"
echo "- PostgreSQL 9.6"
echo "- NodeJS 6.x"
echo "- Memcached Server"
echo "- Python Supervisor"
echo "- Beanstalkd Queques Server"
echo "- Composer + Laravel (lastest version)"
echo

read -p 'Ok, install right now? [y/n]): ' answer
if [ "$answer" != 'y' ] && [ "$answer" != 'Y'  ]; then
    clear
    echo 'Goodbye my friend!'
    exit 1
fi



echo
echo "=========== Packages installing ==========="
echo

# Install helpful packages
apt-get install zsh mc zip unzip htop software-properties-common build-essential python-software-properties python-pip fail2ban gcc libmcrypt4 libpcre3-dev ufw unattended-upgrades whois -y > /dev/null 2>&1
#check_result $? "system packages not be installed!"

# Disabled default IPV6 listing
sudo sed -i "s/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/" /etc/gai.conf > /dev/null 2>&1

echo "- Setup timezone - Europe/Moscow..."

echo "Europe/Moscow" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

echo "- Setup automaticaly Security Updates..."

cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "Ubuntu xenial-security";
};
Unattended-Upgrade::Package-Blacklist {
    //
};
EOF

cat > /etc/apt/apt.conf.d/10periodic << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Setup UFW Firewall

ufw allow 22 > /dev/null 2>&1
ufw allow 80 > /dev/null 2>&1
ufw allow 443 > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1

echo
echo "- UFW Firewall enabled succesful! Allowed - 22, 80 & 443 ports!"
echo



echo
echo "=========== Larascale user setup ==========="
echo

#useradd -g sudo -d /home/larascale -m -s /bin/bash larascale > /dev/null 2>&1
#mkdir -p /home/larascale/.ssh > /dev/null 2>&1

useradd larascale > /dev/null 2>&1
mkdir -p /home/larascale/.ssh > /dev/null 2>&1
mkdir -p /home/larascale/.forge > /dev/null 2>&1
adduser larascale sudo > /dev/null 2>&1


# Setup Bash For larascale User

chsh -s /bin/bash larascale > /dev/null 2>&1
cp /root/.profile /home/larascale/.profile > /dev/null 2>&1
cp /root/.bashrc /home/larascale/.bashrc > /dev/null 2>&1

# Set The Sudo Password For larascale

LARASCALE_USER_PASSWORD=$(gen_pass)
echo -e "$LARASCALE_USER_PASSWORD\n$LARASCALE_USER_PASSWORD\n" | passwd larascale > /dev/null 2>&1

# Create The Server SSH Key

ssh-keygen -f /home/larascale/.ssh/id_rsa -t rsa -N '' > /dev/null 2>&1

# Add larascale User To www-data Group

usermod -a -G www-data larascale > /dev/null 2>&1
id larascale > /dev/null 2>&1
groups larascale > /dev/null 2>&1

# Setup larascale Home Directory Permissions

chown -R larascale:larascale /home/larascale > /dev/null 2>&1
chmod -R 755 /home/larascale > /dev/null 2>&1
chmod 700 /home/larascale/.ssh/id_rsa > /dev/null 2>&1



echo
echo "- User configure succesful!"
echo

echo
echo "=========== Install Nginx ==========="
echo

add-apt-repository ppa:nginx/stable -y > /dev/null 2>&1
apt-get update -y --force-yes -qq > /dev/null 2>&1

apt-get install nginx -y > /dev/null 2>&1

# Configure Primary Nginx Settings

sed -i "s/user www-data;/user larascale;/" /etc/nginx/nginx.conf
sed -i "s/worker_processes.*/worker_processes auto;/" /etc/nginx/nginx.conf
sed -i "s/# multi_accept.*/multi_accept on;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

# Configure Gzip

cat > /etc/nginx/conf.d/gzip.conf << EOF
gzip_comp_level 5;
gzip_min_length 256;
gzip_proxied any;
gzip_vary on;

gzip_types
application/atom+xml
application/javascript
application/json
application/rss+xml
application/vnd.ms-fontobject
application/x-font-ttf
application/x-web-app-manifest+json
application/xhtml+xml
application/xml
font/opentype
image/svg+xml
image/x-icon
text/css
text/plain
text/x-component;

EOF

# Disable The Default Nginx Site

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

wget https://raw.githubusercontent.com/globalmac/Larascale/master/nginx/laravel -O /etc/nginx/sites-available/laravel > /dev/null 2>&1
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel

service nginx restart


# Install A Catch All Server

cat > /etc/nginx/sites-available/catch-all << EOF
server {
    return 404;
}
EOF

ln -s /etc/nginx/sites-available/catch-all /etc/nginx/sites-enabled/catch-all

# Restart Nginx
service nginx restart
service nginx reload

echo
echo "- Nginx installed succesful!"
echo


echo
echo "=========== Install PHP7.1 with modules: ==========="
echo

echo "1) php-pear"
echo "2) php7.1-cli"
echo "3) php7.1-fpm"
echo "4) php7.1-dev"
echo "5) php7.1-common"
echo "6) php7.1-imap"
echo "7) php7.1-mbstring"
echo "8) php7.1-zip"
echo "9) php7.1-bcmath"
echo "10) php7.1-soap"
echo "11) php7.1-intl"
echo "12) php7.1-readline"
echo "13) php7.1-mcrypt"
echo "14) php7.1-curl"
echo "15) php7.1-json"
echo "16) php7.1-gd"
echo "17) php7.1-pgsql"
echo "18) php7.1-memcached"
echo "19) php7.1-imagick"
echo "20) php7.1-xml"

echo
echo "- Installing, please wait..."
echo

add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
apt-get update -y --force-yes -qq > /dev/null 2>&1

apt-get install php-pear php7.1-cli php7.1-fpm php7.1-dev php7.1-common php7.1-imap php7.1-mbstring php7.1-zip php7.1-bcmath php7.1-soap php7.1-intl php7.1-readline php7.1-mcrypt php7.1-curl php7.1-json php7.1-gd php7.1-pgsql php7.1-memcached php7.1-imagick php7.1-xml imagemagick -y --force-yes -qq > /dev/null 2>&1

echo
echo "- Configure some PHP settings, please wait..."
echo

# Misc. PHP CLI Configuration

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
#sudo sed -i "s/;date.timezone.*/date.timezone = Europe/Moscow" /etc/php/7.1/cli/php.ini   

# Configure Sessions Directory Permissions

chmod 733 /var/lib/php/sessions
chmod +t /var/lib/php/sessions

# Tweak Some PHP-FPM Settings

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/fpm/php.ini
#sed -i "s/;date.timezone.*/date.timezone = Europe/Moscow/" /etc/php/7.1/fpm/php.ini

# Configure FPM Pool Settings

sed -i "s/^user = www-data/user = larascale/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/^group = www-data/group = larascale/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/;listen\.owner.*/listen.owner = larascale/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/;listen\.group.*/listen.group = larascale/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.1/fpm/pool.d/www.conf
#sed -i "s/;request_terminate_timeout.*/request_terminate_timeout = 600/" /etc/php/7.1/fpm/pool.d/www.conf

service php7.1-fpm restart > /dev/null 2>&1

echo
echo "- Configure Memcached Server, please wait..."
echo

apt-get install memcached -y --force-yes -qq > /dev/null 2>&1
sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf
service memcached restart > /dev/null 2>&1

echo
echo "- PHP7.1 & Memcached installed succesful!"
echo

echo
echo "=========== Install Beanstalkd and Supervisor ==========="
echo

echo
echo "- Configure Beanstalkd Server and Supervisor, please wait..."
echo

# Install & Configure Beanstalk
apt-get install beanstalkd -y --force-yes -qq > /dev/null 2>&1
sed -i "s/BEANSTALKD_LISTEN_ADDR.*/BEANSTALKD_LISTEN_ADDR=0.0.0.0/" /etc/default/beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
/etc/init.d/beanstalkd start > /dev/null 2>&1

# Configure Supervisor Autostart

systemctl enable supervisor.service > /dev/null 2>&1
service supervisor start > /dev/null 2>&1

echo
echo "- Beanstalkd and Supervisor installed succesful!"
echo



echo
echo "=========== Install NodeJS 6.x ==========="
echo

curl --silent --location https://deb.nodesource.com/setup_6.x | bash - > /dev/null 2>&1

apt-get update -y --force-yes -qq > /dev/null 2>&1

apt-get install nodejs -y --force-yes -qq > /dev/null 2>&1

npm install -g pm2 > /dev/null 2>&1
npm install -g gulp > /dev/null 2>&1
npm install -g yarn > /dev/null 2>&1
npm install -g socket.io > /dev/null 2>&1

echo
echo "- NodeJS installed succesful!"
echo

echo
echo "=========== Install PostgreSQL 9.6 ==========="
echo

PSQL_ROOT_PASSWORD=$(gen_pass)
PSQL_PASSWORD=$(gen_pass)

echo
echo "- Installing, please wait..."
echo

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' -y > /dev/null 2>&1

wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add - > /dev/null 2>&1
apt-get update -y > /dev/null 2>&1
apt-get install postgresql postgresql-contrib -y > /dev/null 2>&1

echo
echo "- Setting up PostgreSQL..."
echo

sudo -i -u postgres psql -q -c "ALTER USER postgres WITH PASSWORD '$PSQL_ROOT_PASSWORD';"
sudo -i -u postgres psql -q -c "create database larascale with encoding='UNICODE';"
sudo -i -u postgres psql -q -c "create user larascale with password '$PSQL_PASSWORD';"
sudo -i -u postgres psql -q -c "grant all privileges on database larascale to larascale;"

echo
echo "==> PostgreSQL 9.6 installed succesful!"
echo


echo
echo "=========== Installing Composer & Laravel 5.4 ==========="
echo

cd /home/larascale
curl -sS https://getcomposer.org/installer | php > /dev/null 2>&1
mv composer.phar /usr/local/bin/composer > /dev/null 2>&1 > /dev/null 2>&1

echo
echo "Installing Laravel 5.4 by Composer, please wait, it can be more than 3-5 minutes..."
echo

composer create-project --prefer-dist laravel/laravel laravel > /dev/null 2>&1

chown -R larascale:larascale /home/larascale > /dev/null 2>&1
cd /home/larascale/laravel
chmod -R 777 storage > /dev/null 2>&1
chmod -R 777 bootstrap/cache > /dev/null 2>&1

service php7.1-fpm restart > /dev/null 2>&1
service nginx restart > /dev/null 2>&1
service postgresql restart > /dev/null 2>&1

echo "==========="
echo "Installation complete successfully! Your new Laravel is ready!"
echo "1) SSH user:"
echo "Login: larascale"
echo "Password: $LARASCALE_USER_PASSWORD"
echo "2) PostgreSQL info:"
echo "Login: postgres"
echo "Password: $PSQL_ROOT_PASSWORD"
echo
echo "Login: larascale"
echo "Password: $PSQL_PASSWORD" 
echo
echo "Your Laravel site run on - http://$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
echo ""
echo "==========="

apt-get clean -y > /dev/null 2>&1
apt-get autoclean -y > /dev/null 2>&1
apt-get autoremove -y > /dev/null 2>&1

exit 0
