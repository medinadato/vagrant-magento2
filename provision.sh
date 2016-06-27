#!/usr/bin/env bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update package mirrors and update base system
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
aptitude install -y python-software-properties
aptitude install -y language-pack-en-base

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
apt-get install -y php7.0 libapache2-mod-php7.0 php7.0-fpm php7.0-common php7.0-gd php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-intl php7.0-xsl php7.0-mbstring php7.0-zip php7.0-bcmath php7.0-iconv
# settings
sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php/7.0/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/7.0/fpm/php.ini

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Enables Xdebug support
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# php dev tools
apt-get install -y php7.0-dev

cd /tmp && wget http://xdebug.org/files/xdebug-2.4.0rc2.tgz && tar -xzf xdebug-2.4.0rc2.tgz
cd xdebug-2.4.0RC2/ && phpize && ./configure --enable-xdebug && make && cp modules/xdebug.so /usr/lib/.
#mod-available
echo 'zend_extension="/usr/lib/xdebug.so"' > /etc/php/7.0/mods-available/20-xdebug.ini
echo 'xdebug.remote_enable=1' >> /etc/php/7.0/mods-available/20-xdebug.ini
#enable for FPM
ln -s /etc/php/7.0/mods-available/20-xdebug.ini /etc/php/7.0/fpm/conf.d/20-xdebug.ini
#enable for CLI
#ln -s /etc/php/7.0/mods-available/20-xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini

service php7.0-fpm restart

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Caching/Proxy
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
apt-get install -y redis-server
apt-get install -y varnish

sed -i 's/DAEMON_OPTS="-a :6081/DAEMON_OPTS="-a :80/g' /etc/default/varnish
sed -i 's/default.vcl/magento.vcl/g' /etc/default/varnish

ln -sf /vagrant/provision/etc/varnish/magento.vcl /etc/varnish/magento.vcl

# For Ubuntu v15.04+
# ln -sf /vagrant/provision/etc/systemd/system/varnish.service.d/customexec.conf /etc/systemd/system/varnish.service.d/customexec.conf

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
sed -i 's/user = www-data/user = vagrant/g' /etc/php/7.0/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = vagrant/g' /etc/php/7.0/fpm/pool.d/www.conf

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

service nginx restart

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