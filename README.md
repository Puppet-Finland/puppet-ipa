# easy_ipa Puppet module
[![Build Status](https://travis-ci.org/Puppet-Finland/puppet-ipa.svg?branch=master)](https://travis-ci.org/Puppet-Finland/puppet-ipa)

## Overview

This module will install and configure IPA servers, replicas, and clients. This module was forked from huit-ipa, 
and refactored with a focus on simplicity and ease of use.

The following features work great:
- Creating a domain.
- Adding IPA server replicas.
- Joining clients.
- WebUI proxy to https://localhost:8440 (for vagrant testing).

The following features were stripped out and are currently unavailable:
- Autofs configuration.
- Sudo rule management.
- Host management (beyond simple clinet domain joins).
- Host joins via one time passwords.
- Dns zone management (beyond creating an initial zone).

## Dependencies
This module requires [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) >= 4.13.0.

## Usage

### Example usage:

Creating an IPA master, with the WebUI proxied to `https://localhost:8440`.
```puppet
class {'easy_ipa':
    ipa_role                    => 'master',
    domain                      => 'vagrant.example.lan',
    ipa_server_fqdn             => 'ipa-server-1.vagrant.example.lan',
    admin_password              => 'vagrant123',
    directory_services_password => 'vagrant123',
    install_ipa_server          => true,
    ip_address                  => '192.168.56.35',
    enable_ip_address           => true,
    enable_hostname             => true,
    manage_host_entry           => true,
    install_epel                => true,
    webui_disable_kerberos      => true,
    webui_enable_proxy          => true,
    webui_force_https           => true,
}
```

Adding a replica:
```puppet
class {'::easy_ipa':
    ipa_role             => 'replica',
    domain               => 'vagrant.example.lan',
    ipa_server_fqdn      => 'ipa-server-2.vagrant.example.lan',
    domain_join_password => 'vagrant123',
    install_ipa_server   => true,
    ip_address           => '192.168.56.36',
    enable_ip_address    => true,
    enable_hostname      => true,
    manage_host_entry    => true,
    install_epel         => true,
    ipa_master_fqdn      => 'ipa-server-1.vagrant.example.lan',
}
```

Add monitoring with [monit](https://mmonit.com/monit/). Depends on the 
[puppetfinland-monit](https://github.com/Puppet-Finland/monit) module:

```
class { '::easy_ipa::monit::server':
    email => 'monitoring@domain.com',
}
```

Add iptables/ip6tables allow rules:

```
class { '::easy_ipa::packetfilter::server':
    allow_address_ipv4 => '10.0.0.0/8',
    allow_address_ipv6 => '::1',
}
```

Add a backup job to cron:
```
    easy_ipa::backup { 'full':
      type      => 'full',
      timestamp => false,
      monthday  => 1,
      weekday   => undef,
      hour      => 4,
      minute    => 15,
      email     => 'admin@domain.com',
    }
```
Backup type can be 'full' or 'data'. Timestamp is either true (default) or 
false. A wrapper script is used as ipa-backup always adds a timestamp to the 
backup directory, which makes no sense if an external system (e.g. Bacula) is 
handling backup versioning anyways.

Adding a local named.conf configuration fragment:
```puppet
::easy_ipa::config::named { 'tsig-key':
  content => template('profile/named-tsig-key.conf.erb'),
}
```
These can be used for various purposes, for example to add a key which allows
dynamic DNS updates to certain DNS zones.

Adding a client:
```puppet
class {'::easy_ipa':
ipa_role             => 'client',
domain               => 'vagrant.example.lan',
domain_join_password => 'vagrant123',
install_epel         => true,
ipa_master_fqdn      => 'ipa-server-1.vagrant.example.lan',
}
```

### Support for systems without ipa client packages

This module has partial support configuring ipa clients on operating systems 
which lack ipa client package and thus the ipa-client-install script. Right now 
Debian 9 is the only operating system supported in this way. Client-side is 
configured with the exception that sshd_config is not touched to prevent 
configuration overlap with other Puppet modules. Adapt the following procedure 
(adapted from [here](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/identity_management_guide/linux-manual)) 
to complete the enrollment of a host into IPA.

On the IPA master:

    kinit admin
    ipa host-add --ip-address=192.168.56.40 ipa-client-4.vagrant.example.lan
    ipa host-add-managedby --hosts=ipa-server-1.vagrant.example.lan ipa-client-4.vagrant.example.lan
    ipa-getkeytab --server=ipa-server-1.vagrant.example.lan -p host/ipa-client-4.vagrant.example.lan -k /tmp/ipa-client-4.keytab
    chmod 644 /tmp/ipa-client-4.keytab

Copy the keytab to /etc/krb5.keytab on the client host to be enrolled and in there run

    chown root:root /etc/krb5.keytab
    chmod 600 /etc/krb5.keytab

Assuming you had ran Puppet on the client and launching of sssd had failed, try again now:

    systemctl restart sssd

You should now be able to use kinit normally on the enrolled client:

    kinit admin

Many of these steps could be automated with exported resources, but getting the 
Kerberos keytab back to the enrolled would somewhat be challenging. 

### Mandatory Parameters

#### `domain`
Mandatory. The name of the IPA domain to create or join.

#### `ipa_role`
Mandatory. What role the node will be. Options are 'master', 'replica', and 'client'.

#### `admin_password`
Mandatory if `ipa_role` is set as 'Master' or 'Replica'.
Password which will be assigned to the IPA account named 'admin'.

#### `directory_services_password`
Mandatory if `ipa_role` is set as 'Master'.
Password which will be passed into the ipa setup's parameter named "--ds-password".

### Optional Parameters

#### `autofs_package_name`
Name of the autofs package to install if enabled.

#### `configure_dns_server`
If true, then the parameter '--setup-dns' is passed to the IPA server installer.
Also, triggers the install of the required dns server packages.

#### `configure_replica_ca`
If true, then the parameter '--setup-ca' is passed to the IPA replica installer.

#### `configure_ntp`
If false, then the parameter '--no-ntp' is passed to the IPA server installer.

#### `custom_dns_forwarders`
Each element in this array is prefixed with '--forwarder ' and passed to the IPA server installer.

#### `domain_join_principal`
The principal (usually username) used to join a client or replica to the IPA domain.

#### `domain_join_password`
The password for the domain_join_principal.

#### `enable_hostname`
If true, then the parameter '--hostname' is populated with the parameter 'ipa_server_fqdn'
and passed to the IPA installer. On client installs '--hostname' is populated with `$::fqdn`.

#### `enable_ip_address`
If true, then the parameter '--ip-address' is populated with the parameter 'ip_address'
and passed to the IPA installer.

#### `fixed_primary`
If true, then the parameter '--fixed-primary' is passed to the IPA installer.

#### `idstart`
From the IPA man pages: "The starting user and group id number".

#### `idmax`
From the IPA man pages: "The max value for the IDs range (default: idstart+199999)".

#### `install_autofs`
If true, then the autofs packages are installed.

#### `install_epel`
If true, then the epel repo is installed. The epel repo is usually required for sssd packages.

#### `install_kstart`
If true, then the kstart packages are installed.

#### `install_ldaputils`
If true, then the ldaputils packages are installed.

#### `install_sssdtools`
If true, then the sssdtools packages are installed.

#### `ipa_client_package_name`
Name of the IPA client package.

#### `ipa_server_package_name`
Name of the IPA server package.

#### `install_ipa_client`
If true, then the IPA client packages are installed if the parameter 'ipa_role' is set to 'client'.

#### `install_ipa_server`
If true, then the IPA server packages are installed if the parameter 'ipa_role' is not set to 'client'.

#### `install_sssd`
If true, then the sssd packages are installed.

#### `ip_address`
IP address to pass to the IPA installer.

#### `ipa_server_fqdn`
Actual fqdn of the IPA server or client.

#### `kstart_package_name`
Name of the kstart package.

#### `ldaputils_package_name`
Name of the ldaputils package.

#### `ipa_master_fqdn`
FQDN of the server to use for a client or replica domain join.

#### `manage_host_entry`
If true, then a host entry is created using the parameters 'ipa_server_fqdn' and 'ip_address'.

#### `mkhomedir`
If true, then the parameter '--mkhomedir' is passed to the IPA client installer.

#### `no_ui_redirect`
If true, then the parameter '--no-ui-redirect' is passed to the IPA server installer.

#### `realm`
The name of the IPA realm to create or join.

#### `sssd_package_name`
Name of the sssd package.

#### `sssdtools_package_name`
Name of the sssdtools package.

####  ̀gssapi_no_negotiate ̀

Suppress setting Negotiate headers based on BrowserMatch. Not sending these headers is useful to work around browsers that do not handle them properly (and incorrectly show authentication popups to users). Example: "Windows". Default undef.

#### `webui_enable_proxy`
If true, then httpd is configured to act as a reverse proxy for the IPA Web UI. This allows
for the Web UI to be accessed from different ports and hostnames than the default.

#### `webui_force_https`
If true, then /etc/httpd/conf.d/ipa-rewrite.conf is modified to force all connections to https.
This is necessary to allow the WebUI to be accessed behind a reverse proxy when using nonstandard
ports.

#### `webui_proxy_external_fqdn`
The public or external FQDN used to access the IPA Web UI behind the reverse proxy.

#### `webui_proxy_https_port`
The HTTPS port to use for the reverse proxy. Cannot be 443.


## Limitations

This module has only been tested on Centos 7.

## Testing
A vagrantfile is provided for easy testing.

Steps to get started:
 1. Install vagrant.
 1. Install virtualbox.
 1. Clone this repo.
 1. Run `vagrant up` in a terminal window from the root of the repo.
 1. Open a browser and navigate to `https://localhost:8440`.
 Log in with username `admin` and password `vagrant123`.

## License
jpuskar/puppet-easy_ipa forked from:
huit/puppet-ipa - Puppet module that can manage an IPA master, replicas and clients.

    Copyright (C) 2013 Harvard University Information Technology
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
