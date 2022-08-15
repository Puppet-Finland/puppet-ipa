# @api private
class easy_ipa::install::server::redhat {
  assert_private()

  if versioncmp(fact('os.release.major'), '8') == 0 {
    package { 'idm':
      ensure   => 'DL1',
      provider => 'dnfmodule',
    }
  }
}
