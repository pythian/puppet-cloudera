class cloudera::roles::server (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_version  = $cloudera::params::cdh_cluster_version,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
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
  class { '::cloudera::api':
    require => Class['::cloudera']
  }
  class { '::cloudera::api::managementservice':
    cm_api_host => $cm_api_host,
    cdh_service_roles => ['ACTIVITYMONITOR','ALERTPUBLISHER','EVENTSERVER','HOSTMONITOR','SERVICEMONITOR'],
    require => Class['::cloudera::api']
  }
  class { '::cloudera::api::create':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    cdh_cluster_version => $cdh_cluster_version,
    cdh_full_version => $cdh_full_version,
    require => Class['::cloudera::api']
  }
  class { '::cloudera::api::addhost':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::create']
  }
  cloudera::api::addservice{'ZOOKEEPER':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['::cloudera::api::addhost']
  }
  cloudera::api::addservice{'HDFS':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['::cloudera::api::addhost']
  }
  cloudera::api::addservice{'HBASE':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['::cloudera::api::addhost']
  }
  cloudera::api::configservice{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "hdfs_service", "value" => "HDFS"},{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[HBASE]']
  }
  cloudera::api::addservice{'YARN':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['::cloudera::api::addhost']
  }
  cloudera::api::configservice{'YARN':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "hdfs_service", "value" => "HDFS"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[YARN]']
  }
  cloudera::api::addrole{'ZOOKEEPER':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['SERVER'],
    require => Class['cloudera::api::addservice[ZOOKEEPER]']
  }
}
