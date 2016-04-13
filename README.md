# Overview

It's a Magento 2 project. This document provides instructions to get it running on Vagrant.


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


# Host machine

You must have installed Vagrant and Virtual Box.


## Load the submodule

> Note: In order to load your module, you might need to add your public key to Bitbucket.
> Check with the BitBucket administrator you have the right permissions to run git on ssh.

```bash
$ git pull && git submodule init && git submodule update && git submodule status
```

If adding your public key to BitBucket is not an option you can run the alternative command:

```bash
$ rm -rf www
$ git clone https://YOUR_BITBUCKET_USERNAME@bitbucket.org/wolfinteractive/purebaby.com.au.git www
```

## Bring vagrant up:

```bash
$ vagrant up
```

## Hosts file

Add the following code into the host /etc/hosts file:

```bash
100.0.0.50 local.purebaby.com.au
```


# Magento

## Admin

URL | User | Pass
--------------------------------------------- | ----- | --------
http://local.purebaby.com.au/index.php/admin/ | admin | adm1234