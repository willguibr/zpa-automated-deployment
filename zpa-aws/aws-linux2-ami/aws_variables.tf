# aws variables
variable "aws-region" {
  description = "The AWS region."
  default     = ""
}

# IAM Policy Variables
variable "iam_policy" {
  description = "Zscaler_SSM_Policy"
  default     = "Zscaler_SSM_Policy"
  type        = string
}

variable "aws_iam_role" {
  description = "Zscaler_SSM_IAM_Role"
  default     = "Zscaler_SSM_IAM_Role"
  type        = string
}

# AWS KMS Key Variables
variable "description" {
  description = "Zscaler_KMS_Key"
  default     = ""
  type        = string
}

variable "multi_region" {
  description = "Enable Multi-Region KMS"
  default     = true
  type        = bool
}

variable "key_spec" {
  default = "SYMMETRIC_DEFAULT"
}

variable "enabled" {
  default = true
}

variable "rotation_enabled" {
  default = false
}

variable "kms_alias" {
  description = "KMS Alias"
  default     = "Zscaler_KMS_SSM"
  type        = string
}

# SSM Parameter Store
variable "secure_parameters" {
  description = "Secure Parameters"
  default     = "ZSDEMO"
  type        = string
}

variable "instance-type" {
  description = "App Connector Instance Type"
  default     = "t3.medium"
}

# VPC and Subnet Configuration
variable "vpc-cidr" {
  description = "VPC CIDR"
  default     = "10.1.0.0/16"
}

variable "subnet-count" {
  description = "Default number of worker subnets to create"
  default     = 1
}

variable "instance-per-subnet" {
  default = 1
}

variable "byo_eip_address" {
  default     = false
  type        = bool
  description = "Bring your own Elastic IP address for the NAT GW"
}

variable "nat_eip1_id" {
  default     = ""
  type        = string
  description = "User provided Elastic IP address ID for the NAT GW"
}

# Create Key Pair
variable "connector_key_pair" {
  default = ""
  type    = string
}

variable "public-key" {
  default = ""
  type    = string
}

# App Connector User Data
variable "user_data" {
  default = "user_data.sh"
  type    = string
}

