define cloudera::parcels::config (
  $cdh_metadata_dir  = $cloudera::params::cdh_metadata_dir,
  $cm_api_host       = $cloudera::params::cm_api_host,
  $cm_api_port       = $cloudera::params::cm_api_port,
  $cm_api_user       = $cloudera::params::cm_api_user,
  $cm_api_password   = $cloudera::params::cm_api_password,
  $items_config      = $cloudera::params::items_config,
  $parcels_product   = $title
) {

  file { "parcels-config.json":
    ensure  => $file_ensure,
    path    => "/tmp/parcels-config.json",
    content => template("${module_name}/config.json.erb")
  }

  exec { "parcels-config-$parcels_product":
    command => "/usr/bin/curl -H 'Content-Type: application/json' -u $cm_api_user:$cm_api_password -XPUT \"http://$cm_api_host:$cm_api_port/api/v13/cm/config\" -d @parcels-config.json > $cdh_metadata_dir/parcels-config-$parcels_product.json.output",
    cwd     => "/tmp",
    creates => "$cdh_metadata_dir/parcels-config-$parcels_product.json.output",
    tries   => 3,
    try_sleep => 60,
    require => File["parcels-config.json"]
  }

}
