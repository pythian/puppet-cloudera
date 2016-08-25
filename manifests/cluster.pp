# == Class: cloudera::cluster
class cloudera::cluster (
  $cdh_metadata_dir = $cloudera::params::cdh_metadata_dir,
) inherits cloudera::params {
  file { "$cdh_metadata_dir":
    ensure => 'directory'
  }
}
