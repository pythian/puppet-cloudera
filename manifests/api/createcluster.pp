# == Class: cloudera::api::createcluster
#
# This class handles installing and configuring the Cloudera Manager Server.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# === Actions:
#
#
# === Requires:
#
#
# === Sample Usage:
#
#
# === Authors:
#
#
# === Copyright:
#
#
class cloudera::api::createcluster (
  $file_ensure       = $cloudera::params::file_ensure,
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_cluster_version  = $cloudera::params::cdh_cluster_version,
  $cdh_cluster_major_release = $cdh_cluster_major_release,
  $cdh_cluster_minor_release = $cdh_cluster_minor_release,
  $cdh_cluster_parcels_release = $cdh_cluster_parcels_release,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_pass   = $cloudera::params::cm_api_pass
) inherits cloudera::params {

  file { 'cluster.json':
    ensure  => $file_ensure,
    path    => '/tmp/cluster.json',
    content => template("${module_name}/cluster.json.erb"),
    require => Package['cloudera-manager-server']
  }

  exec { 'create_cluster':
    command => "/usr/bin/curl -H 'Content-Type: application/json' -u $cm_api_user:$cm_api_pass -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters\" -d @cluster.json > $cdh_metadata_dir/cluster.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/cluster.json.output",
    require => File['cluster.json'],
    tries   => 3,
    try_sleep => 60
  }

}
