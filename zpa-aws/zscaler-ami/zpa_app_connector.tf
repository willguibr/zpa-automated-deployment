// Retrieve Connector Enrollment Cert ID
data "zpa_enrollment_cert" "connector" {
  name = "Connector"
}

# Create App Connector Group
resource "zpa_app_connector_group" "aws_connector_group" {
  name                     = "${var.aws-region}-${aws_vpc.vpc1.id}"
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

// Create Provisioning Key for App Connector Group
resource "zpa_provisioning_key" "aws_provisioning_key" {
  name               = "${var.aws-region}-${aws_vpc.vpc1.id}"
  association_type   = var.zpa_provisioning_key_association_type
  max_usage          = var.zpa_provisioning_key_max_usage
  enrollment_cert_id = data.zpa_enrollment_cert.connector.id
  zcomponent_id      = zpa_app_connector_group.aws_connector_group.id
  depends_on = [
    aws_instance.app_connector_instance,
    zpa_app_connector_group.aws_connector_group
  ]
}