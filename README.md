
# BasePHP VM

Virtual machine for **BasePHP** projects and libraries based on Vagrant.

## Installation

This instruction works for **Mac OS**, **Linux** or **Windows** operating systems:

### Pre-requirements

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Install [Vagrant](https://www.vagrantup.com/downloads.html)
1. Install [Git](https://git-scm.com/downloads)
1. Clone this repository

### Configuration

Copy file `vagrant-config.default.json` to file with name `vagrant-config.user.json`:

```
cp vagrant-config.default.json vagrant-config.user.json
```

File `vagrant-config.user.json` is added to `.gitignore` file so any
custom settings can be put there. You can add there synced folders and
paths to provision scripts for any projects based on **BasePHP** framework.

### Example of configuration

Let say we want to configure virtual machine for project **BasePHP Framework**
or any other project based on **BasePHP**. File `vagrant-config.user.json` would be following:

```
{
  "virtual_machine": {
    "ip_address": "192.168.10.151",
    "memory": 2048,
    "name": "basephp.vm"
  },
  "synced_folders": [
    {
      "from": ".",
      "to": "/vagrant"
    },
    {
      "from": "../basephp-framework",
      "to": "/home/vagrant/www/basephp-framework"
    }
  ],
  "provision_scripts": [
    {
      "name": "default",
      "script": "./provision.sh",
      "type": "shell"
    },
    {
      "name": "basephp-framework",
      "script": "../basephp-framework/vagrant/provision.sh",
      "type": "shell"
    }
  ]
}
```

### Vagrant commands

All following commands must be used in directory with `Vagrantfile`.

Go to folder with cloned **BasePHP VM** and execute following command to launch virtual machine:

```
vagrant up
```

You may login into virtual machine through **SSH**:

```
vagrant ssh 
```

If you change synced folders then you have to reload virtual machine 
using command:

```
vagrant reload
```

If you change provision scripts then you have to perform provisioning again
using command:

```
vagrant provision 
```

If you want to refresh only one provision script then you may use command
similar to this:

```
vagrant provision --provision-with "basephp-framework" 
```

Turning off:

```
vagrant halt 
```

Destroying virtual machine with all data:

```
vagrant destroy 
```

After destroying `vagrant up` will recreate virtual machine from scratch.

### Set domains on host machine

You need to configure domains for **BasePHP** projects on
your host machine.

#### Recommendations

Domain `.dev` is not recommended for your local projects because it
is real generic top-level domain (gTLD). Popular browsers force using `https://`
protocol for this domain. You can pick one of the following top-level
domains for your local projects: `.vm`, `.test`, `.local`.

#### Domains without wildcard

Domains without wildcard can be added to file `/etc/hosts`. For example:

```
192.168.10.151 basephp-framework.vm 
```

Where `192.168.10.151` is IP address of your virtual machine.
