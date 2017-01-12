# == Class: cloudera::api::addhost
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
#  class { '::cloudera::api::addhost': }
#
# === Authors:
#
#
# === Copyright:
#
#

class cloudera::api::addhost (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_pass       = $cloudera::params::cm_api_pass
) inherits cloudera::params {

  exec { 'wait-host-registration':
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/hosts\" | grep $fqdn",
    tries => 6,
    try_sleep => 10
  }

  exec {'update-host-rack':
    command => "/bin/bash ./scripts/configure_rack.sh $cm_api_host $cm_api_port $cm_api_user $cm_api_pass > $cdh_metadata_dir/host-rack.json.output",
    creates => "$cdh_metadata_dir/host-rack.json.output",
    require => [Exec['wait-host-registration'],File['host.json']],
  }

  file { 'host.json':
    ensure  => $file_ensure,
    path    => '/tmp/host.json',
    content => template("${module_name}/host.json.erb")
  }

  exec { 'add_host':
    command => "/usr/bin/curl -H 'Content-Type: application/json' -u $cm_api_user:$cm_api_pass -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/hosts\" -d @host.json > $cdh_metadata_dir/$fqdn.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/$fqdn.json.output",
    require => [Exec['wait-host-registration'],File['host.json']],
    tries   => 3,
    try_sleep => 60
  }

}
