# frozen_string_literal: true

Facter.add(:gid_max) do
  setcode do
    lines = File.readlines('/etc/login.defs')
    lines.find { |line| line.start_with?('GID_MAX') }.split[1].strip.to_i
  end
end
