#!/bin/sh
# This is a heavily stripped down version of puppet-puppetmaster/vagrant/prepare.sh
#
# Gist based on commit 9a429d77f11aa6d of terraform-aws_instance_wrapper

# Exit on any error
set -e

# Default settings
HOST_NAME="false"
PUPPET_ENV="production"
START_AGENT="false"

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin

CWD=`pwd`

set_hostname() {
    hostnamectl set-hostname $1
}

detect_osfamily() {
    if [ -f /etc/redhat-release ]; then
        OSFAMILY='redhat'
        RELEASE=$(cat /etc/redhat-release)
	      if [ "`echo $RELEASE | grep -E 7\.[0-9]+`" ]; then
            REDHAT_VERSION="7"
            REDHAT_RELEASE="el-7"
	      elif [ "`echo $RELEASE | grep -E 8\.[0-9]+`" ]; then
            REDHAT_VERSION="8"
            REDHAT_RELEASE="el-8"
        else
            echo "Unsupported Redhat/Centos/Fedora version."
            exit 1
        fi
    elif [ "`lsb_release -d | grep -E '(Ubuntu|Debian)'`" ]; then
        OSFAMILY='debian'
        DESCR="$(lsb_release -d | awk '{ print $2}')"
        if [ `echo $DESCR|grep Ubuntu` ]; then
            UBUNTU_VERSION="$(lsb_release -c | awk '{ print $2}')"
            # TODO: Remove when Puppet makes a jammy release
            if [ "$UBUNTU_VERSION" = "jammy" ]; then
                UBUNTU_VERSION="focal"
            fi
        elif [ `echo $DESCR|grep Debian` ]; then
            DEBIAN_VERSION="$(lsb_release -c | awk '{ print $2}')"
        else
            echo "Unsupported Debian family operating system. Supported are Debian and Ubuntu"
            exit 1
        fi
    else
        echo "ERROR: unsupported osfamily. Supported are Debian and RedHat"
        exit 1
    fi
}

install_dependencies() {
    if [ "${REDHAT_VERSION}" = "30" ]; then
        dnf -y install libxcrypt-compat
    fi
}

setup_puppet() {
    if [ -x /opt/puppetlabs/bin/puppet ]; then
        true
    else
        if [ $REDHAT_RELEASE ]; then
            RELEASE_URL="https://yum.puppetlabs.com/puppet6/puppet6-release-${REDHAT_RELEASE}.noarch.rpm"
            rpm -hiv "${RELEASE_URL}" || (c=$?; echo "Failed to install ${RELEASE_URL}"; (exit $c))
            yum -y install puppet-agent || (c=$?; echo "Failed to install puppet agent"; (exit $c))
            if systemctl list-unit-files --type=service | grep firewalld; then
                systemctl stop firewalld
                systemctl disable firewalld
                systemctl mask firewalld
            fi
        else
            if [ $UBUNTU_VERSION ]; then
                APT_URL="https://apt.puppetlabs.com/puppet6-release-${UBUNTU_VERSION}.deb"
            fi
            if [ $DEBIAN_VERSION ]; then
                APT_URL="https://apt.puppetlabs.com/puppet6-release-${DEBIAN_VERSION}.deb"
            fi
            # https://serverfault.com/questions/500764/dpkg-reconfigure-unable-to-re-open-stdin-no-file-or-directory
            export DEBIAN_FRONTEND=noninteractive
            FILE="$(mktemp -d)/puppet-release.db"
            wget "${APT_URL}" -qO $FILE || (c=$?; echo "Failed to retrieve ${APT_URL}"; (exit $c))
            # The apt-daily and apt-daily-upgrade services have a nasty habit of
            # launching immediately on boot. This prevents the installer from updating
            # the package caches itself, which causes some packages to be missing and
            # subsequently causing puppetmaster-installer to fail. So, wait for those
            # two services to run before attempting to run the installer. There are
            # ways to use systemd-run to accomplish this rather nicely:
            #
            # https://unix.stackexchange.com/questions/315502/how-to-disable-apt-daily-service-on-ubuntu-cloud-vm-image
            #
            # However, that approach fails on Ubuntu 16.04 (and earlier) as well as
            # Debian 9, so it is not practical. This approach uses a simple polling
            # method and built-in tools.
            APT_READY=no
            while [ "$APT_READY" = "no" ]; do
                # This checks three things to prevent package installation failures, in this order:
                #
                # 1) Is "apt-get update" running?
                # 2) Is "apt-get install" running?
                # 3) Is "dpkg" running?
                #
                # The "apt-get install" commands locks dpkg as well, but the last check ensures that dpkg running outside of apt does not cause havoc.
                #
                fuser -s /var/lib/apt/lists/lock || fuser -s /var/cache/apt/archives/lock || fuser -s /var/lib/dpkg/lock || APT_READY=yes
                sleep 1
            done

            dpkg --install $FILE; rm $FILE; apt-get update || (c=$?; echo "Failed to install from ${FILE}"; (exit $c))
            apt-get -y install puppet-agent || (c=$?; echo "Failed to install puppet agent"; (exit $c))
        fi
    fi
}

set_puppet_agent_environment() {
    puppet config set --section agent environment $1
}

run_puppet_agent() {
    systemctl enable puppet
    systemctl start puppet
}

if [ "${HOST_NAME}" != "false" ]; then
    set_hostname $HOST_NAME
fi
detect_osfamily
install_dependencies
setup_puppet
set_puppet_agent_environment $PUPPET_ENV
if [ "${START_AGENT}" = "true" ]; then
    run_puppet_agent
fi
