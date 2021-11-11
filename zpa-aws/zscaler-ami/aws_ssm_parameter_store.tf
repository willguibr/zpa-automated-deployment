# Create Parameter Store
resource "aws_ssm_parameter" "secret" {
  name        = var.secure_parameters
  description = var.secure_parameters
  type        = "SecureString"
  value       = zpa_provisioning_key.aws_provisioning_key.provisioning_key
}