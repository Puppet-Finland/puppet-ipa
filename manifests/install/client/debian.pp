#
# @summary Ensure that home directories get created on Debian and Ubuntu clients.
#
# This code is needed as the --mkhomedir parameter passed to ipa-client-install does
# not configure PAM even though it does install the required packages.
#
# Currently Ubuntu 14.04/16.04 and Debian 8/9 are supported.
#
class easy_ipa::install::client::debian {
  case $facts['os']['distro']['codename'] {
    /^(xenial|stretch|bionic|focal|buster|bullseye|jammy|bookworm)$/: {
      # Ensure that required packages are present even if they do not get pulled
      # in as freeipa-client package dependencies
      stdlib::ensure_packages(['oddjob','oddjob-mkhomedir'], { 'ensure' => 'present' })

      # This should preferably be in a separate Puppet module
      service { 'oddjobd':
        ensure => 'running',
        enable => true,
        name   => 'oddjobd',
      }
      $mkhomedir_line = 'session optional /lib/x86_64-linux-gnu/security/pam_oddjob_mkhomedir.so'
      $notify = Service['oddjobd']
    }
    /^(trusty|jessie)$/: {
      $mkhomedir_line = 'session required pam_mkhomedir.so skel=/etc/skel/ umask=0022'
      $notify = undef
    }
    default: {
      fail('ERROR: unsupported Debian/Ubuntu version!')
    }
  }

  file_line { 'mkhomedir':
    ensure => 'present',
    path   => '/etc/pam.d/common-session',
    line   => $mkhomedir_line,
    after  => '^# end of pam-auth-update config',
    notify => $notify,
  }
}
