#
# @summary Ensure that home directories get created on Debian and Ubuntu clients.
#
# This code is needed as the --mkhomedir parameter passed to ipa-client-install does
# not configure PAM even though it does install the required packages.
#
class easy_ipa::install::client::debian {
  # Ensure that required packages are present even if they do not get pulled
  # in as freeipa-client package dependencies
  stdlib::ensure_packages(['oddjob','oddjob-mkhomedir'], { 'ensure' => 'present' })

  # This should preferably be in a separate Puppet module
  service { 'oddjobd':
    ensure => 'running',
    enable => true,
    name   => 'oddjobd',
  }
  $arch = $facts['os']['hardware']
  $mkhomedir_line = "session optional /lib/${arch}-linux-gnu/security/pam_oddjob_mkhomedir.so"
  $notify = Service['oddjobd']

  file_line { 'mkhomedir':
    ensure => 'present',
    path   => '/etc/pam.d/common-session',
    line   => $mkhomedir_line,
    after  => '^# end of pam-auth-update config',
    notify => $notify,
  }
}
