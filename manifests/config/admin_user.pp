#
# @summary Manage admin user
#
class easy_ipa::config::admin_user {
  $uid_number = $easy_ipa::idstart
  $home_dir_path = '/home/admin'
  $keytab_path = "${home_dir_path}/admin.keytab"
  $k5login_path = "${home_dir_path}/.k5login"

  # Ensure admin homedir and keytab files.
  file { $home_dir_path:
    ensure  => directory,
    mode    => '0700',
    owner   => $uid_number,
    group   => $uid_number,
    recurse => true,
    require => Exec["server_install_${easy_ipa::ipa_server_fqdn}"],
  }

  file { $k5login_path:
    owner   => $uid_number,
    group   => $uid_number,
    seluser => 'user_u',
  }

  # chown/chmod *after* file is created by kadmin.local
  file { $keytab_path:
    owner => $uid_number,
    group => $uid_number,
    mode  => '0600',
  }

  # Gives admin user the host/fqdn principal.
  k5login { $k5login_path:
    principals => $easy_ipa::master_principals,
    notify     => File[$k5login_path],
    require    => File[$home_dir_path],
  }

  # Set keytab for admin user.
  # kadmin.local must be run as `root` to log to `/var/log/kadmind.log`
  $configure_admin_keytab_cmd = "/usr/sbin/kadmin.local -q \"ktadd -norandkey -k ${keytab_path} admin\" "
  # kvno must be run as the `admin` user to function
  $configure_admin_keytab_cmd_unless = "/sbin/runuser -l admin -c \"/usr/bin/kvno -k ${keytab_path} admin@${easy_ipa::final_realm}\""
  exec { 'configure_admin_keytab':
    command => $configure_admin_keytab_cmd,
    cwd     => $home_dir_path,
    unless  => $configure_admin_keytab_cmd_unless,
    require => File[$home_dir_path],
    notify  => File[$keytab_path],
  }

  $k5start_admin_keytab_cmd = "/sbin/runuser -l admin -c \"/usr/bin/k5start -f ${keytab_path} -U\""
  $k5start_admin_keytab_cmd_unless = "/sbin/runuser -l admin -c /usr/bin/klist | grep -i krbtgt\\/${easy_ipa::final_realm}\\@"
  exec { 'k5start_admin_keytab':
    command => $k5start_admin_keytab_cmd,
    cwd     => $home_dir_path,
    unless  => $k5start_admin_keytab_cmd_unless,
    require => [
      File[$k5login_path],
      File[$keytab_path],
      Cron['k5start_admin'],
    ],
  }

  # Automatically refreshes admin keytab.
  cron { 'k5start_admin':
    command => "/usr/bin/k5start -f ${keytab_path} -U > /dev/null 2>&1",
    user    => 'admin',
    minute  => '*/1',
    require => [
      File[$k5login_path],
      File[$keytab_path],
    ],
  }
}
