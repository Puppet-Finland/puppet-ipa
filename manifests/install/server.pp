#
class easy_ipa::install::server {

  package{ $::easy_ipa::params::ipa_server_package_name:
    ensure => present,
  }

  package{ $::easy_ipa::params::kstart_package_name:
    ensure => present,
  }

  if $easy_ipa::server_install_ldaputils {
    package { $::easy_ipa::params::ldaputils_package_name:
      ensure => present,
    }
  }

  $server_install_cmd_opts_idstart = "--idstart=${easy_ipa::idstart}"

  $server_install_cmd_opts_idmax = $easy_ipa::idmax ? {
    undef   => '',
    default => "--idmax=${easy_ipa::idmax}"
  }

  if $easy_ipa::allow_zone_overlap {
    $server_install_cmd_opts_zone_overlap = '--allow-zone-overlap'
  } else {
    $server_install_cmd_opts_zone_overlap = ''
  }

  if $easy_ipa::no_dnssec_validation {
    $server_install_cmd_opts_dnssec_validation = '--no-dnssec-validation'
  } else {
    $server_install_cmd_opts_dnssec_validation = ''
  }

  if $easy_ipa::enable_hostname {
    $server_install_cmd_opts_hostname = "--hostname=${easy_ipa::ipa_server_fqdn}"
  } else {
    $server_install_cmd_opts_hostname = ''
  }

  if $easy_ipa::enable_ip_address {
    $server_install_cmd_opts_ip_address = "--ip-address ${easy_ipa::ip_address}"
  } else {
    $server_install_cmd_opts_ip_address = ''
  }

  if $easy_ipa::final_configure_dns_server {
    $server_install_cmd_opts_setup_dns = '--setup-dns'
  } else {
    $server_install_cmd_opts_setup_dns = ''
  }

  if $easy_ipa::configure_replica_ca {
    $server_install_cmd_opts_setup_ca = '--setup-ca'
  } else {
    $server_install_cmd_opts_setup_ca = ''
  }

  if $easy_ipa::configure_ntp {
    $server_install_cmd_opts_no_ntp = ''
  } else {
    $server_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $easy_ipa::final_configure_dns_server {
    if size($easy_ipa::custom_dns_forwarders) > 0 {
      $server_install_cmd_opts_forwarders = join(
        prefix(
          $easy_ipa::custom_dns_forwarders,
          '--forwarder '),
        ' '
      )
    }
    else {
      $server_install_cmd_opts_forwarders = '--no-forwarders'
    }
  }
  else {
    $server_install_cmd_opts_forwarders = ''
  }

  if $easy_ipa::no_ui_redirect {
    $server_install_cmd_opts_no_ui_redirect = '--no-ui-redirect'
  } else {
    $server_install_cmd_opts_no_ui_redirect = ''
  }

  if $easy_ipa::mkhomedir {
    $server_install_cmd_opts_mkhomedir = '--mkhomedir'
  } else {
    $server_install_cmd_opts_mkhomedir = ''
  }

  if $easy_ipa::ipa_role == 'master' {
    contain 'easy_ipa::install::server::master'
    Class['easy_ipa::install::server::master']
    -> Class['easy_ipa::config::webui']
  } elsif $easy_ipa::ipa_role == 'replica' {
    contain 'easy_ipa::install::server::replica'
    Class['easy_ipa::install::server::replica']
    -> Class['easy_ipa::config::webui']
  }

  ensure_resource (
    'service',
    'httpd',
    {ensure => 'running'},
  )

  contain 'easy_ipa::config::webui'

  service { 'ipa':
    ensure  => 'running',
    enable  => true,
    require => Exec["server_install_${easy_ipa::ipa_server_fqdn}"],
  }

  if $easy_ipa::install_sssd {
    service { 'sssd':
      ensure  => 'running',
      enable  => true,
      require => Package[$::easy_ipa::params::sssd_package_name],
    }
  }

  easy_ipa::helpers::flushcache { "server_${easy_ipa::ipa_server_fqdn}": }
  contain easy_ipa::config::admin_user

}
