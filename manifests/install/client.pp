#
class easy_ipa::install::client {

  package{ 'ipa-client':
    ensure => $::easy_ipa::params::ipa_client_package_ensure,
    name   => $::easy_ipa::params::ipa_client_package_name,
  }

  package{ $::easy_ipa::params::kstart_package_name:
    ensure => present,
  }

  if $easy_ipa::client_install_ldaputils {
    package { $::easy_ipa::params::ldaputils_package_name:
      ensure => present,
    }
  }

  if $easy_ipa::mkhomedir {
    $client_install_cmd_opts_mkhomedir = '--mkhomedir'
  } else {
    $client_install_cmd_opts_mkhomedir = ''
  }

  if $easy_ipa::fixed_primary {
    $client_install_cmd_opts_fixed_primary = '--fixed-primary'
  } else {
    $client_install_cmd_opts_fixed_primary = ''
  }

  if $easy_ipa::configure_ntp {
    $client_install_cmd_opts_no_ntp = ''
  } else {
    $client_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $easy_ipa::enable_dns_updates {
    $client_install_cmd_opts_dns_updates = "--enable-dns-updates"
  } else {
    $client_install_cmd_opts_dns_updates = ''
  }

  if $easy_ipa::enable_hostname {
    $client_install_cmd_opts_hostname = "--hostname=${::fqdn}"
  } else {
    $client_install_cmd_opts_hostname = ''
  }

  if $facts['ipa_force_join'] {
    $client_install_cmd_opts_force_join= '--force-join'
  } else {
    $client_install_cmd_opts_force_join = ''
  }

    $client_install_cmd = "\
/usr/sbin/ipa-client-install \
  --server=${easy_ipa::ipa_master_fqdn} \
  --realm=${easy_ipa::final_realm} \
  --domain=${easy_ipa::domain} \
  --principal='${easy_ipa::final_domain_join_principal}' \
  --password='${easy_ipa::final_domain_join_password}' \
  ${client_install_cmd_opts_dns_updates} \
  ${client_install_cmd_opts_hostname} \
  ${client_install_cmd_opts_mkhomedir} \
  ${client_install_cmd_opts_fixed_primary} \
  ${client_install_cmd_opts_no_ntp} \
  ${client_install_cmd_opts_force_join} \
  ${easy_ipa::opt_no_ssh} \
  ${easy_ipa::opt_no_sshd} \
  --unattended"

  # Some platforms require "manual" setup as they don't have the freeipa-client
  # package.
  #
  if $::easy_ipa::params::ipa_client_package_ensure == 'present' {
    exec { "client_install_${::fqdn}":
      command   => $client_install_cmd,
      timeout   => 0,
      unless    => "cat /etc/ipa/default.conf | grep -i \"${easy_ipa::domain}\"",
      creates   => '/etc/ipa/default.conf',
      logoutput => 'on_failure',
      before    => Service['sssd'],
      provider  => 'shell',
    }
  } else {
    include ::easy_ipa::install::client::manual
  }

  if $facts['os']['family'] == 'Debian' and $::easy_ipa::mkhomedir {
    include ::easy_ipa::install::client::debian
  }

  if $easy_ipa::install_sssd {
    service { 'sssd':
      ensure  => 'running',
      enable  => true,
      require => Package[$::easy_ipa::params::sssd_package_name],
    }
  }
}
