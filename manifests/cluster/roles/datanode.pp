class cloudera::cluster::roles::datanode (
  $file_ensure       = $cloudera::params::file_ensure,
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_service_roles = $cloudera::params::cdh_service_roles,
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
    require => Class['::cloudera::cluster::create']
  }
  cloudera::cluster::addservice{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => $cdh_service_roles,
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster::addhost'],
  }
}
