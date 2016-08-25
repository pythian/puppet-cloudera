class cloudera::cluster::roles::server (
  $file_ensure       = $cloudera::params::file_ensure,
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_version  = $cloudera::params::cdh_cluster_version,
  $cdh_full_version  = $cloudera::params::cdh_full_version,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
  $cm_db_remote      = $cloudera::params::cm_db_remote,
  $cm_db_type        = $cloudera::params::cm_db_type,
  $cm_db_host        = $cloudera::params::cm_db_host,
  $cm_db_port        = $cloudera::params::cm_db_port,
  $cm_db_user        = $cloudera::params::cm_db_user,
  $cm_db_pass        = $cloudera::params::cm_db_pass
) inherits cloudera::params {

  if $cm_db_remote == 0 {
    class { '::cloudera':
      cm_server_host => $cm_api_host,
      install_cmserver => true,
      use_parcels => true
    }
  }  else {
    class { '::cloudera':
      cm_server_host => $cm_api_host,
      install_cmserver => true,
      use_parcels => true,
      db_type => $cm_db_type,
      db_host => $cm_db_host,
      db_port => $cm_db_port,
      db_user => $cm_db_user,
      db_pass => $cm_db_pass
    }
  }

  class { '::cloudera::cluster':
    require => Class['::cloudera']
  }

  class { '::cloudera::cluster::managementservice':
    cm_api_host => $cm_api_host,
    cdh_service_roles => ['ACTIVITYMONITOR','ALERTPUBLISHER','EVENTSERVER','HOSTMONITOR','SERVICEMONITOR'],
    require => Class['::cloudera::cluster']
  }

  class { '::cloudera::cluster::create':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    cdh_cluster_version => $cdh_cluster_version,
    cdh_full_version => $cdh_full_version,
    require => Class['::cloudera::cluster']
  }

}
