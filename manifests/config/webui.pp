# Configures port and redirect overrides for the IPA server web UI.
class easy_ipa::config::webui {

  if $easy_ipa::webui_enable_proxy {
    #ref: https://www.redhat.com/archives/freeipa-users/2016-June/msg00128.html
    $proxy_server_internal_fqdn = $easy_ipa::ipa_server_fqdn
    $proxy_server_external_fqdn = $easy_ipa::webui_proxy_external_fqdn
    $proxy_https_port = $easy_ipa::webui_proxy_https_port

    $proxy_server_external_fqdn_and_port = "${proxy_server_external_fqdn}:${proxy_https_port}"

    $proxy_internal_uri = "https://${proxy_server_internal_fqdn}"
    $proxy_external_uri = "https://${proxy_server_external_fqdn}:${proxy_https_port}"
    $proxy_server_name = "https://${easy_ipa::ipa_server_fqdn}:${proxy_https_port}"
    $proxy_referrer_regex = regsubst(
      $proxy_external_uri,
      '\.',
      '\.',
      'G',
    )

    exec { 'semanage-port-http_port_t':
        command => "semanage port -a -t http_port_t -p tcp ${proxy_https_port}",
        unless  => "semanage port -l|grep -E \"^http_port_t.*tcp.*${proxy_https_port}\"",
        path    => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    }

    file_line { 'webui_additional_https_port_listener':
      ensure => present,
      path   => '/etc/httpd/conf.d/nss.conf',
      line   => "Listen ${proxy_https_port}",
      after  => 'Listen\ 443',
      notify => Service['httpd'],
    }

    file { '/etc/httpd/conf.d/ipa-rewrite.conf':
      ensure  => present,
      replace => true,
      content => template('easy_ipa/ipa-rewrite.conf.erb'),
      notify  => Service['httpd'],
    }

    file { '/etc/httpd/conf.d/ipa-webui-proxy.conf':
      ensure  => present,
      replace => true,
      content => template('easy_ipa/ipa-webui-proxy.conf.erb'),
      notify  => Service['httpd'],
      require => Exec['semanage-port-http_port_t'],
    }
  }

  if $easy_ipa::gssapi_no_negotiate {
    file_line{'disable_negotiate_headers':
      ensure => present,
      path   => '/etc/httpd/conf.d/ipa.conf',
      line   => "  BrowserMatch \"${easy_ipa::gssapi_no_negotiate}\" gssapi-no-negotiate",
      notify => Service['httpd'],
      after  => '^AuthType.*GSSAPI$',
    }
  }
}
