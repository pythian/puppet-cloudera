class cloudera::roles::servicenode_2 (
  $file_ensure       = $cloudera::params::file_ensure,
  $server_leader     = $cloudera::params::server_leader,
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
  if $cdh_cluster_ha == 0 { 
    cloudera::api::addrole{'HDFS':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['SECONDARYNAMENODE','JOURNALNODE'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'YARN':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['RESOURCEMANAGER','JOBHISTORY'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'ZOOKEEPER':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['SERVER'],
      cm_api_host => $cm_api_host,
    }
  } else {
    cloudera::api::addrole{'HDFS':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['SECONDARYNAMENODE','JOURNALNODE'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'HBASE':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['MASTER'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'YARN':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['RESOURCEMANAGER','JOBHISTORY'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'ZOOKEEPER':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['SERVER'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::statusservice{'HDFS':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_status => 'STARTED',
      cm_api_host => $cm_api_host,
      require => [Class['cloudera::api::addrole[HDFS]'], Class['cloudera::api::addrole[HBASE]'], Class['cloudera::api::addrole[YARN]'], Class['cloudera::api::addrole[ZOOKEEPER]']],
    }
    class {'::cloudera::api::start':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['cloudera::api::statusservice[HDFS]'],
    }
    cloudera::api::statusservice{'YARN':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_status => 'STARTED',
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::start'],
    }
    exec {'enable-hdfs-ha':
      command => "/bin/bash /home/ubuntu/scripts/enable_hdfs_ha.sh $cm_api_host $cdh_cluster_name $fqdn",
      require => Class['cloudera::api::statusservice[YARN]'],
    }
  }
}
