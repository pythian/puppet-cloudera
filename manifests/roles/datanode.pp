class cloudera::roles::datanode (
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
  $cm_api_pass   = $cloudera::params::cm_api_pass,
) inherits cloudera::params {
  cloudera::api::addrole{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['DATANODE'],
    cm_api_host => $cm_api_host,
    cm_api_port => $cm_api_port,
    cm_api_user => $cm_api_user,
    cm_api_pass => $cm_api_pass,
  }
  cloudera::api::addrole{'HBASE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['REGIONSERVER'],
    cm_api_host => $cm_api_host,
    cm_api_port => $cm_api_port,
    cm_api_user => $cm_api_user,
    cm_api_pass => $cm_api_pass,
    require => Class['::cloudera::api::addhost'],
  }
  cloudera::api::addrole{'MAPREDUCE':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['TASKTRACKER'],
    cm_api_host => $cm_api_host,
    cm_api_port => $cm_api_port,
    cm_api_user => $cm_api_user,
    cm_api_pass => $cm_api_pass,
    require => Class['::cloudera::api::addhost'],
  }
  exec { 'wait-parcels':
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/CDH/versions/$cdh_cluster_parcels_release\" | grep ACTIVATED",
    tries => 45,
    try_sleep => 60,
    require => [Class['cloudera::api::addrole[HDFS]'],Class['cloudera::api::addrole[HBASE]'],Class['cloudera::api::addrole[MAPREDUCE]'],],
  }
  exec {'configure-hdfs-disks':
    command => "/bin/bash /home/ubuntu/scripts/hdfs_disks.sh $cm_api_host $cm_api_port $cm_api_user $cm_api_pass $cdh_cluster_name > $cdh_metadata_dir/disks",
    creates => "$cdh_metadata_dir/disks",
    require => Exec['wait-parcels'],
  }
  if $server_leader == 0 {
    class {'::cloudera::api::start':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      cm_api_user => $cm_api_user,
      cm_api_pass => $cm_api_pass,
      require => Exec['configure-hdfs-disks'],
    }
    cloudera::api::statusservice{'MAPREDUCE':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_service_status => 'STARTED',
      cm_api_host => $cm_api_host,
      cm_api_user => $cm_api_user,
      cm_api_pass => $cm_api_pass,
      require => Class['::cloudera::api::start'],
    }
    if $cdh_cluster_ha > 0 {
      exec {'enable-hdfs-ha':
        #it will never run without default credentials, but need to be update to be consistent. Currently, user and pass are not passed to enable_hdfs_ha script
        command => "/bin/bash /home/ubuntu/scripts/enable_hdfs_ha.sh $cm_api_host $cdh_cluster_name",
        require => Class['cloudera::api::statusservice[MAPREDUCE]'],
      }
    }
  }
}
