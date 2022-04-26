#!/bin/sh
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  class {'::easy_ipa':\
    ipa_role => 'master',\
    domain => 'vagrant.example.lan',\
    ipa_server_fqdn => 'ipa-server-1.vagrant.example.lan',\
    admin_password => 'vagrant123',\
    directory_services_password => 'vagrant123',\
    install_ipa_server => true,\
    ip_address => '192.168.56.35',\
    enable_ip_address => true,\
    enable_hostname => true,\
    manage_host_entry => true,\
    install_epel => true,\
    webui_disable_kerberos => true,\
    webui_enable_proxy => true,\
    webui_force_https => true,\
    idstart => 14341,\
  }"
