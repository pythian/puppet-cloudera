# == Class: cloudera::cluster
class cloudera::cluster (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $server_leader     = $cloudera::params::server_leader,
  $cdh_cluster_role  = $cloudera::params::cdh_cluster_role,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_ha    = $cloudera::params::cdh_cluster_ha,
  $cdh_cluster_major_release = $cdh_cluster_major_release,
  $cdh_cluster_minor_release = $cdh_cluster_minor_release,
  $cdh_cluster_parcels_release = $cdh_cluster_parcels_release,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
  $cm_db_remote      = $cloudera::params::cm_db_remote,
  $cm_db_type        = $cloudera::params::cm_db_type,
  $cm_db_host        = $cloudera::params::cm_db_host,
  $cm_db_port        = $cloudera::params::cm_db_port,
  $cm_db_user        = $cloudera::params::cm_db_user,
  $cm_db_pass        = $cloudera::params::cm_db_pass,
) inherits cloudera::params {
  class { '::cloudera::api': }

  if $cdh_cluster_role == 'CMSERVER' {
    if $cm_db_remote == 0 {
      class { '::cloudera':
        cm_server_host => $cm_api_host,
        install_cmserver => true,
        use_parcels => true,
      }
    } else {
      class { '::cloudera':
        cm_server_host => $cm_api_host,
        install_cmserver => true,
        use_parcels => true,
        db_type => $cm_db_type,
        db_host => $cm_db_host,
        db_port => $cm_db_port,
        db_user => $cm_db_user,
        db_pass => $cm_db_pass,
      }
    }
    exec {'waiting until CM API get ready':
      command => "/usr/bin/curl -u $cloudera::params::cm_api_user:$cloudera::params::cm_api_password -XGET \"http://$cm_api_host:$cm_api_port/api/v13\"",
      tries => 6,
      try_sleep => 300,
      require => Class['::cloudera'],
    }
    class { '::cloudera::api::createcluster':
      cdh_cluster_name => $cdh_cluster_name,
      cdh_cluster_minor_release => $cdh_cluster_minor_release,
      cm_api_host => $cm_api_host,
      require => Exec['waiting until CM API get ready']
    }
    class { '::cloudera::api::addhost':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::createcluster']
    }
    class { '::cloudera::role::server':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['::cloudera::api::addhost']
    }
  } else {
    exec {'waiting for cluster creation':
      command => "/usr/bin/curl -u $cloudera::params::cm_api_user:$cloudera::params::cm_api_password -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name\" | grep version",
      tries => 6,
      try_sleep => 300,
    }
    class { '::cloudera':
      cm_server_host => $cm_api_host,
      install_cmserver => false,
      use_parcels => true,
      require => Exec['waiting for cluster creation'],
    }
    class { '::cloudera::api::addhost':
      cdh_cluster_name => $cdh_cluster_name,
      cm_api_host => $cm_api_host,
      require => Class['::cloudera']
    }
    if $cdh_cluster_role == 'SERVICENODE_1' {
      class { '::cloudera::role::servicenode_1':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cdh_cluster_ha => $cdh_cluster_ha,
        cdh_cluster_minor_release => $cdh_cluster_minor_release,
        cdh_cluster_major_release => $cdh_cluster_major_release,
        cdh_cluster_parcels_release => $cdh_cluster_parcels_release,
        server_leader => $server_leader,
      }
    } elsif $cdh_cluster_role == 'SERVICENODE_2' {
      class { '::cloudera::role::servicenode_2':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cdh_cluster_ha => $cdh_cluster_ha,
        cdh_cluster_minor_release => $cdh_cluster_minor_release,
        cdh_cluster_major_release => $cdh_cluster_major_release,
        cdh_cluster_parcels_release => $cdh_cluster_parcels_release,
        server_leader => $server_leader,
      }

    } elsif $cdh_cluster_role == 'DATANODE' {
      class { '::cloudera::role::datanode':
        cdh_cluster_name => $cdh_cluster_name,
        cm_api_host => $cm_api_host,
        cdh_cluster_ha => $cdh_cluster_ha,
        cdh_cluster_minor_release => $cdh_cluster_minor_release,
        cdh_cluster_major_release => $cdh_cluster_major_release,
        cdh_cluster_parcels_release => $cdh_cluster_parcels_release,
        server_leader => $server_leader,
      }
  }
}
