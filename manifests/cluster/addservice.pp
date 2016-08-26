# == Class: cloudera::cluster::addservice
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
#   cloudera::cluster::addservice{'HBASE':
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

define cloudera::cluster::addservice (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
  $cdh_service_name = $title
) {

  file { "$cdh_service_name.json":
    ensure  => $file_ensure,
    path    => "/tmp/$cdh_service_name.json",
    content => template("${module_name}/service.json.erb")
  }

  exec { "add service $cdh_service_name":
    command => "/usr/bin/curl -H 'Content-Type: application/json' -u $cloudera::params::cm_api_user:$cloudera::params::cm_api_password -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/services\" -d @$cdh_service_name.json > $cdh_metadata_dir/$cdh_service_name.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/$cdh_service_name.json.output",
    require => File["$cdh_service_name.json"],
    tries   => 3,
    try_sleep => 60
  }
}
