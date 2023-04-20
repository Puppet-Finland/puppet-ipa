#
# @summary Define easy_ipa::backup
#
# Backup FreeIPA from cron
#
# @param title
#   The resource title is used as part of the the name for the cronjob.
# @param type
#   Backup type. Either 'full' (offline) or 'data' (online).
# @param timestamp
#   Keep the default timestamp in the backup directory. Valid values are true
#   (default) and false. Set this to false if you have and external system (e.g.
#   bacula) that fetches the backups periodically and handles versioning on its
#   own.
# @param monthday
#   Standard parameter for the cron resource.
# @param weekday
#   Standard parameter for the cron resource.
# @param hour
#   Standard parameter for the cron resource.
# @param minute
#   Standard parameter for the cron resource
# @param email
#   Email to send cron notifications to. Defaults to $::servermonitor.
#
define easy_ipa::backup (
  Enum['full','data']                                                 $type,
  Variant[Array[String], Array[Integer[0-23]], String, Integer[0-23]] $hour,
  Variant[Array[String], Array[Integer[0-59]], String, Integer[0-59]] $minute,
  Variant[Array[String], Array[Integer[0-7]],  String, Integer[0-7]]  $weekday = '*',
  Variant[Array[String], Array[Integer[1-31]], String, Integer[1-31]] $monthday = '*',
  String                                                              $email = $facts['servermonitor'],
  Boolean                                                             $timestamp = true,
) {
  $script = 'ipa-backup-wrapper.sh'
  $command = "${script} ${type} ${timestamp}"

  ensure_resource('file', $script, {
      'ensure'  => 'present',
      'name'    => "/usr/local/bin/${script}",
      'content' => template("easy_ipa/${script}.erb"),
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0755',
  })

  cron { "ipa-${title}-backup":
    user        => 'root',
    command     => $command,
    monthday    => $monthday,
    weekday     => $weekday,
    hour        => $hour,
    minute      => $minute,
    environment => ['PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin', "MAILTO=${email}"],
    require     => File[$script],
  }
}
