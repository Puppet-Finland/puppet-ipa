#
# @summary Manage easy_ipa install
#
class easy_ipa::install {
  # Note: sssd.conf handled by ipa-server-install.
  if $easy_ipa::install_sssd {
    contain 'easy_ipa::install::sssd'
  }

  if $easy_ipa::ipa_role == 'master' or $easy_ipa::ipa_role == 'replica' {
    if $easy_ipa::install_ipa_server {
      contain 'easy_ipa::install::server'
    }
  } elsif $easy_ipa::ipa_role == 'client' {
    if $easy_ipa::install_ipa_client {
      contain 'easy_ipa::install::client'
    }
  }
}
