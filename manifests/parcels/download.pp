define cloudera::parcels::download (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cdh_cluster_name  = $cloudera::params::cdh_cluster_name,
  $parcels_product   = $title,
  $parcels_version   = $cloudera::params::parcels_version,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_pass       = $cloudera::params::cm_api_pass
) {

  exec { "parcels-available-remotely-$parcels_product":
    command   => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version\" > $cdh_metadata_dir/parcels-available-remotely-$parcels_product.json.output && grep AVAILABLE_REMOTELY $cdh_metadata_dir/parcels-available-remotely-$parcels_product.json.output",
    creates   => "$cdh_metadata_dir/parcels-available-remotely-$parcels_product.json.output",
    tries     => 3,
    try_sleep => 60,
    notify    => Exec["parcels-download-$parcels_product"]
  }

  exec { "parcels-download-$parcels_product":
    command     => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XPOST \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version/commands/startDownload\" > $cdh_metadata_dir/parcels-download-$parcels_product.json.output",
    cwd         => "/tmp",
    creates     => "$cdh_metadata_dir/parcels-download-$parcels_product.json.output",
    tries       => 3,
    try_sleep   => 60,
    notify      => Exec["parcels-downloading-$parcels_product"],
    refreshonly => true,
  }

  exec { "parcels-downloading-$parcels_product":
    command     => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version\" > $cdh_metadata_dir/parcels-downloading-$parcels_product.json.output && grep DOWNLOADING $cdh_metadata_dir/parcels-downloading-$parcels_product.json.output",
    creates     => "$cdh_metadata_dir/parcels-downloading-$parcels_product.json.output",
    tries       => 3,
    try_sleep   => 60,
    notify      => Exec["wait-download-complete-$parcels_product"],
    refreshonly => true,
  }

  exec { "wait-download-complete-$parcels_product":
    command     => "/usr/bin/curl -u $cm_api_user:$cm_api_pass -XGET \"http://$cm_api_host:$cm_api_port/api/v13/clusters/$cdh_cluster_name/parcels/products/$parcels_product/versions/$parcels_version\" | grep DOWNLOADED",
    tries       => 10,
    try_sleep   => 60,
    refreshonly => true,
  }
}

