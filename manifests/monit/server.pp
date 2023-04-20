#
# @summary Manage easy_ipa::monit::server
#
# Monitor FreeIPA server processes using monit
#
# This class depends on puppetfinland-monit module
#
# @param email
#   Email address to send notifications to. Defaults to top-scope variable
#   $::servermonitor.
#
class easy_ipa::monit::server (
  String $email = $facts['servermonitor'],
) {
  @monit::fragment { 'ipa.monit':
    ensure     => 'present',
    modulename => 'easy_ipa',
    basename   => 'ipa',
    tag        => 'default',
  }

  @file { 'ipa.sh':
    ensure  => 'file',
    name    => "${facts['monit::params::fragment_dir']}/ipa.sh",
    content => template('easy_ipa/ipa.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    notify  => Class['monit::service'],
    require => Class['monit'],
    tag     => 'monit',
  }
}
