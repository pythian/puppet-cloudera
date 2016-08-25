# == Class: cloudera::cluster
class cloudera::cluster (
  $cdh_metadata_dir = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name = $cloudera::params::cdh_cluster_name,
  $cm_api_host      = $cloudera::params::cm_api_host,
  $cm_api_port      = $cloudera::params::cm_api_port,
  $install_cmserver = $cloudera::params::install_cmserver,
) inherits cloudera::params {
  file { "$cdh_metadata_dir":
    ensure => 'directory'
  }
  if $install_cmserver == true {
    class { '::cloudera':
      cm_server_host => $cm_api_host,
      install_cmserver = $install_cmserver,
      use_parcels => true
    }

  } else {
    class { '::cloudera':
      cm_server_host => $cm_api_host,
      use_parcels => true
    }
  }
  class { '::cloudera::cluster':
    require => Class['::cloudera']
  }
  class { '::cloudera::cluster::addhost':
    cdh_cluster_name => $cdh_cluster_name,
    cm_api_host => $cm_api_host,
    require => Class['::cloudera::cluster']
  }
}
