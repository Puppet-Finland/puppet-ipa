#
# @summary Manage autofs
#
class easy_ipa::install::autofs {
  package { $easy_ipa::params::autofs_package_name:
    ensure => present,
  }

  service { 'autofs':
    ensure => 'running',
    enable => true,
  }
}
