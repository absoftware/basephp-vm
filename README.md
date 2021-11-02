
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

Create custom configuration by copying default configuration:

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

## Problems after updating MacOS to Monterey

### VirtualBox's compatibility with MacOS Monterey

First you will get alert as popup that some software from Oracle will stop working just after installation of MacOS Monterey. This alert doesn’t mention that it’s about VirtualBox, but it is.

**So we need to update VirtualBox to version 6.1.28.**

But it brings next troubles described below.

### New limitation according to IP range for host-only adapters

Starting from VirtualBox 6.1.28 there is limitation:

> On Linux, Mac OS X and Solaris Oracle VM VirtualBox will only allow IP addresses in 192.68.56.0/21 range to be assigned to host-only adapters. For IPv6 only link-local addresses are allowed. If other ranges are desired, they can be enabled by creating /etc/vbox/networks.conf and specifying allowed ranges there. For example, to allow 10.0.0.0/8 and 192.168.0.0/16 IPv4 ranges as well as 2001::/64 range put the following lines into /etc/vbox/networks.conf:

```
* 10.0.0.0/8 192.168.0.0/16
* 2001::/64
```

**So by default we must use for Vagrant's IP range 192.168.56.0/21 (from 192.68.56.0 to 192.68.63.255).**

Links:

- VirtualBox bug report: https://www.virtualbox.org/ticket/20626
- VirtualBox documentation: https://www.virtualbox.org/manual/ch06.html#network_hostonly
- VirtualBox documentation: https://docs.oracle.com/en/virtualization/virtualbox/6.1/user/networkingdetails.html#network_hostonly
- Comment from Vagrant's repo: https://github.com/hashicorp/vagrant/issues/12557#issuecomment-953001059

### Error when creating a box

It's related to VirtualBox 6.1.28. If doing `vagrant up` and error occurs like

```
There was an error while executing VBoxManage, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "create"]

Stderr: 0%...
Progress state: NS_ERROR_FAILURE
VBoxManage: error: Failed to create the host-only adapter
VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterfaceWrap, interface IHostNetworkInterface
VBoxManage: error: Context: "RTEXITCODE handleCreate(HandlerArg *)" at line 95 of file VBoxManageHostonly.cpp
```

then please use commands to fix in your host machine

```
sudo kextload -b org.virtualbox.kext.VBoxDrv 
sudo kextload -b org.virtualbox.kext.VBoxNetFlt 
sudo kextload -b org.virtualbox.kext.VBoxNetAdp 
sudo kextload -b org.virtualbox.kext.VBoxUSB
```

### Workaround for Vagrant because of missing headless mode in VirtualBox

It's related to VirtualBox 6.1.28. Doing `vagrant up` it shows error

```
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["startvm", "53a6a976-9a72-42c7-8956-fe61906c23ea", "--type", "headless"]

Stderr: VBoxManage: error: The virtual machine 'bedriftsnett-dev-test' has terminated unexpectedly during startup because of signal 10
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component MachineWrap, interface IMachine
```

Workaround is adding `vb.gui = true` to Vagrantfile

```
config.vm.provider "virtualbox" do |vb|
    vb.gui = true # workaround for https://github.com/hashicorp/vagrant/issues/12557
    # there are other commands in this section as well...
end
```

Downside of this workaround is that VirtualBox will display window with GUI for that virtual machine. Command vb.gui = false means headless mode which is broken after updating to MacOS Monterey.

Links:

- Vagrant bug report: https://github.com/hashicorp/vagrant/issues/12557
- VirtualBox bug report: https://www.virtualbox.org/ticket/20636
