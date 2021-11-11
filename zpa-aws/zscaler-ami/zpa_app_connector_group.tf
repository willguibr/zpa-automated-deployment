resource "zpa_app_connector_group" "canada_connector_group" {
  name                     = var.zpa_app_connector_group_name
  description              = var.zpa_app_connector_group_description
  enabled                  = var.zpa_app_connector_group_enabled
  city_country             = var.zpa_app_connector_group_city_country
  country_code             = var.zpa_app_connector_group_country_code
  latitude                 = var.zpa_app_connector_group_latitude
  longitude                = var.zpa_app_connector_group_longitude
  location                 = var.zpa_app_connector_group_location
  upgrade_day              = var.zpa_app_connector_group_upgrade_day
  upgrade_time_in_secs     = var.zpa_app_connector_group_upgrade_time_in_secs
  override_version_profile = var.zpa_app_connector_group_override_version_profile
  version_profile_id       = var.zpa_app_connector_group_version_profile_id
  dns_query_type           = var.zpa_app_connector_group_dns_query_type
}