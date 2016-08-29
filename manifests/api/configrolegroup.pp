# == Class: cloudera::api::configrolegroup
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
#   cloudera::api::configrolegroup{'HDFS':
#     cm_api_host => $cloudera::params::cm_api_host,
#     cm_api_port => $cloudera::params::cm_api_port,
#     cdh_service_rolegroup => $cloudera::params::cdh_service_rolegroup
#   }
#
# === Authors:
#
#
# === Copyright:
#
#

define cloudera::api::configrolegroup (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
  $cdh_cluster_service = $cloudera::params::cdh_cluster_service,
  $cdh_service_rolegroup = $cloudera::params::cdh_service_rolegroup,
  $items_config = $cloudera::params::items_config
) {

  file { "$cdh_cluster_service-$cdh_service_rolegroup-config.json":
    ensure  => $file_ensure,
    path    => "/tmp/$cdh_cluster_service-$cdh_service_rolegroup-config.json",
    content => template("${module_name}/config.json.erb")
  }

  exec { "add config for service $cdh_cluster_service role type $cdh_service_rolegroup":
    command => "/usr/bin/curl -H 'Content-Type: application/json' -u $cloudera::params::cm_api_user:$cloudera::params::cm_api_password -XPUT \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/services/$cdh_cluster_service/roleConfigGroups/$cdh_service_rolegroup/config\" -d @$cdh_cluster_service-$cdh_service_rolegroup-config.json > $cdh_metadata_dir/$cdh_cluster_service-$cdh_service_rolegroup-config.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/$cdh_cluster_service-$cdh_service_rolegroup-config.json.output",
    require => File["$cdh_cluster_service-$cdh_service_rolegroup-config.json"],
    tries   => 3,
    try_sleep => 60
  }

}
