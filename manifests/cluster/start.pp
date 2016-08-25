# == Class: cloudera::cluster::start
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
# === Sample Usage:
#
#   cloudera::cluster::start{'HBASE':
#     cm_api_host => $cloudera::params::cm_api_host,
#     cm_api_port => $cloudera::params::cm_api_port
#   }
#
# === Authors:
#
#
# === Copyright:
#
#

Class cloudera::cluster::start (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password
) inherits cloudera::params {

  exec { "start cluster $cdh_cluster_name":
    command => "/usr/bin/curl -H 'Content-Type: application/json' -u $cloudera::params::cm_api_user:$cloudera::params::cm_api_password -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/firstRun\" > $cdh_metadata_dir/cluster-started.lock",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/cluster-started.lock",
    tries   => 3,
    try_sleep => 60
  }

}
