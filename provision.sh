#!/usr/bin/env bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update package mirrors and update base system
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
aptitude install python-software-properties

LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:nginx/stable
add-apt-repository -y ppa:chris-lea/redis-server

curl https://repo.varnish-cache.org/GPG-key.txt | apt-key add -
echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list

aptitude update
aptitude -y safe-upgrade

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install and configure PHP
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
apt-get install -y php7.0 libapache2-mod-php7.0 php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-intl php7.0-xsl php7.0-mbstring php7.0-zip php7.0-bcmath php7.0-iconv
# settings
sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php/7.0/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/7.0/fpm/php.ini

service php7.0-fpm restart

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Enables Xdebug support
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# php dev tools
apt-get install php7.0-dev
# xdebug
wget "http://xdebug.org/files/xdebug-2.4.0.tgz" && tar -xvzf xdebug-2.4.0.tgz && cd xdebug-2.4.0 && ./configure && make
cp modules/xdebug.so /usr/lib/php/20151012

#echo "zend_extension = /usr/lib/php/20151012/xdebug.so" >> /etc/php/7.0/cli/php.ini
#echo "xdebug.remote_enable = 1" >> /etc/php/7.0/fpm/php.ini
#echo "xdebug.remote_connect_back=1" >> /etc/php/7.0/fpm/php.ini
#echo "xdebug.remote_port = 9000" >> /etc/php/7.0/fpm/php.ini
#echo "xdebug.scream=0" >> /etc/php/7.0/fpm/php.ini
#echo "xdebug.show_local_vars=1" >> /etc/php/7.0/fpm/php.ini
#echo "xdebug.idekey=PHPSTORM" >> /etc/php/7.0/fpm/php.ini

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Caching
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
apt-get install -y redis-server
apt-get install -y varnish

sed -i 's/# VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/g' /etc/default/varnish

mv /etc/varnish/default.vcl /etc/varnish/default.vcl_bkp
ln -sf /vagrant/provision/etc/varnish/varnish.vcl /etc/varnish/default.vcl

service varnish restart

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Dev tools
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
apt-get -y install git tree curl htop

# composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Fix permissions issues
sed -i 's/user = www-data/user = vagrant/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = vagrant/g' /etc/php5/fpm/pool.d/www.conf

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install and configure Nginx
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
apt-get install -y nginx

rm /etc/nginx/sites-enabled/default
ln -sf /vagrant/provision/etc/nginx/sites-enabled/project.conf /etc/nginx/sites-enabled/project.conf
cp /vagrant/provision/etc/init/nginx.conf /etc/init/

ln -sf /vagrant/provision/etc/ssh/ssh_config /etc/ssh/ssh_config
ln -sf /vagrant/provision/etc/hosts /etc/hosts

ln -s /vagrant/www /usr/share/nginx/www

sed -i 's/sendfile on/sendfile off/g' /etc/nginx/nginx.conf

/etc/init.d/nginx restart

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install and configure MySQL
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export DEBIAN_FRONTEND=noninteractive

apt-get install -y mysql-server-5.6 mysql-client-5.6

mysql -uroot -e "GRANT ALL ON *.* to root@'%'";
mysql -uroot -e "DROP DATABASE IF EXISTS magento"
mysql -uroot -e "CREATE DATABASE magento"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf

service mysql restart

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Crontab
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ln -sf /vagrant/provision/etc/crontab/vagrant /var/spool/cron/crontabs/vagrant