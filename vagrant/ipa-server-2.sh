#/bin/sh
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  class { 'resolv_conf':\
    nameservers => ['192.168.56.35'],\
  }"
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  host {'ipa-server-1.vagrant.example.lan':\
    ensure => present,\
    ip => '192.168.56.35',\
  }"
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  class {'::easy_ipa':\
    ipa_role => 'replica',\
    domain => 'vagrant.example.lan',\
    ipa_server_fqdn => 'ipa-server-2.vagrant.example.lan',\
    domain_join_password => 'vagrant123',\
    install_ipa_server => true,\
    ip_address => '192.168.56.36',\
    enable_ip_address => true,\
    enable_hostname => true,\
    manage_host_entry => true,\
    install_epel => true,\
    ipa_master_fqdn => 'ipa-server-1.vagrant.example.lan',\
    idstart => 14341,\
  }"
