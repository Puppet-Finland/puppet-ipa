# frozen_string_literal: true

require 'spec_helper'

describe 'easy_ipa', type: :class do
  context 'on Windows' do
    let(:facts) do
      { os: { family: 'Windows' } }
    end
    let(:params) do
      {
        ipa_role: 'master',
        domain:   'rspec.example.lan',
      }
    end

    it { is_expected.to raise_error(Puppet::Error, %r{ERROR: unsupported operating system}) }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          networking: {
            fqdn: 'ipa.rpsec.example.lan',
          }
        )
      end

      context 'as bad_val role' do
        let(:params) do
          {
            ipa_role: 'bad_val',
            domain: 'rspec.example.lan',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.escape("Enum['client', 'master', 'replica']"))) }
      end

      context 'as master' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            admin_password:              'rspecrspec123',
            directory_services_password: 'rspecrspec123',
          }
        end

        context 'with defaults' do
          it { is_expected.to contain_class('easy_ipa::install') }
          it { is_expected.to contain_class('easy_ipa::install::server') }
          it { is_expected.to contain_class('easy_ipa::install::sssd') }
          it { is_expected.to contain_class('easy_ipa::install::server::master') }
          it { is_expected.to contain_class('easy_ipa::config::webui') }
          it { is_expected.to contain_class('easy_ipa::validate_params') }

          it { is_expected.not_to contain_class('easy_ipa::install::autofs') }
          it { is_expected.not_to contain_class('easy_ipa::install::server::replica') }
          it { is_expected.not_to contain_class('easy_ipa::install::client') }

          it { is_expected.to contain_package('ipa-server-dns') }
          it { is_expected.to contain_package('bind-dyndb-ldap') }
          it { is_expected.to contain_package('kstart') }
          it { is_expected.to contain_package('ipa-server') }
          it { is_expected.to contain_package('sssd-common') }

          it { is_expected.not_to contain_package('ipa-client') }

          case facts[:os]['family']
          when 'RedHat'
            it { is_expected.to contain_package('epel-release') }
            it { is_expected.to contain_package('openldap-clients') }
          when 'Debian'
            it { is_expected.to contain_package('ldap-utils') }
          end
        end

        context 'with idmax' do
          let(:params) do
            super().merge(idstart: 10_000,
                          idmax:   20_000)
          end

          it do
            is_expected.to contain_exec('server_install_ipa.rpsec.example.lan').with(
              logoutput: false
            ).
              with_command(%r{--idstart=10000}).
              with_command(%r{--idmax=20000})
          end
        end

        context 'without idmax' do
          let(:params) do
            super().merge(idstart: 10_000)
          end

          it do
            is_expected.to contain_exec('server_install_ipa.rpsec.example.lan').with(
              logoutput: false
            ).with_command(%r{--idstart=10000})
            is_expected.not_to contain_exec('server_install_ipa.rpsec.example.lan').with_command(%r{--idmax})
          end
        end

        context 'configure_ssh' do
          context 'true' do
            let(:params) do
              super().merge(configure_ssh: true)
            end

            it { is_expected.not_to contain_exec('server_install_ipa.rpsec.example.lan').with_command(%r{--no-ssh(?!d)}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_ssh: false)
            end

            it {
              is_expected.to contain_exec('server_install_ipa.rpsec.example.lan').with(
                logoutput: false
              ).with_command(%r{--no-ssh(?!d)})
            }
          end
        end

        context 'configure_sshd' do
          context 'true' do
            let(:params) do
              super().merge(configure_sshd: true)
            end

            it { is_expected.not_to contain_exec('server_install_ipa.rpsec.example.lan').with_command(%r{--no-sshd}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_sshd: false)
            end

            it {
              is_expected.to contain_exec('server_install_ipa.rpsec.example.lan').with(
                logoutput: false
              ).with_command(%r{--no-sshd})
            }
          end
        end

        context 'with idstart out of range' do
          let(:params) do
            super().merge(idstart: 100)
          end

          it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.quote('expects an Integer[10000]'))) }
        end

        context 'with idstart greater than idmax' do
          let(:params) do
            super().merge(idstart: 44_444,
                          idmax:   33_333)
          end

          it { is_expected.to raise_error(Puppet::Error, %r{"idmax" must be an integer greater than parameter "idstart"}) }
        end

        context 'with manage_host_entry but not ip_address' do
          let(:params) do
            super().merge(manage_host_entry: true)
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter ip_address is mandatory}) }
        end

        context 'without admin_password' do
          let(:params) do
            super().merge(admin_password: nil)
          end

          it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.quote('expects a value of type Undef or String[8]'))) }
        end

        context 'without directory_services_password' do
          let(:params) do
            super().merge(directory_services_password: nil)
          end

          it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.quote('expects a value of type Undef or String[8]'))) }
        end

        context 'with bad ip_address' do
          let(:params) do
            super().merge(ip_address: 'not_an_ip')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{expects a.*Stdlib::IP::Address}) }
        end

        context 'with bad domain' do
          let(:params) do
            super().merge(domain: 'not_a_domain')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Fqdn}) }
        end

        context 'with bad realm' do
          let(:params) do
            super().merge(realm: 'not_a_realm')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{a match for Stdlib::Fqdn}) }
        end
      end

      context 'as replica' do
        let(:params) do
          {
            ipa_role: 'replica',
            domain: 'rspec.example.lan',
            ipa_master_fqdn: 'ipa-server-1.rspec.example.lan',
            domain_join_password: 'rspecrspec123',
          }
        end

        context 'with defaults' do
          it { is_expected.to contain_class('easy_ipa::install') }
          it { is_expected.to contain_class('easy_ipa::install::server') }
          it { is_expected.to contain_class('easy_ipa::install::sssd') }
          it { is_expected.to contain_class('easy_ipa::install::server::replica') }
          it { is_expected.to contain_class('easy_ipa::config::webui') }
          it { is_expected.to contain_class('easy_ipa::validate_params') }

          it { is_expected.not_to contain_class('easy_ipa::install::autofs') }
          it { is_expected.not_to contain_class('easy_ipa::install::server::master') }
          it { is_expected.not_to contain_class('easy_ipa::install::client') }

          it { is_expected.to contain_package('ipa-server-dns') }
          it { is_expected.to contain_package('bind-dyndb-ldap') }
          it { is_expected.to contain_package('kstart') }
          it { is_expected.to contain_package('ipa-server') }
          it { is_expected.to contain_package('sssd-common') }

          it { is_expected.not_to contain_package('ipa-client') }

          case facts[:os]['family']
          when 'RedHat'
            it { is_expected.to contain_package('epel-release') }
            it { is_expected.to contain_package('openldap-clients') }
          when 'Debian'
            it { is_expected.to contain_package('ldap-utils') }
          end
        end

        context 'configure_ssh' do
          context 'true' do
            let(:params) do
              super().merge(configure_ssh: true)
            end

            it { is_expected.not_to contain_exec('server_install_ipa.rpsec.example.lan').with_command(%r{--no-ssh(?!d)}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_ssh: false)
            end

            it {
              is_expected.to contain_exec('server_install_ipa.rpsec.example.lan').with(
                logoutput: false
              ).with_command(%r{--no-ssh(?!d)})
            }
          end
        end

        context 'configure_sshd' do
          context 'true' do
            let(:params) do
              super().merge(configure_sshd: true)
            end

            it { is_expected.not_to contain_exec('server_install_ipa.rpsec.example.lan').with_command(%r{--no-sshd}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_sshd: false)
            end

            it {
              is_expected.to contain_exec('server_install_ipa.rpsec.example.lan').with(
                logoutput: false
              ).with_command(%r{--no-sshd})
            }
          end
        end

        context 'missing ipa_master_fqdn' do
          let(:params) do
            super().reject { |k| k == :ipa_master_fqdn }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn cannot be empty}) }
        end

        context 'with bad ipa_master_fqdn' do
          let(:params) do
            super().merge(ipa_master_fqdn: 'not_an_fqdn')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Fqdn}) }
        end

        context 'missing domain_join_password' do
          let(:params) do
            super().reject { |k| k == :domain_join_password }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{domain_join_password cannot be empty}) }
        end
      end

      context 'as client' do
        let(:params) do
          {
            ipa_role: 'client',
            domain: 'rspec.example.lan',
            ipa_master_fqdn: 'ipa-server-1.rspec.example.lan',
            domain_join_password: 'rspecrspec123',
          }
        end

        context 'with defaults' do
          it { is_expected.to contain_class('easy_ipa::install') }
          it { is_expected.to contain_class('easy_ipa::install::sssd') }
          it { is_expected.to contain_class('easy_ipa::install::client') }
          it { is_expected.to contain_class('easy_ipa::validate_params') }

          it { is_expected.not_to contain_class('easy_ipa::install::autofs') }
          it { is_expected.not_to contain_class('easy_ipa::install::server') }
          it { is_expected.not_to contain_class('easy_ipa::install::server::master') }
          it { is_expected.not_to contain_class('easy_ipa::install::server::replica') }
          it { is_expected.not_to contain_class('easy_ipa::config::webui') }

          it { is_expected.to contain_package('ipa-client').that_comes_before('Exec[client_install_ipa.rpsec.example.lan]') }
          it { is_expected.to contain_package('sssd-common') }
          it { is_expected.to contain_package('kstart') }
          it { is_expected.not_to contain_package('ipa-server-dns') }
          it { is_expected.not_to contain_package('bind-dyndb-ldap') }
          it { is_expected.not_to contain_package('ipa-server') }

          case facts[:os]['family']
          when 'RedHat'
            it { is_expected.to contain_package('epel-release') }
            it { is_expected.not_to contain_package('openldap-clients') }
          when 'Debian'
            it { is_expected.not_to contain_package('ldap-utils') }
          end
        end

        context 'configure_ssh' do
          context 'true' do
            let(:params) do
              super().merge(configure_ssh: true)
            end

            it { is_expected.not_to contain_exec('client_install_ipa.rpsec.example.lan').with_command(%r{--no-ssh(?!d)}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_ssh: false)
            end

            it {
              is_expected.to contain_exec('client_install_ipa.rpsec.example.lan').with(
                logoutput: false
              ).with_command(%r{--no-ssh(?!d)})
            }
          end
        end

        context 'configure_sshd' do
          context 'true' do
            let(:params) do
              super().merge(configure_sshd: true)
            end

            it { is_expected.not_to contain_exec('client_install_ipa.rpsec.example.lan').with_command(%r{--no-sshd}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_sshd: false)
            end

            it {
              is_expected.to contain_exec('client_install_ipa.rpsec.example.lan').with(
                logoutput: false
              ).with_command(%r{--no-sshd})
            }
          end
        end

        context 'missing ipa_master_fqdn' do
          let(:params) do
            super().reject { |k| k == :ipa_master_fqdn }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn cannot be empty}) }
        end

        context 'missing domain_join_password' do
          let(:params) do
            super().reject { |k| k == :domain_join_password }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter named domain_join_password cannot be empty}) }
        end
      end
    end
  end
end
