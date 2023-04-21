# @summary Manages IPA masters, replicas and clients.
#
# @param manage
#      (boolean) Manage easy_ipa with Puppet. Defaults to true. Setting this to
#                to false is useful when a handful of hosts have unsupported
#                operating systems and you'd rather exclude them from FreeIPA
#                instead of including the others individually. Use this with
#                a separate Hiera level (e.g. $::lsbdistcodename) for maximum
#                convenience.
# @param domain
#      (string) The name of the IPA domain to create or join.
# @param ipa_role
#      (string) What role the node will be. Options are 'master', 'replica', and 'client'.
#
# @param admin_password
#      (string) Password which will be assigned to the IPA account named 'admin'.
#
# @param directory_services_password
#      (string) Password which will be passed into the ipa setup's parameter named "--ds-password".
#
# @param allow_zone_overlap
#      (boolean) if set to true, allow creating of (reverse) zone even if the zone is already
#                resolvable. Using this option is discouraged as it result in later problems with
#                domain name. You may have to use this, though, when migrating existing DNS
#                domains to FreeIPA.
#
# @param no_dnssec_validation
#      (boolean) if set to true, DNSSEC validation is disabled.
#
# @param client_install_ldaputils
#      (boolean) If true, then the ldaputils packages are installed if ipa_role is set to client.
#
# @param configure_dns_server
#      (boolean) If true, then the parameter '--setup-dns' is passed to the IPA server installer.
#                Also, triggers the install of the required dns server packages.
#
# @param configure_replica_ca
#      (boolean) If true, then the parameter '--setup-ca' is passed to the IPA replica installer.
#
# @param configure_ntp
#      (boolean) If false, then the parameter '--no-ntp' is passed to the IPA client and server
#                installers.
#
# @param configure_ssh
#      (boolean) If false, then the parameter '--no-ssh' is passed to the IPA client and server
#                installers.
#
# @param configure_sshd
#      (boolean) If false, then the parameter '--no-sshd' is passed to the IPA client and server
#                installers.
#
# @param custom_dns_forwarders
#      (array[string]) Each element in this array is prefixed with '--forwarder '
#                      and passed to the IPA server installer.
#
# @param domain_join_principal
#      (string) The principal (usually username) used to join a client or replica to the IPA domain.
#
# @param domain_join_password
#      (string) The password for the domain_join_principal.
#
# @param enable_dns_updates
#      (boolean) If true, then the parameter '--enable-dns-updates' is passed to the IPA installer.
#
# @param enable_hostname
#      (boolean) If true, then the parameter '--hostname' is populated with the parameter 'ipa_server_fqdn'
#                and passed to the IPA installer.
#
# @param enable_ip_address
#      (boolean) If true, then the parameter '--ip-address' is populated with the parameter 'ip_address'
#                and passed to the IPA installer.
#
# @param fixed_primary
#      (boolean) If true, then the parameter '--fixed-primary' is passed to the IPA installer.
#
# @param idstart
#      (integer) From the IPA man pages: "The starting user and group id number".
#
# @param gssapi_no_negotiate
#      (pattern) Suppress setting Negotiate headers based on BrowserMatch.
#               Not sending these headers is useful to work around browsers that do not handle them properly (and incorrectly show
#               authentication popups to users). Example: "Windows". Default undef.
#
# @param idmax
#      (integer) From the IPA man pages: "The max value for the IDs range (default: idstart+199999)".
#
# @param install_autofs
#      (boolean) If true, then the autofs packages are installed.
#
# @param install_epel
#      (boolean) If true, then the epel repo is installed. The epel repo is usually required for sssd packages.
#
# @param install_kstart
#      (boolean) If true, then the kstart packages are installed.
#
# @param install_sssdtools
#      (boolean) If true, then the sssdtools packages are installed.
#
# @param install_ipa_client
#      (boolean) If true, then the IPA client packages are installed if the parameter 'ipa_role' is set to 'client'.
#
# @param install_ipa_server
#      (boolean) If true, then the IPA server packages are installed if the parameter 'ipa_role' is not set to 'client'.
#
# @param install_sssd
#      (boolean) If true, then the sssd packages are installed.
#
# @param ip_address
#      (string) IP address to pass to the IPA installer.
#
# @param ipa_server_fqdn
#      (string) Actual fqdn of the IPA server or client.
#
# @param ipa_master_fqdn
#      (string) FQDN of the server to use for a client or replica domain join.
#
# @param manage_host_entry
#      (boolean) If true, then a host entry is created using the parameters 'ipa_server_fqdn' and 'ip_address'.
#
# @param mkhomedir
#      (boolean) If true, then the parameter '--mkhomedir' is passed to the IPA server and client
#      installers.
#
# @param no_ui_redirect
#      (boolean) If true, then the parameter '--no-ui-redirect' is passed to the IPA server installer.
#
# @param realm
#      (string) The name of the IPA realm to create or join.
#
# @param server_install_ldaputils
#      (boolean) If true, then the ldaputils packages are installed if ipa_role is not set to client.
#
# @param webui_disable_kerberos
#       Disable webui kerberos.
#
# @param webui_enable_proxy
#      (boolean) If true, then httpd is configured to act as a reverse proxy for the IPA Web UI. This allows
#                for the Web UI to be accessed from different ports and hostnames than the default.
#
# @param webui_force_https
#      (boolean) If true, then /etc/httpd/conf.d/ipa-rewrite.conf is modified to force all connections to https.
#                This is necessary to allow the WebUI to be accessed behind a reverse proxy when using nonstandard
#                ports.
#
# @param webui_proxy_external_fqdn
#      (string) The public or external FQDN used to access the IPA Web UI behind the reverse proxy.
#
# @param webui_proxy_https_port
#      (integer) The HTTPS port to use for the reverse proxy. Cannot be 443.
#
# @param adjust_login_defs
#      (boolean) Adjust UID_MAX and GID_MAX in login.defs. Without this newer server installers fail. Default false.
#
# TODO: Allow creation of root zone for isolated networks -- https://www.freeipa.org/page/Howto/DNS_in_isolated_networks
# TODO: Class comments.
# TODO: Dependencies and metadata updates.
# TODO: Variable scope and passing.
# TODO: configurable admin username.
#
class easy_ipa (
  Stdlib::Fqdn $domain,
  Enum['client', 'master', 'replica'] $ipa_role,
  Boolean $manage                                  = true,
  Optional[String[8]] $admin_password              = undef,
  Optional[String[8]] $directory_services_password = undef,
  Boolean $allow_zone_overlap                      = false,
  Boolean $no_dnssec_validation                    = false,
  Boolean $client_install_ldaputils                = false,
  Boolean $configure_dns_server                    = true,
  Boolean $configure_replica_ca                    = false,
  Boolean $configure_ntp                           = true,
  Boolean $configure_ssh                           = true,
  Boolean $configure_sshd                          = true,
  Array[String] $custom_dns_forwarders             = [],
  String[1] $domain_join_principal                 = 'admin',
  Optional[String[1]] $domain_join_password        = undef,
  Boolean $enable_dns_updates                      = false,
  Boolean $enable_hostname                         = true,
  Boolean $enable_ip_address                       = false,
  Boolean $fixed_primary                           = false,
  Variant[Pattern,Undef] $gssapi_no_negotiate      = undef,
  Integer[10000] $idstart                          = (fqdn_rand('10737') + 10000),
  Variant[Integer,Undef] $idmax                    = undef,
  Boolean $install_autofs                          = false,
  Boolean $install_epel                            = true,
  Boolean $install_kstart                          = true,
  Boolean $install_sssdtools                       = true,
  Boolean $install_ipa_client                      = true,
  Boolean $install_ipa_server                      = true,
  Boolean $install_sssd                            = true,
  Optional[Stdlib::IP::Address] $ip_address        = undef,
  String $ipa_server_fqdn                          = $facts['networking']['fqdn'],
  Optional[Stdlib::Fqdn] $ipa_master_fqdn          = undef,
  Boolean $manage_host_entry                       = false,
  Boolean $mkhomedir                               = true,
  Boolean $no_ui_redirect                          = false,
  Optional[Stdlib::Fqdn] $realm                    = undef,
  Boolean $server_install_ldaputils                = true,
  Boolean $webui_disable_kerberos                  = false,
  Boolean $webui_enable_proxy                      = false,
  Boolean $webui_force_https                       = false,
  String $webui_proxy_external_fqdn                = 'localhost',
  String $webui_proxy_https_port                   = '8440',
  Boolean $adjust_login_defs                       = false,
) {
  if $manage {
    # Include per-OS parameters and fail on unsupported OS
    include easy_ipa::params

    $final_realm = $realm ? {
      undef   => upcase($domain),
      default => $realm,
    }

    $master_principals = suffix(
      prefix([$ipa_server_fqdn],
        'host/'
      ),
      "@${final_realm}"
    )

    $final_domain_join_password = $domain_join_password ? {
      undef   => $directory_services_password,
      default => $domain_join_password,
    }

    if $ipa_role == 'client' {
      $final_configure_dns_server = false
    } else {
      $final_configure_dns_server = $configure_dns_server
    }

    $opt_no_ssh = $configure_ssh ? {
      true    => '',
      default => '--no-ssh',
    }

    $opt_no_sshd = $configure_sshd ? {
      true    => '',
      default => '--no-sshd',
    }

    if $adjust_login_defs {
      file_line {
        default:
          path    => '/etc/login.defs',
          replace => true,
          ;
        'adjust uid max':
          line  => "UID_MAX\t11999",
          match => '^UID_MAX\s*60000$',
          ;
        'adjust gid max':
          line  => "GID_MAX\t11999",
          match => '^GID_MAX\s*60000$',
          ;
      }
    }

    require easy_ipa::validate_params
    contain easy_ipa::install
  }
}
