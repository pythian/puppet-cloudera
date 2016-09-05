# == Class: cloudera::api::statusservice
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
#  class { '::cloudera::api::statusservice': }
#
# === Authors:
#
#
# === Copyright:
#
#

define cloudera::api::statusservice (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $server_leader     = $cloudera::params::server_leader,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cdh_service_name  = $title,
  $cdh_service_status = $cloudera::params::cdh_service_status,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
) {

  exec { "wait-for-service-$cdh_service_name-get-$cdh_service_status":
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_password -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/services/$cdh_service_name\" | grep $cdh_service_status",
    tries => 30,
    try_sleep => 60,
  }

}
