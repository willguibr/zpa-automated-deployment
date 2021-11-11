data "aws_ami" "app_connector" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

data "aws_region" "current" {}

// Retrieve Connector Enrollment Cert ID
data "zpa_enrollment_cert" "connector" {
  name = "Connector"
}

