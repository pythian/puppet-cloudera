define cloudera::parcels::activate (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $parcels_product   = $title,
  $parcels_version   = $cloudera::params::parcels_version,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_pass   = $cloudera::params::cm_api_pass
) {

  exec { "parcels-activate-$parcels_product":
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version/commands/activate\" > $cdh_metadata_dir/parcels-activate-$parcels_product.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/parcels-activate-$parcels_product.json.output",
    tries   => 3,
    try_sleep => 60,
    notify => Exec["wait-activation-complete-$parcels_product"]
  }

  exec { "wait-activation-complete-$parcels_product":
    command => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version\" | grep ACTIVATED",
    tries => 5,
    try_sleep => 60,
    refreshonly => true,
  }
}
