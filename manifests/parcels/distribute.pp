define cloudera::parcels::distribute (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $parcels_product   = $title,
  $parcels_version   = $cloudera::params::parcels_version,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_pass   = $cloudera::params::cm_api_pass
) {

  exec { "parcels-distribute-$parcels_product":
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version/commands/startDistribution\" > $cdh_metadata_dir/parcels-distribute-$parcels_product.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/parcels-distribute-$parcels_product.json.output",
    tries   => 3,
    try_sleep => 60,
    notify => Exec["wait-distribution-complete-$parcels_product"]
  }

  exec { "wait-distribution-complete-$parcels_product":
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version\" | jq '. | select(.state.totalProgress == 100) | select(.stage == "DISTRIBUTED")'",
    tries => 10,
    try_sleep => 180,
    refreshonly => true,
  }
}

