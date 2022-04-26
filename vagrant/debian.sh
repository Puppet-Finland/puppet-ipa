#!/bin/sh
echo I am provisioning...
export FACTER_is_vagrant='true'

DEBIAN_FRONTEND=noninteractive
apt-get dist-upgrade -y

# For Debian systems, the freeipa-client package is only available in the backports repository.
# It needs to be enabled manually.
DESCR="$(lsb_release -d | awk '{ print $2}')"
if [ `echo $DESCR|grep Debian` ]; then
  puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e \
    "class { 'apt::backports': }"
fi