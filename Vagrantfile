# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Project: BasePHP VM
# File: Vagrantfile created by Ariel Bogdziewicz on 29/07/2018
# Author: Ariel Bogdziewicz
# Copyright: Copyright © 2018 Ariel Bogdziewicz. All rights reserved.
# License: MIT
#
require 'json'

# Predefined file names for default and user configs.
config_default_path = 'vagrant-config.user.json'
config_user_path = 'vagrant-config.user.json'

# Load user configuration otherwise fallback to default configuration.
if File.file?(config_user_path)
    config_file = File.read(config_user_path)
else
    config_file = File.read(config_default_path)
end

# Parse JSON and load configuration to hash table.
vagrant_config = JSON.parse(config_file)

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # Ubuntu 18.04 LTS (Bento)
    config.vm.box = "bento/ubuntu-18.04"
    config.vm.box_version = "201806.08.0"

    # Provisioning
    config.vm.provision "shell", path: "provision.sh"

    # Configure network
    config.vm.network "private_network", ip: vagrant_config['virtual_machine']['ip_address']
    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.network :forwarded_port, guest: 443, host: 8443

    # Virtual machine properties
    config.vm.provider :virtualbox do |vb|
        vb.name = vagrant_config['virtual_machine']['name']
        vb.memory = vagrant_config['virtual_machine']['memory']
    end

    # Provision scripts
    vagrant_config['provision_scripts'].each do |provision|
        config.vm.provision provision['name'], type: provision['type'], preserve_order: true, path: provision['script']
    end

    # Synced folders
    vagrant_config['synced_folders'].each do |synced_folder|
        config.vm.synced_folder synced_folder['from'], synced_folder['to']
    end
end
