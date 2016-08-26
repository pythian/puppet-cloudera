class cloudera::cluster::roles::servicenode_2 (
  $file_ensure       = $cloudera::params::file_ensure,
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
) inherits cloudera::params {

  class { '::cloudera':
    cm_server_host => $cm_api_host,
    use_parcels => true
  }
  class { '::cloudera::cluster':
    require => Class['::cloudera']
  }
  class { '::cloudera::cluster::addhost':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster']
  }
  cloudera::cluster::addrole{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['SECONDARYNAMENODE'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster::addhost'],
  }
  cloudera::cluster::addrole{'YARN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['RESOURCEMANAGER','HISTORYSERVER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster::addhost'],
  }
  cloudera::cluster::addrole{'ZOOKEEPER':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['SERVER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster::addhost'],
  }
}
