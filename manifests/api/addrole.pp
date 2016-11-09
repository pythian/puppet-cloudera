# == Class: cloudera::api::addrole
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
#   cloudera::api::addrole{'HBASE':
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

define cloudera::api::addrole (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_pass   = $cloudera::params::cm_api_pass,
  $cdh_service_name = $title,
  $cdh_service_roles = $cloudera::params::cdh_service_roles
) {

  file { "$cdh_service_name-roles.json":
    ensure  => $file_ensure,
    path    => "/tmp/$cdh_service_name-roles.json",
    content => template("${module_name}/roles.json.erb")
  }

  exec { "add role for service $cdh_service_name":
    command => "/usr/bin/curl -H 'Content-Type: application/json' -u $cm_api_user:$cm_api_pass -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/services/$cdh_service_name/roles\" -d @$cdh_service_name-roles.json > $cdh_metadata_dir/$cdh_service_name-roles.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/$cdh_service_name-roles.json.output",
    require => File["$cdh_service_name-roles.json"],
    tries   => 3,
    try_sleep => 60
  }
}
