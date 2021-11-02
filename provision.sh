#!/bin/bash
#
# Project: BasePHP VM
# File: provision.sh created by Ariel Bogdziewicz on 29/07/2018
# Author: Ariel Bogdziewicz
# Copyright: Copyright © 2018 Ariel Bogdziewicz. All rights reserved.
# License: MIT
#
export DEBIAN_FRONTEND=noninteractive

function copy_file {
    echo "copy_file \"${1}\" \"${2}\" ${3} ${4}"
    cp "${1}" "${2}"
    chmod $3 "${2}"
    chown $4 "${2}"
}

update_apt_get() {
    echo "Updating apt-get"
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y build-essential
}

install_emacs() {
    echo "Installing Emacs"
    apt-get install -y emacs

    echo "Copying Emacs configuration file to vagrant home directory"
    copy_file /vagrant/files/home/.emacs /home/vagrant/.emacs 644 vagrant:vagrant

    echo "Copying Emacs configuration file to root home directory"
    copy_file /vagrant/files/home/.emacs /root/.emacs 644 root:root
}

set_hostname() {
    echo "Copying hostname configuration"
    copy_file /vagrant/files/etc/hostname /etc/hostname 644 root:root
}

install_openssh() {
    echo "Installing Open SSH"
    apt-get install -y openssh-server openssh-client
    service ssh restart
}

install_git() {
    echo "Installing Git"
    apt-get install -y git gitk ruby
    
    echo "Copying Bash configuration file to vagrant home directory"
    copy_file /vagrant/files/home/.bash_profile /home/vagrant/.bash_profile 644 vagrant:vagrant
    
    echo "Copying Bash configuration file to root home directory"
    copy_file /vagrant/files/home/.bash_profile /root/.bash_profile 644 root:root
}

install_mysql() {
    echo "Installing MySQL"
    apt-get install -q -y mariadb-server mariadb-client
    service mysql restart

    echo "Loading timezones to MySQL"
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

    echo "Restarting MySQL service"
    service mysql restart
}

install_nginx() {
    echo "Installing NGINX"
    apt-get install -y nginx

    echo "Associating Vagrant user with www-data"
    gpasswd -a vagrant www-data
    gpasswd -a www-data vagrant
}

install_php() {
    echo "Installing PHP"
    apt-get install -y software-properties-common
    add-apt-repository ppa:ondrej/php
    apt-get install -y php8.0-fpm

    echo "Installing PHP extensions"
    apt-get install -y php8.0-mysql php8.0-gd php8.0-mbstring php8.0-curl libphp-adodb php-xdebug

    echo "Update Xdebug config"
    copy_file /vagrant/files/etc/php/8.0/mods-available/xdebug.ini /etc/php/8.0/mods-available/xdebug.ini 644 root:root

    echo "Restarting NGINX and PHP services"
    systemctl restart nginx
    service php8.0-fpm restart
}

default_website_configuration() {
    echo "Copying PHPINFO website"
    cp -r /vagrant/files/var/www/html/phpinfo /var/www/html
    chmod 755 /var/www/html/phpinfo
    chmod 644 /var/www/html/phpinfo/index.php
    chown -R root:root /var/www/html/phpinfo

    echo "Changing default site configuration"
    copy_file /vagrant/files/etc/nginx/sites-available/default /etc/nginx/sites-available/default 644 root:root

    echo "Reloading NGINX"
    service nginx reload
}

install_composer() {
    echo "Installing composer"
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
}

install_python() {
    apt-get install -y python # It's required by NPM to install SASS correctly
}

install_node() {
    echo "Installing NVM"
    su - vagrant -s /bin/bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash'

    echo "Installing Node.js and NPM"
    curl -sL https://deb.nodesource.com/setup_16.x | bash -
    apt-get install -y nodejs

    echo "Copying script which allows easily uninstall Node.js totally"
    copy_file /vagrant/files/home/.rm_nodejs.sh /home/vagrant/.rm_nodejs.sh 644 vagrant:vagrant
}

echo "BasePHP VM - Provisioning virtual machine..."
update_apt_get
install_emacs
set_hostname
install_openssh
install_git
install_mysql
install_nginx
install_php
default_website_configuration
install_python
install_composer
install_node
