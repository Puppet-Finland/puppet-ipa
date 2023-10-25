#
# @summary Prevent havoc on unsupported operating systems.
#
# Traditionally this file would be used to abstract away operating system
# differences. Right now the main purpose is to prevent easy_ipa classes from
# causing havoc (e.g. partial configurations) on unsupported operating systems
# by failing early rather than later.
#
class easy_ipa::params {
  case $facts['os']['family'] {
    'RedHat': {
      $ipa_client_package_name = 'ipa-client'
      $ipa_client_package_ensure = 'present'
      $named_conf_d = '/etc/named/conf.d'
    }
    'Debian': {
      case $facts['os']['distro']['codename'] {
        /(trusty|xenial|bionic|focal|bullseye|jammy)/: {
          $ipa_client_package_ensure = 'present'
        }
        default: {
          fail('ERROR: unsupported operating system')
        }
      }
      $ipa_client_package_name = 'freeipa-client'
    }
    default: {
      fail('ERROR: unsupported operating system!')
    }
  }

  # These package names are the same on RedHat and Debian derivatives
  $ipa_server_package_name = 'ipa-server'
  $kstart_package_name = 'kstart'
  $sssd_package_name = 'sssd-common'
}
