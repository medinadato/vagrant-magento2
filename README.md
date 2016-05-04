# Overview

It's a Magento 2 project. This document provides instructions to get it up and running on Vagrant.


# Tools

## Composer

You might or might not need to install Composer. It's already included in the box. However,
running it on the host is a way faster.

## Git

You might or might not need to install Git. It's already included in the box. However,
running it on the host is a way faster.

## Vagrant

You can download it from here 'https://www.vagrantup.com/downloads.html'.

Also, it's recommended installing vbguest with the command below to avoid shared folder permission issues:

```bash
$ vagrant plugin install vagrant-vbguest
```

## MySQL Remote access

The box is already prepared to allow remote mysql access. To do so just use the command below from your host machine.
> As per Vagrantfile, the currenty ip for this box is 100.0.0.40

```bash
$ mysql -hIP_TO_VAGRANT_BOX -uroot magento
```


# Host machine

You must have installed Vagrant and Virtual Box.


## Load the submodule

### Folder www present

If, inside your magento2 vagrant box there is a www folder, please install the submodule.

> Note: In order to load your module, you might need to add your public key to Bitbucket.
> Check with the BitBucket administrator you have the right permissions to run git on ssh.

```bash
$ git pull && git submodule init && git submodule update && git submodule status
```

### Folder www not present

If adding your public key to BitBucket is not an option you can run the alternative command:

```bash
$ rm -rf www
$ git clone https://github.com/magento/magento2.git www
```

## Bring vagrant up:

```bash
$ vagrant up
```

## Hosts file

Add the following code into the host /etc/hosts file:

```bash
100.0.0.40 local.magento2
```


# Magento

Inside the guest machine run:

```bash
$ cd /vagrant/www/ && composer install
$ php /vagrant/www/bin/magento setup:install --admin-firstname="Admin" --admin-lastname="M2" --admin-email="medina@mdnsolutions.com" --admin-user="admin" --admin-password="adm6543" --base-url="http://local.magento2" --db-name="magento" --db-user="root" --currency="AUD" --language="en_AU" --timezone="Australia/Melbourne" --backend-frontname="admin"
```

Afterwards you should be able to access back-end via:

URL | User | Pass
--------------------------- | ----- | --------
http://local.magento2/admin | admin | adm6543