class cloudera::roles::servicenode (
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
  class { '::nfs':
    client_enabled => true,
  }
  file {'/nfs':
    ensure => directory,
  }
  file {'/nfs/namenode':
    ensure => directory,
    require => File['/nfs'],
  }
  mount { '/nfs/namenode':
    device  => "$cm_api_host:/nfs/namenode",
    fstype  => "nfs",
    ensure  => "mounted",
    options => "defaults",
    atboot  => true,
    require => File['/nfs/namenode']
  }
  cloudera::api::addrole{'HDFS':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['SECONDARYNAMENODE'],
    cm_api_host => $cm_api_host,
  }
  cloudera::api::addrole{'YARN':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['RESOURCEMANAGER','JOBHISTORY'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::addhost'],
  }
  cloudera::api::addrole{'ZOOKEEPER':
    cdh_cluster_name => $cdh_cluster_name,
    cdh_service_roles => ['SERVER'],
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::api::addhost'],
  }
  exec { 'wait-parcels':
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_password -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/CDH/versions/$cdh_cluster_parcels_release\" | grep ACTIVATED",
    tries => 15,
    try_sleep => 60,
    require => Class['cloudera::api::addrole[ZOOKEEPER]'],
  }
  class{'::cloudera::api::zookeeperinit':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    require => Exec['wait-parcels'],
  }
}
