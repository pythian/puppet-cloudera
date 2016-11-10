class cloudera::roles::servicenode_2 (
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
  $cm_api_pass   = $cloudera::params::cm_api_pass,
) inherits cloudera::params {
  if $cdh_cluster_multi_az == 0 {
    if $cdh_cluster_ha == 0 {
      file {'/nfs':
        ensure => directory,
      }
      file {'/nfs/namenode':
        ensure => directory,
        require => File['/nfs'],
      }
      class { '::nfs':
        client_enabled => true,
        require => File['/nfs/namenode'],
      }
      mount { '/nfs/namenode':
        device  => "$cm_api_host:/nfs/namenode",
        fstype  => "nfs",
        ensure  => "mounted",
        options => "defaults",
        atboot  => true,
        require => File['/nfs/namenode'],
      }
      cloudera::api::addrole{'HDFS':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SECONDARYNAMENODE','JOURNALNODE'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Mount['/nfs/namenode'],
      }
      cloudera::api::addrole{'MAPREDUCE':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['JOBTRACKER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Mount['/nfs/namenode'],
      }
      cloudera::api::addrole{'ZOOKEEPER':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SERVER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Mount['/nfs/namenode'],
      }
      exec { 'wait-parcels':
        command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/CDH/versions/$cdh_cluster_parcels_release\" | grep ACTIVATED",
        tries => 15,
        try_sleep => 60,
        require => Class['cloudera::api::addrole[ZOOKEEPER]'],
      }
      exec {'change-nfs-permission':
        command => "/bin/chown -R hdfs:hadoop /nfs/namenode && touch $cdh_metadata_dir/nfs-permission.lock",
        creates => "$cdh_metadata_dir/nfs-permission.lock",
        require => Exec['wait-parcels'],
      }
      class{'::cloudera::api::zookeeperinit':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Exec['wait-parcels'],
      }
    } else {
      cloudera::api::addrole{'HDFS':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SECONDARYNAMENODE','JOURNALNODE'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      cloudera::api::addrole{'HBASE':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['MASTER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      cloudera::api::addrole{'MAPREDUCE':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['JOBTRACKER','FAILOVERCONTROLLER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      cloudera::api::addrole{'ZOOKEEPER':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SERVER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      exec { 'wait-parcels':
        command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/CDH/versions/$cdh_cluster_parcels_release\" | grep ACTIVATED",
        tries => 15,
        try_sleep => 60,
        require => Class['cloudera::api::addrole[ZOOKEEPER]'],
      }
      class{'::cloudera::api::zookeeperinit':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Exec['wait-parcels'],
      }
    }
  } else {
    if $cdh_cluster_ha == 0 {
      file {'/nfs':
        ensure => directory,
      }
      file {'/nfs/namenode':
        ensure => directory,
        require => File['/nfs'],
      }
      class { '::nfs':
        client_enabled => true,
        require => File['/nfs/namenode'],
      }
      mount { '/nfs/namenode':
        device  => "$cm_api_host:/nfs/namenode",
        fstype  => "nfs",
        ensure  => "mounted",
        options => "defaults",
        atboot  => true,
        require => File['/nfs/namenode'],
      }
      cloudera::api::addrole{'HDFS':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SECONDARYNAMENODE','JOURNALNODE'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Mount['/nfs/namenode'],
      }
      cloudera::api::addrole{'MAPREDUCE':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['JOBTRACKER','FAILOVERCONTROLLER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Mount['/nfs/namenode'],
      }
      cloudera::api::addrole{'ZOOKEEPER':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SERVER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Mount['/nfs/namenode'],
      }
      exec { 'wait-parcels':
        command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/CDH/versions/$cdh_cluster_parcels_release\" | grep ACTIVATED",
        tries => 15,
        try_sleep => 60,
        require => Class['cloudera::api::addrole[ZOOKEEPER]'],
      }
      exec {'change-nfs-permission':
        command => "/bin/chown -R hdfs:hadoop /nfs/namenode && touch $cdh_metadata_dir/nfs-permission.lock",
        creates => "$cdh_metadata_dir/nfs-permission.lock",
        require => Exec['wait-parcels'],
      }
      class{'::cloudera::api::zookeeperinit':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Exec['wait-parcels'],
      }
    } else {
      cloudera::api::addrole{'HDFS':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SECONDARYNAMENODE','JOURNALNODE'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      cloudera::api::addrole{'HBASE':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['MASTER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      cloudera::api::addrole{'MAPREDUCE':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['JOBTRACKER','FAILOVERCONTROLLER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      cloudera::api::addrole{'ZOOKEEPER':
        cdh_cluster_name => $cdh_cluster_name,
        cdh_service_roles => ['SERVER'],
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
      }
      exec { 'wait-parcels':
        command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/CDH/versions/$cdh_cluster_parcels_release\" | grep ACTIVATED",
        tries => 15,
        try_sleep => 60,
        require => Class['cloudera::api::addrole[ZOOKEEPER]'],
      }
      class{'::cloudera::api::zookeeperinit':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cm_api_port => $cm_api_port,
        cm_api_user => $cm_api_user,
        cm_api_pass => $cm_api_pass,
        require => Exec['wait-parcels'],
      }
    }
  }
}