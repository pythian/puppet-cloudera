# == Class: cloudera::cluster
class cloudera::cluster (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $server_leader     = $cloudera::params::server_leader,
  $cdh_cluster_role  = $cloudera::params::cdh_cluster_role,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
  $cdh_cluster_multi_az = $cloudera::params::cdh_cluster_multi_az,
  $cdh_cluster_major_release = $cdh_cluster_major_release,
  $cdh_cluster_minor_release = $cdh_cluster_minor_release,
  $cdh_cluster_parcels_release = $cdh_cluster_parcels_release,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
  $cm_db_local       = $cloudera::params::cm_db_local,
  $cm_db_rds         = $cloudera::params::cm_db_rds,
  $cm_db_type        = $cloudera::params::cm_db_type,
  $cm_db_host        = $cloudera::params::cm_db_host,
  $cm_db_port        = $cloudera::params::cm_db_port,
  $cm_db_user        = $cloudera::params::cm_db_user,
  $cm_db_masteruser  = $cloudera::params::cm_db_masteruser,
  $cm_db_pass        = $cloudera::params::cm_db_pass,
  $cm_db_masterpass  = $cloudera::params::cm_db_masterpass,
) inherits cloudera::params {
  class { '::cloudera::api': }
  debug("DB Local: $cm_db_local")
  debug("RDS: $cm_db_rds")
  debug("Type: $cm_db_type")
  if $cdh_cluster_role == 'CMSERVER' {
    if $cdh_cluster_ha == 0 {
      file {'/nfs':
        ensure => directory,
      }
      file {'/nfs/namenode':
        ensure => directory,
        require => File['/nfs'],
      }
      class { '::nfs':
        server_enabled => true,
        require => File['/nfs/namenode'],
      }
      nfs::server::export{'/nfs/namenode':
        ensure  => 'mounted',
        clients => '*(rw,async,no_root_squash) localhost(rw)',
        require => Class['::nfs'],
      }
      if $cm_db_local == 0 {
        class { '::cloudera':
          cm_server_host => $cm_api_host,
          install_cmserver => true,
          use_parcels => true,
          require => Service['nfs-kernel-server'],
        }
      } else {
        if $cm_db_rds == 0 {
          if $cm_db_type == "mysql" {
            class { 'mysql::server': root_password => $cm_db_master_password, remove_default_accounts => true, require => Service['nfs-kernel-server'], }
            mysql_user{ "$cm_db_user@%": ensure => present, password_hash => mysql_password("$cm_db_pass"), require => Class['::mysql::server'], }
            mysql_grant{ "$cm_db_user@%/$cm_db_name.*": user => "$cm_db_user@%", table => "$cm_db_name.*", privileges => ['ALL'], require => Class["mysql_user[$cm_db_user@%]"], }
          }
        }
        class { '::cloudera':
          cm_server_host => $cm_api_host,
          install_cmserver => true,
          use_parcels => true,
          db_type => $cm_db_type,
          db_host => $cm_db_host,
          db_port => $cm_db_port,
          db_user => $cm_db_masteruser,
          db_pass => $cm_db_masterpass,
          require => Class['::mysql::server'],
        }
      }
    } else {
      if $cm_db_local == 0 {
        class { '::cloudera':
          cm_server_host => $cm_api_host,
          install_cmserver => true,
          use_parcels => true,
        }
      } else {
        if $cm_db_rds == 0 {
          if $cm_db_type == "mysql" {
            class { '::mysql::server': root_password => $cm_db_master_password, remove_default_accounts => true, }
            ::mysql_user{ "$cm_db_user@%": ensure => present, password_hash => mysql_password("$cm_db_pass"), require => Class['::mysql::server'], }
            ::mysql_grant{ "$cm_db_user@%/$cm_db_name.*": user => "$cm_db_user@%", table => "$cm_db_name.*", privileges => ['ALL'], require => Class["mysql_user[$cm_db_user@%]"], }
          }
        }
        class { '::cloudera':
          cm_server_host => $cm_api_host,
          install_cmserver => true,
          use_parcels => true,
          db_type => $cm_db_type,
          db_host => $cm_db_host,
          db_port => $cm_db_port,
          db_user => $cm_db_masteruser,
          db_pass => $cm_db_masterpass,
          require => Class['mysql_grant'],
        }
      }
    }
    exec {'waiting until CM API get ready':
      command => "/usr/bin/curl -u $cm_api_user:$cm_api_password -XGET \"http://$cm_api_host:$cm_api_port/api/v13\"",
      tries => 30,
      try_sleep => 60,
      require => Class['::cloudera'],
    }
    class { '::cloudera::api::managementservice':
      cm_api_host => $cm_api_host,
      cdh_service_roles => ['ACTIVITYMONITOR','ALERTPUBLISHER','EVENTSERVER','HOSTMONITOR','SERVICEMONITOR'],
      require => Exec['waiting until CM API get ready'],
    }
    exec { 'configure-activity-monitor-db':
      command => "/bin/bash /home/ubuntu/scripts/configure_activity_monitor_db.sh $cm_api_host $cm_api_port $cm_api_user $cm_api_password > $cdh_metadata_dir/activity_monitor_db_config.json.output",
      creates => "$cdh_metadata_dir/activity_monitor_db_config.json.output",
      require => Class['::cloudera::api::managementservice'],
    }
    class { '::cloudera::api::createcluster':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_cluster_minor_release => $cdh_cluster_minor_release,
      cm_api_host => $cm_api_host,
      require => Exec['waiting until CM API get ready'],
    }
    class { '::cloudera::api::addhost':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::createcluster'],
    }
    class { '::cloudera::roles::server':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost'],
    }
    ::cloudera::parcels::config{"CDH-$cdh_cluster_major_release":
      cm_api_host => $cm_api_host,
      items_config => [{ "name" => "REMOTE_PARCEL_REPO_URLS", "value" => "https://archive.cloudera.com/cdh5/parcels/$cdh_cluster_major_release/"}],
      require => Class['::cloudera::roles::server'],
    }
    ::cloudera::parcels::download{'CDH':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      parcels_version => $cdh_cluster_parcels_release,
      require => [Class["cloudera::parcels::config[CDH-$cdh_cluster_major_release]"],Exec['configure-activity-monitor-db']],
    }
    ::cloudera::parcels::distribute{'CDH':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      parcels_version => $cdh_cluster_parcels_release,
      require => Class['cloudera::parcels::download[CDH]'],
    }
    ::cloudera::parcels::activate{'CDH':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      parcels_version => $cdh_cluster_parcels_release,
      require => Class['cloudera::parcels::distribute[CDH]'],
    }
    class {'::cloudera::api::start':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['cloudera::parcels::activate[CDH]'],
    }
    cloudera::api::statusservice{'YARN':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_status => 'STARTED',
      cm_api_host => $cm_api_host,
      require => [Class['::cloudera::api::start'],Class['cloudera::parcels::activate[CDH]']],
    }
    if $cdh_cluster_ha > 0 {
      exec {'enable-hdfs-ha':
        command => "/bin/bash /home/ubuntu/scripts/enable_hdfs_ha.sh $cm_api_host $cdh_cluster_name",
        require => Class['cloudera::api::statusservice[YARN]'],
      }
    }
  } else {
    exec {'waiting for cluster creation':
      command => "/usr/bin/curl -u $cm_api_user:$cm_api_password -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name\" | grep version",
      tries => 30,
      try_sleep => 60,
    }
    class { '::cloudera':
      cm_server_host => $cm_api_host,
      install_cmserver => false,
      use_parcels => true,
      require => Exec['waiting for cluster creation'],
    }
    class { '::cloudera::api::addhost':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['::cloudera']
    }
    if $cdh_cluster_role == 'SERVICENODE_1' {
      class { '::cloudera::roles::servicenode_1':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cdh_cluster_ha => $cdh_cluster_ha,
        cdh_cluster_multi_az => $cdh_cluster_multi_az,
        cdh_cluster_minor_release => $cdh_cluster_minor_release,
        cdh_cluster_major_release => $cdh_cluster_major_release,
        cdh_cluster_parcels_release => $cdh_cluster_parcels_release,
        server_leader => $server_leader,
        require => Class['::cloudera::api::addhost'],
      }
    } elsif $cdh_cluster_role == 'SERVICENODE_2' {
      class { '::cloudera::roles::servicenode_2':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cdh_cluster_ha => $cdh_cluster_ha,
        cdh_cluster_multi_az => $cdh_cluster_multi_az,
        cdh_cluster_minor_release => $cdh_cluster_minor_release,
        cdh_cluster_major_release => $cdh_cluster_major_release,
        cdh_cluster_parcels_release => $cdh_cluster_parcels_release,
        server_leader => $server_leader,
        require => Class['::cloudera::api::addhost'],
      }
    } elsif $cdh_cluster_role == 'DATANODE' {
      class { '::cloudera::roles::datanode':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cdh_cluster_ha => $cdh_cluster_ha,
        cdh_cluster_multi_az => $cdh_cluster_multi_az,
        cdh_cluster_minor_release => $cdh_cluster_minor_release,
        cdh_cluster_major_release => $cdh_cluster_major_release,
        cdh_cluster_parcels_release => $cdh_cluster_parcels_release,
        server_leader => $server_leader,
        require => Class['::cloudera::api::addhost'],
      }
    }
  }
}
