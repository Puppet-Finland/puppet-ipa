#
# @summary Prepare the integrated named-pkcs11 service for local configuration
# fragments.
#
# This is only supposed to work on RHEL/CentOS.
#
class easy_ipa::named {
  include easy_ipa::params

  unless $facts['os']['family'] == 'RedHat' {
    fail('ERROR: class ::easy_ipa::named supports only RedHat/CentOS')
  }

  $named_conf_d = $easy_ipa::params::named_conf_d

  service { 'named-pkcs11':
    require => Class['easy_ipa'],
  }

  file { $named_conf_d:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'named',
    mode    => '0750',
    require => Class['easy_ipa'],
  }
}
