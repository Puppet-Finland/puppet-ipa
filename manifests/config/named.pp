#
# @summary Add custom named.conf fragment.
#
# @param basename
#     (string) Basename of the configuration fragment, without the ".conf" at the end. Defaults to $title.
# @param content
#     (string) The value to pass to the File resource's "content" parameter. For example
#     template('profile/templates/tsig-key.erb').
# @param notify_named
#     (boolean) Whether to restart named-pkcs11 on config changes. Defaults to false.
#
define easy_ipa::config::named (
  String  $content,
  String  $basename = $title,
  Boolean $notify_named = false
) {
  include easy_ipa::params
  include easy_ipa::named

  $named_conf_d = $easy_ipa::params::named_conf_d

  $notify = $notify_named ? {
    true    => Service['named-pkcs11'],
    false   => undef,
    default => undef,
  }

  file { "${named_conf_d}/${basename}.conf":
    ensure  => 'file',
    content => $content,
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    require => File[$named_conf_d],
    notify  => $notify,
  }

  file_line { "named-include-${basename}.conf":
    ensure => 'present',
    path   => '/etc/named.conf',
    line   => "include \"${named_conf_d}/${basename}.conf\";",
    after  => '^/* End of IPA-managed part. */$',
    notify => $notify,
  }
}
