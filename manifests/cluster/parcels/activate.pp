define cloudera::cluster::parcels::activate (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $parcels_product   = $title,
  $parcels_version   = $cloudera::params::parcels_version,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password
) {

  exec { "parcels-activate-$parcels_product":
    command => "/usr/bin/curl -u $cloudera::params::cm_api_user:$cloudera::params::cm_api_password -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version/commands/activate\" > $cdh_metadata_dir/parcels-activate-$parcels_product.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/parcels-activate-$parcels_product.json.output",
    tries   => 3,
    try_sleep => 60
  }

}
