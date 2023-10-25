# frozen_string_literal: true

configure_beaker(modules: :metadata) do |host|
  on host, 'sysctl -w net.ipv6.conf.lo.disable_ipv6=0'
  # disable sticky bit owner enforcement for ipa 4.6/EL7
  # https://bugzilla.redhat.com/show_bug.cgi?id=1677027
  # https://pagure.io/freeipa/c/87496d647706462fa8a10bbea5637104153146b2
  on host, 'sysctl -w fs.protected_regular=0'
  # https://cstan.io/?p=12175&lang=en
  on host, 'yum update -y'
  install_puppet_module_via_pmt_on(host, 'puppet/cron')
  install_puppet_module_via_pmt_on(host, 'puppet/epel')
end
