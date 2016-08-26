class cloudera::cluster::roles::datanode (
  $file_ensure       = $cloudera::params::file_ensure,
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
  $cdh_cluster_major_release = $cdh_cluster_major_release,
  $cdh_cluster_minor_release = $cdh_cluster_minor_release,
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
    cdh_service_roles => ['DATANODE'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster::addhost'],
  }
  cloudera::cluster::configservice{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::cluster::addrole[HDFS]'],
  }
  cloudera::cluster::configroletype{'HDFS-NN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_roletype => 'NAMENODE',
    items_config => [{ "name" => "dfs_name_dir_list", "value" => "/namenode/"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::cluster::addrole[HDFS]']
  }
  cloudera::cluster::configroletype{'HDFS-DN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_roletype => 'DATANODE',
    items_config => [{ "name" => "dfs_data_dir_list", "value" => "/datanode/"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::cluster::addrole[HDFS]']
  }
  cloudera::cluster::configroletype{'HDFS-SNN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_roletype => 'SECONDARYNAMENODE',
    items_config => [{ "name" => "fs_checkpoint_dir_list", "value" => "/secondarynamenode/"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::cluster::addrole[HDFS]']
  }
  cloudera::cluster::addrole{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['REGIONSERVER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster::addhost'],
  }
  cloudera::cluster::configservice{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "hdfs_rootdir", "value" => "/HBASE"},{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"},{ "name" => "hdfs_service", "value" => "HDFS"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::cluster::addrole[HBASE]']
  }
  cloudera::cluster::addrole{'YARN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['NODEMANAGER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster::addhost'],
  }
  ::cloudera::cluster::parcels::config{"CDH-$cdh_cluster_major_version":
    cm_api_host => $cm_api_host,
    items_config => [{ "name" => "REMOTE_PARCEL_REPO_URLS", "value" => "https://archive.cloudera.com/cdh5/parcels/$cdh_cluster_major_version/"}],
    require => Class['::cloudera']
  }
  ::cloudera::cluster::parcels::download{'CDH':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    cdh_cluster_minor_release => $cdh_cluster_minor_release,
    require => Class['cloudera::cluster::configroletype[HDFS-NN]']
  }
  ::cloudera::cluster::parcels::distribute{'CDH':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    cdh_cluster_minor_release => $cdh_cluster_minor_release,
    require => Class['cloudera::cluster::parcels::download[CDH]']
  }
  ::cloudera::cluster::parcels::activate{'CDH':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    cdh_cluster_minor_release => $cdh_cluster_minor_release,
    require => Class['cloudera::cluster::parcels::distribute[CDH]']
  }
#  class {'::cloudera::cluster::start':
#    cdh_cluster_name => $cdh_cluster_name,
#    cm_api_host => $cm_api_host,
#    require => Class['cloudera::cluster::parcels::activate[CDH]']
#  }
}
