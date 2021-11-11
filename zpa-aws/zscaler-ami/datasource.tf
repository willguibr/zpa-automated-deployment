data "aws_ami" "app_connector" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["3n2udvk6ba2lglockhnetlujo"]
  }

  owners = ["aws-marketplace"]
}

data "aws_region" "current" {}


// Retrieve Connector Enrollment Cert ID
data "zpa_enrollment_cert" "connector" {
  name = "Connector"
}

