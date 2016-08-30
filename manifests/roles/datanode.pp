class cloudera::roles::datanode (
  $file_ensure       = $cloudera::params::file_ensure,
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
  $cdh_cluster_major_release = $cdh_cluster_major_release,
  $cdh_cluster_minor_release = $cdh_cluster_minor_release,
  $cdh_cluster_parcels_release = $cdh_cluster_parcels_release,
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
  cloudera::api::addrole{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['DATANODE'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::addhost'],
  }
  cloudera::api::configservice{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addrole[HDFS]'],
  }
  cloudera::api::configroletype{'HDFS-NN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_roletype => 'NAMENODE',
    items_config => [{ "name" => "dfs_name_dir_list", "value" => "/dfs/hdfs/namenode"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addrole[HDFS]']
  }
  cloudera::api::configroletype{'HDFS-DN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_roletype => 'DATANODE',
    items_config => [{ "name" => "dfs_data_dir_list", "value" => "/dfs/hdfs/datanode"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addrole[HDFS]']
  }
  cloudera::api::configroletype{'HDFS-SNN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_roletype => 'SECONDARYNAMENODE',
    items_config => [{ "name" => "fs_checkpoint_dir_list", "value" => "/dfs/hdfs/secondarynamenode"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addrole[HDFS]']
  }
  cloudera::api::addrole{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['REGIONSERVER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::addhost'],
  }
  cloudera::api::configservice{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "hdfs_rootdir", "value" => "/HBASE"},{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"},{ "name" => "hdfs_service", "value" => "HDFS"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addrole[HBASE]']
  }
  cloudera::api::addrole{'YARN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['NODEMANAGER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::addhost'],
  }
  ::cloudera::parcels::config{"CDH-$cdh_cluster_major_release":
    cm_api_host => $cm_api_host,
    items_config => [{ "name" => "REMOTE_PARCEL_REPO_URLS", "value" => "https://archive.cloudera.com/cdh5/parcels/$cdh_cluster_major_release/"}],
    require => Class['::cloudera::api::addhost']
  }
  ::cloudera::parcels::download{'CDH':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    parcels_version => $cdh_cluster_parcels_release,
    require => Class["cloudera::parcels::config[CDH-$cdh_cluster_major_release]"]
  }
  ::cloudera::parcels::distribute{'CDH':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    parcels_version => $cdh_cluster_parcels_release,
    require => Class['cloudera::parcels::download[CDH]']
  }
  ::cloudera::parcels::activate{'CDH':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    parcels_version => $cdh_cluster_parcels_release,
    require => Class['cloudera::parcels::distribute[CDH]']
  }
  class {'::cloudera::api::start':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    require => Class['cloudera::parcels::activate[CDH]']
  }
}
