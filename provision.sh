# Update package mirrors and update base system
apt-get update
apt-get upgrade -y

# Install and configure PHP
apt-get install -y git redis-server
apt-get install -y php5-fpm php5-curl php5-mcrypt php5-cli php5-xdebug php5-mysql php5-gd php5-intl php5-xsl

# other packages
apt-get -y install git tree curl htop 

# Install composer
# curl -sS https://getcomposer.org/installer | php
# mv composer.phar /usr/local/bin/composer
# chmod +x /usr/local/bin/composer

# Enable Xdebug support
echo "zend_extension=xdebug.so" > /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_enable = 1" >> /etc/php5/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php5/fpm/conf.d/20-xdebug.ini

# Fix permissions issues
#3sed -i 's/user = www-data/user = vagrant/g' /etc/php5/fpm/pool.d/www.conf
#sed -i 's/group = www-data/group = vagrant/g' /etc/php5/fpm/pool.d/www.conf

# Restore missing mcrypt plugin
php5enmod mcrypt

ln -sf /vagrant/provision/etc/php5/fpm/php.ini /etc/php5/fpm/php.ini

# Install and configure Nginx
apt-get install -y nginx

#rm /etc/nginx/sites-enabled/default
ln -sf /vagrant/provision/etc/nginx/sites-enabled/project.conf /etc/nginx/sites-enabled/project.conf
cp /vagrant/provision/etc/init/nginx.conf /etc/init/

#ln -sf /vagrant/provision/etc/ssh/ssh_config /etc/ssh/ssh_config
#ln -sf /vagrant/provision/etc/hosts /etc/hosts

ln -s /vagrant/www /usr/share/nginx/www


####mkdir -p /var/log/nginx/magento

service nginx restart

# Install and configure MySQL
export DEBIAN_FRONTEND=noninteractive

apt-get install -y mysql-server-5.6 mysql-client-5.6

mysql -uroot -e "DROP DATABASE IF EXISTS magento2"
mysql -uroot -e "CREATE DATABASE magento2"
#mysql -uroot magento2 < /vagrant/provision/mysql/magento.sql

mysql -uroot -e "GRANT ALL PRIVILEGES ON magento2.* TO 'mage_user'@'%' IDENTIFIED BY 'wolf123'"
mysql -uroot -e "FLUSH PRIVILEGES"
