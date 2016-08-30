class cloudera::roles::servicenode_1 (
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
  class { '::cloudera::api':
    require => Class['::cloudera']
  }
  class { '::cloudera::api::addhost':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api']
  }
  if $cdh_cluster_ha == 0 { 
    cloudera::api::addrole{'HDFS':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['NAMENODE'],
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost'],
    }
    cloudera::api::addrole{'HBASE':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['MASTER'],
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost'],
    }
    cloudera::api::addrole{'ZOOKEEPER':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['SERVER'],
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost'],
    }
  } else {
    cloudera::api::addrole{'HDFS':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['NAMENODE'],
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost'],
    }
    cloudera::api::addrole{'HBASE':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['MASTER'],
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost'],
    }
    cloudera::api::addrole{'YARN':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['RESOURCEMANAGER'],
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost'],
    }
  }
}
