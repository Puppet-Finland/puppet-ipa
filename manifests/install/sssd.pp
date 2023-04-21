#
# @summary Manage sssd install
#
class easy_ipa::install::sssd {
  package { $easy_ipa::params::sssd_package_name:
    ensure => present,
  }
}
