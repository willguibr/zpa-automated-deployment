# Creates/manages KMS CMK
resource "aws_kms_key" "key" {
  description              = var.description
  customer_master_key_spec = var.key_spec
  deletion_window_in_days  = var.customer_master_key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled
  multi_region             = var.multi_region
}

# Add an alias to the key
resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.kms_alias}"
  target_key_id = aws_kms_key.key.key_id
}