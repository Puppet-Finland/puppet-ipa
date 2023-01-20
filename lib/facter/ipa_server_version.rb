# frozen_string_literal: true

Facter.add(:ipa_server_version) do
  setcode do
    family = Facter.value('osfamily')
    case family
    when 'RedHat'
      Facter::Core::Execution.execute('/bin/rpm -q ipa-server --queryformat "%{VERSION}"')
    when 'Debian'
      Facter::Core::Execution.execute('/usr/bin/dpkg-query -W -f="${Version}" ipa-server')
    end
  end
end
