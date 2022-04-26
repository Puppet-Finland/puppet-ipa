#!/bin/sh
echo Final provisioning...
export FACTER_is_vagrant='true'

yum -y upgrade

# Recent CentOS images have NetworkManager enabled. As it breaks IPA server's
# /etc/resolv.conf we don't want to use it.
puppet apply -e "service { 'NetworkManager': ensure => 'stopped', enable => false, }"
