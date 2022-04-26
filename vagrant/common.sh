#!/bin/sh
export PATH=$PATH:/opt/puppetlabs/bin
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-concat
puppet module install crayfishx-firewalld
puppet module install puppet-selinux
puppet module install puppet-systemd
puppet module install saz-resolv_conf --version 5.0.0 --ignore-dependencies
puppet module install puppetlabs-apt --ignore-dependencies
puppet module install puppetlabs-firewall
puppet module install puppetlabs-k5login_core
if [ -d /tmp/modules/easy_ipa ]; then rm -rf /tmp/modules/easy_ipa; fi
mkdir -p /tmp/modules/easy_ipa
cp -r /vagrant/* /tmp/modules/easy_ipa
