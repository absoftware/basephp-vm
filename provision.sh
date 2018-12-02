#!/bin/bash
#
# Project: BasePHP VM
# File: provision.sh created by Ariel Bogdziewicz on 29/07/2018
# Author: Ariel Bogdziewicz
# Copyright: Copyright © 2018 Ariel Bogdziewicz. All rights reserved.
# License: MIT
#
export DEBIAN_FRONTEND=noninteractive

update_apt_get() {
    echo "Updating apt-get"
    apt-get -y update
    apt-get -y upgrade
}

install_emacs() {
    echo "Installing Emacs"
    apt-get -y install emacs
    
    echo "Copying Emacs configuration file to vagrant home directory"
    cp /vagrant/files/home/.emacs /home/vagrant/.emacs
    chmod 644 /home/vagrant/.emacs
    chown vagrant:vagrant /home/vagrant/.emacs
    
    echo "Copying Emacs configuration file to root home directory"
    cp /vagrant/files/home/.emacs /root/.emacs
    chmod 644 /root/.emacs
    chown root:root /root/.emacs
}

set_locale() {
    echo "Copying locale configuration"
    cp /vagrant/files/etc/default/locale /etc/default/locale
    chmod 644 /etc/default/locale
    chown root:root /etc/default/locale
}

set_hostname() {
    echo "Copying hostname configuration"
    cp /vagrant/files/etc/hostname /etc/hostname
    chmod 644 /etc/hostname
    chown root:root /etc/hostname
}

install_openssh() {
    echo "Installing Open SSH"
    apt-get -y install openssh-server openssh-client
    service ssh restart
}

install_git() {
    echo "Installing Git"
    apt-get -y install git gitk ruby
    
    echo "Copying Bash configuration file to vagrant home directory"
    cp /vagrant/files/home/.bash_profile /home/vagrant/.bash_profile
    chmod 644 /home/vagrant/.bash_profile
    chown vagrant:vagrant /home/vagrant/.bash_profile
    
    echo "Copying Bash configuration file to root home directory"
    cp /vagrant/files/home/.bash_profile /root/.bash_profile
    chmod 644 /root/.bash_profile
    chown root:root /root/.bash_profile
}

install_mysql() {
    echo "Installing MySQL"
    apt-get -y update
    apt-get -y upgrade
    apt-get -q -y install mysql-server mysql-client
    service mysql restart
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

    echo "Copying MySQL configuration files"
    cp /vagrant/files/etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
    chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf
    chown root:root /etc/mysql/mysql.conf.d/mysqld.cnf
    
    echo "Restarting MySQL service"
    service mysql restart
}

install_apache_php() {
    echo "Installing Apache and PHP"
    apt-get -y install apache2 php7.2 libapache2-mod-php7.2 php7.2-mysql \
        php7.2-cgi php7.2-cli php7.2-gd php-geoip php7.2-dev libgeoip-dev \
        php7.2-curl php-pear php-imagick php7.2-intl php7.2-mbstring \
        php-gettext php7.2-imap
    a2enmod rewrite

    echo "Associating Vagrant user with Apache"
    gpasswd -a vagrant www-data
    gpasswd -a www-data vagrant
    
    echo "Copying Apache configuration files"

    cp /vagrant/files/etc/apache2/conf-available/charset.conf /etc/apache2/conf-available/charset.conf
    chmod 644 /etc/apache2/conf-available/charset.conf
    chown root:root /etc/apache2/conf-available/charset.conf
    
    cp -r /vagrant/files/var/www/html/phpinfo /var/www/html
    chmod 755 /var/www/html/phpinfo
    chmod 644 /var/www/html/phpinfo/index.php
    chown -R root:root /var/www/html/phpinfo
    
    echo "Restarting Apache service"
    service apache2 restart
}

install_less() {
    echo "Installing LESS"
    apt-get -y install nodejs
    apt-get -y install npm
    npm install -g less less-plugin-clean-css
}

website_configuration() {
    echo "Changing default site"
    cp /vagrant/files/etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf
    chmod 644 /etc/apache2/sites-available/000-default.conf
    chown root:root /etc/apache2/sites-available/000-default.conf
    a2ensite 000-default.conf

    echo "Disabling conflicting Apache2 modules"
    a2disconf javascript-common

    echo "Restarting Apache"
    service apache2 reload
}

echo "BasePHP VM - Provisioning virtual machine..."
update_apt_get
install_emacs
set_locale
set_hostname
install_openssh
install_git
install_mysql
install_apache_php
install_less
website_configuration
