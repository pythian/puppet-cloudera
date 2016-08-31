class cloudera::roles::servicenode_1 (
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
      cdh_service_roles => ['NAMENODE','JOURNALNODE'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'HBASE':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['MASTER'],
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
      cdh_service_roles => ['NAMENODE','JOURNALNODE','FAILOVERCONTROLLER'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'HBASE':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['MASTER'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'YARN':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['RESOURCEMANAGER'],
      cm_api_host => $cm_api_host,
    }
    cloudera::api::addrole{'ZOOKEEPER':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_roles => ['SERVER'],
      cm_api_host => $cm_api_host,
    }
  }
}
