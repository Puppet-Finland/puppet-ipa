include cron  # easy_ipa needs cron to be installed

class { 'easy_ipa':
  ipa_role                    => 'master',
  domain                      => 'rspec.example.lan',
  admin_password              => 'rspecrspec123',
  directory_services_password => 'rspecrspec123',
  idstart                     => 70000,
  configure_dns_server        => false,
  configure_ntp               => false,
}
