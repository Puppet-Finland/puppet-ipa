#
# @summary Update host keys for a domain-joined node in FreeIPA to match real host
#   keys.
# 
# Useful when real keys and keys in IPA device account have gone
#   out of sync, e.g. due to rebuilding the server from a snapshot.
#
#   This gets a kerberos ticket from the IPA server first, then gathers
#   the SSH keys from IPA clients from their SSH facts, then runs appropriate
#   "ipa host-mod" commands for each IPA client on the IPA server.
#
#   Note that it is assumed that the IPA client host name is equal to the $::fqdn
#   fact.
#
# @param ipa_clients
#   One of more IPA clients whose host keys to puload
# @param ipa_server
#   A host which has the "ipa" tools installed. Not necessarily an IPA server.
# @param ipa_user
#   An IPA user with permission to run "ipa host-mod".
# @param ipa_password
#   IPA user's password
# @param noop
#   If true then only imulate what would be done
#
plan easy_ipa::update_host_keys
(
  TargetSpec $ipa_clients,
  TargetSpec $ipa_server,
  String     $ipa_user,
  String     $ipa_password,
  Boolean    $noop = true,
) {
  # Part #1: get a kerberos ticket on the IPA server
  if $noop {
    out::message('No-op: get kerberos ticket on the IPA server')
  } else {
    out::message('Get kerberos ticket on the IPA server')
    $kinit_resultset = run_command("sh -c \'echo ${ipa_password}|kinit -V ${ipa_user} 2>&1\'", $ipa_server, '_catch_errors' => true)
    $kinit_stdout = $kinit_resultset.first.value['stdout']
    out::message($kinit_stdout)
  }

  # Part 2: collect SSH facts from IPA clients
  out::message('Gathering facts from the IPA clients')
  run_plan('facts', 'targets' => $ipa_clients)

  get_targets($ipa_clients).each |$ipa_client| {
    $ed25519 = $ipa_client.facts['ssh']['ed25519']['key']
    $ecdsa = $ipa_client.facts['ssh']['ecdsa']['key']
    $rsa = $ipa_client.facts['ssh']['rsa']['key']
    $dsa = $ipa_client.facts['ssh']['dsa']['key']

    $ipa_host_mod_cmd = "ipa host-mod ${ipa_client.facts['fqdn']} --sshpubkey=\"${ed25519}\" --sshpubkey=\"${ecdsa}\" --sshpubkey=\"${rsa}\" --sshpubkey=\"${dsa}\" --updatedns"  # lint:ignore:140chars

    if $noop {
      out::message("No-op: would run \"${ipa_host_mod_cmd}\" on IPA server")
    } else {
      # lint:ignore:manifest_whitespace_opening_bracket_before  # lint:ignore:140chars 
      $ipa_host_mod_resultset = run_command($ipa_host_mod_cmd, $ipa_server, '_catch_errors' => true) ['stdout','stderr'].each |$output| {
        # lint:endignore
        out::message($ipa_host_mod_resultset.first.value[$output])
      }
    }
  }
}
