#!/bin/sh
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  case \$facts['os']['distro']['codename'] {\
    /(stretch|trusty|xenial)/: {\
      class { 'resolv_conf':\
        nameservers => ['192.168.56.35'],\
      }\
    }\
    /(bionic|buster|focal|bullseye|jammy)/: {\
      class { 'systemd':\
        manage_resolved => true,\
        dns => ['192.168.56.35'],\
      }\
    }\
  }"
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  class {'::easy_ipa':\
    ipa_role => 'client',\
    domain => 'vagrant.example.lan',\
    domain_join_password => 'vagrant123',\
    install_epel => true,\
    ipa_master_fqdn => 'ipa-server-1.vagrant.example.lan',\
  }"
