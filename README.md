# Overview

This document provides instructions to get Magento 2 running in a Vagrant Machine.


## Host machine

You must have Vagrant and Virtual Machine in order to use this box.

### Vagrant

You can download it from here 'https://www.vagrantup.com/downloads.html'.

Also install vbguest with the comand below to avoid shared folder permissions issues:

vagrant plugin install vagrant-vbguest

### Composer

```bash
$ curl -sS https://getcomposer.org/installer | php
$ mv composer.phar /usr/local/bin/composer
```

### Hosts file

Add the following code to your /etc/hosts file:

```bash
100.0.0.40 local.magento2
```

Bring vagrant up:

```bash
$ vagrant up
```


## Guess machine

TBC


## Magento

## Temporary
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition www

Public Key:
    16e1fa43197072c643dc8deb387cb710
Private Key:
    a63b35affa790bb3b45d8b0ed7284768
