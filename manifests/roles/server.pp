class cloudera::roles::server (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $server_leader     = $cloudera::params::server_leader,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_version  = $cloudera::params::cdh_cluster_version,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
  $cdh_cluster_multi_az = $cloudera::params::cdh_cluster_multi_az,
  $cdh_cluster_major_release = $cdh_cluster_major_release,
  $cdh_cluster_minor_release = $cdh_cluster_minor_release,
  $cdh_cluster_parcels_release = $cdh_cluster_parcels_release,
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
  cloudera::api::addservice{'ZOOKEEPER':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['nfs::server::export[/nfs/namenode]'],
  }
  cloudera::api::addservice{'HDFS':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['nfs::server::export[/nfs/namenode]'],
  }
  cloudera::api::addservice{'HBASE':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['nfs::server::export[/nfs/namenode]'],
  }
  cloudera::api::addservice{'YARN':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    require => Class['::cloudera::api::addhost']
  }
  cloudera::api::addrole{'ZOOKEEPER':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['SERVER'],
    require => Class['cloudera::api::addservice[ZOOKEEPER]']
  }
  cloudera::api::addrole{'HDFS':
    cm_api_host => $cm_api_host,
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['JOURNALNODE'],
    require => Class['cloudera::api::addservice[HDFS]']
  }
  cloudera::api::configservice{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "hdfs_rootdir", "value" => "/HBASE"},{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"},{ "name" => "hdfs_service", "value" => "HDFS"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[HBASE]']
  }
  cloudera::api::configservice{'YARN':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "hdfs_service", "value" => "HDFS"},{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[YARN]'],
  }
  cloudera::api::configservice{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    items_config => [{ "name" => "zookeeper_service", "value" => "ZOOKEEPER"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addrole[HDFS]'],
  }
  cloudera::api::configrolegroup{'YARN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'YARN',
    cdh_service_rolegroup => 'YARN-NODEMANAGER-BASE',
    items_config => [{ "name" => "yarn_nodemanager_local_dirs", "value" => "/dfs/yarn/nodemanager"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[YARN]'],
  }
  cloudera::api::configrolegroup{'HDFS-JOURNALNODE-BASE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_rolegroup => 'HDFS-JOURNALNODE-BASE',
    items_config => [{ "name" => "dfs_journalnode_edits_dir", "value" => "/dfs/journalnode"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[HDFS]'],
  }
  cloudera::api::configrolegroup{'HDFS-SECONDARYNAMENODE-BASE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_rolegroup => 'HDFS-SECONDARYNAMENODE-BASE',
    items_config => [{ "name" => "fs_checkpoint_dir_list", "value" => "/dfs/secondarynamenode"}],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[HDFS]'],
  }
  cloudera::api::configrolegroup{'HDFS-NAMENODE-BASE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_cluster_service => 'HDFS',
    cdh_service_rolegroup => 'HDFS-NAMENODE-BASE',
    items_config => [{ "name" => "dfs_name_dir_list", "value" => "/nfs/namenode,/dfs/namenode" }],
    cm_api_host => $cm_api_host,
    require => Class['cloudera::api::addservice[HDFS]'],
  }
}
