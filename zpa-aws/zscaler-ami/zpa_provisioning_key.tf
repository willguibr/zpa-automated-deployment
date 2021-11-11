// Create Provisioning Key for App Connector Group
resource "zpa_provisioning_key" "aws_provisioning_key" {
  name               = var.zpa_provisioning_key_name
  association_type   = var.zpa_provisioning_key_association_type
  max_usage          = var.zpa_provisioning_key_max_usage
  enrollment_cert_id = data.zpa_enrollment_cert.connector.id
  zcomponent_id      = zpa_app_connector_group.canada_connector_group.id
  depends_on = [
    aws_instance.app_connector_instance,
    zpa_app_connector_group.canada_connector_group
  ]
}