# LaraScale package for Ubuntu 14.04
Simple to use Laravel 5.2 install shell script for Ubuntu 14.04

## Include:

*   Nginx
*   PHP 7 (PHP7-FPM)
*   Percona XtraDB Server

## 1 step: Services setting up (by root user):

```
curl -O https://raw.githubusercontent.com/globalmac/fastvpsinstall/master/activate.sh
```
```
bash activate.sh
```

## 2 step: Composer & Laravel install (by larascale user):

Login to SSH by larascale user!

```
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer create-project --prefer-dist laravel/laravel larascale
cd larascale
chmod -R o+w storage
chmod -R o+w bootstrap/cache
```


