# Validates input configs from init.pp.
# @api private
class easy_ipa::validate_params {
  assert_private()

  if $easy_ipa::manage_host_entry {
    unless $easy_ipa::ip_address {
      fail('When using the parameter manage_host_entry, the parameter ip_address is mandatory.')
    }
  }

  if $easy_ipa::idmax and $easy_ipa::idmax < $easy_ipa::idstart {
    fail('Parameter "idmax" must be an integer greater than parameter "idstart".')
  }

  if $easy_ipa::ipa_role != 'master' { # if replica or client
    unless $easy_ipa::domain_join_password {
      fail("When creating a ${easy_ipa::ipa_role} the parameter named domain_join_password cannot be empty.")
    }
    unless $easy_ipa::ipa_master_fqdn {
      fail("When creating a ${easy_ipa::ipa_role} the parameter named ipa_master_fqdn cannot be empty.")
    }
  }
}
