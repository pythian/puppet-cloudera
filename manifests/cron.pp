class cloudera::cron ()
inherits cloudera::params {
  cron::hourly { 'mysqlbackup_hourly':
    minute      => '00',
    user        => 'root',
    command     => '/usr/local/bin/mysql_backup_restore.sh backup',
    description => 'Mysql backup',
  }
}
