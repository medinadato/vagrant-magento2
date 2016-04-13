# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Update package mirrors and update base system
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
apt-get update
apt-get upgrade -y

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install and configure PHP
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sudo apt-get install -y git redis-server
sudo apt-get install -y php5-fpm php5-curl php5-cli php5-xdebug php5-mysql php5-gd php5-intl php5-xsl php5-mcrypt

# Restore missing mcrypt plugin
sudo php5enmod mcrypt

#ln -sf /vagrant/provision/etc/php5/fpm/php.ini /etc/php5/fpm/php.ini

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Enables Xdebug support
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo "zend_extension=xdebug.so" > /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_enable = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.max_nesting_level = 200" >> /etc/php5/fpm/conf.d/20-xdebug.ini

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

#ln -sf /vagrant/provision/etc/ssh/ssh_config /etc/ssh/ssh_config
ln -sf /vagrant/provision/etc/hosts /etc/hosts

ln -s /vagrant/www /usr/share/nginx/www

sed -i 's/sendfile on/sendfile off/g' /etc/nginx/nginx.conf

/etc/init.d/nginx restart

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install and configure MySQL
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
export DEBIAN_FRONTEND=noninteractive

apt-get install -y mysql-server-5.6 mysql-client-5.6

mysql -uroot -e "DROP DATABASE IF EXISTS db_purebaby"
mysql -uroot -e "CREATE DATABASE db_purebaby"
mysql -uroot db_purebaby < /vagrant/provision/mysql/magento.sql


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Crontab
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ln -sf /vagrant/provision/etc/crontab/vagrant /var/spool/cron/crontabs/vagrant


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Magento
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#ln -s /vagrant/www/app/etc/local.xml_dev /vagrant/www/app/etc/local.xml