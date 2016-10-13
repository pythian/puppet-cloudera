class cloudera::roles::datanode (
  $file_ensure       = $cloudera::params::file_ensure,
  $server_leader     = $cloudera::params::server_leader,
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
  $cdh_cluster_multi_az = $cloudera::params::cdh_cluster_multi_az,
  $cdh_cluster_major_release = $cdh_cluster_major_release,
  $cdh_cluster_minor_release = $cdh_cluster_minor_release,
  $cdh_cluster_parcels_release = $cdh_cluster_parcels_release,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
) inherits cloudera::params {
  cloudera::api::addrole{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['DATANODE'],
    cm_api_host => $cm_api_host,
  }
  cloudera::api::addrole{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['REGIONSERVER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::addhost'],
  }
  cloudera::api::addrole{'MAPREDUCE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['TASKTRACKER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::addhost'],
  }
  exec { 'wait-parcels':
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_password -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/CDH/versions/$cdh_cluster_parcels_release\" | grep ACTIVATED",
    tries => 15,
    try_sleep => 60,
    require => [Class['cloudera::api::addrole[HDFS]'],Class['cloudera::api::addrole[HBASE]'],Class['cloudera::api::addrole[YARN]'],],
  }
  exec {'configure-hdfs-disks':
    command => "/bin/bash /home/ubuntu/scripts/hdfs_disks.sh $cm_api_host $cm_api_port $cm_api_user $cm_api_password $cdh_cluster_name > $cdh_metadata_dir/disks",
    creates => "$cdh_metadata_dir/disks",
    require => Exec['wait-parcels'],
  }
}
