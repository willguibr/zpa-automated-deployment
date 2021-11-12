data "aws_ami" "app_connector" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

data "aws_region" "current" {}


# SSM and KMS Policy Document
data "aws_iam_policy_document" "zscaler_ssm_kms_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:ListKeys",
      "tag:GetResources",
      "kms:ListAliases",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/ZSDEMO*"]
  }
}

data "aws_iam_policy_document" "app_connector_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = ""
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create IAM Policy
resource "aws_iam_policy" "zscaler_ssm_kms_policy" {
  name        = var.iam_policy
  description = var.iam_policy
  policy      = data.aws_iam_policy_document.zscaler_ssm_kms_policy.json
}

# Create IAM Role
resource "aws_iam_role" "zscaler_iam_role" {
  name               = var.aws_iam_role
  assume_role_policy = data.aws_iam_policy_document.app_connector_assume_role.json
}

# Create IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "zscaler_ssm_kms_policy_attachment" {
  role       = aws_iam_role.zscaler_iam_role.name
  policy_arn = aws_iam_policy.zscaler_ssm_kms_policy.arn
}

# Create Instance Profile
resource "aws_iam_instance_profile" "app_connector_profile" {
  name = "${var.name-prefix}-app_connector_profile-${var.resource-tag}"
  role = aws_iam_role.zscaler_iam_role.name
}

# Creates/manages KMS CMK
resource "aws_kms_key" "zscaler_ssm_kms" {
  description              = var.description
  deletion_window_in_days  = var.customer_master_key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled
  multi_region             = var.multi_region
}

# Add an alias to the key
resource "aws_kms_alias" "zscaler_kms_alias" {
  name          = "alias/${var.kms_alias}"
  target_key_id = aws_kms_key.zscaler_ssm_kms.key_id
}

# Create Parameter Store
resource "aws_ssm_parameter" "secret" {
  name        = "${var.secure_parameters}-${var.aws-region}-${aws_vpc.vpc1.id}"
  description = var.secure_parameters
  type        = "SecureString"
  value       = zpa_provisioning_key.aws_provisioning_key.provisioning_key
}

// Create AWS Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = var.connector_key_pair
  public_key = var.public-key
}

resource "aws_instance" "app_connector_instance" {
  ami                         = data.aws_ami.app_connector.id
  instance_type               = var.instance-type
  iam_instance_profile        = aws_iam_instance_profile.app_connector_profile.name
  vpc_security_group_ids      = [aws_security_group.appconnector-node-sg.id]
  subnet_id                   = aws_subnet.pubsubnet1.0.id
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  user_data                   = file(var.user_data)
}

resource "aws_security_group" "appconnector-node-sg" {
  name        = "${var.name-prefix}-appconnector-node-sg-${var.resource-tag}"
  description = "Security group for all App Connector nodes in the cluster"
  vpc_id      = aws_vpc.vpc1.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "all-vpc-ingress-ec" {
  description       = "Allow all VPC traffic"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.appconnector-node-sg.id
  cidr_blocks       = [aws_vpc.vpc1.cidr_block]
  type              = "ingress"
}

resource "aws_security_group_rule" "appconnector-node-ingress-ssh" {
  description       = "Allow SSH to App Connector VM"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.appconnector-node-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}

# 1. Network Creation
data "aws_availability_zones" "available" {
  state = "available"
}

#VPCs
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true

}

#Subnets
resource "aws_subnet" "pubsubnet1" {
  count = 1

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc1.cidr_block, 8, count.index + 101)
  vpc_id            = aws_vpc.vpc1.id
}

resource "aws_subnet" "connector-service-subnet" {
  count = var.subnet-count

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc1.cidr_block, 8, count.index + 1)
  vpc_id            = aws_vpc.vpc1.id
}

#IGW
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id
}

#IGW Route Table
resource "aws_route_table" "routetablepublic1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
}

#Route Table Association for public subnet
resource "aws_route_table_association" "routetablepublic1" {
  count = 1

  subnet_id      = aws_subnet.pubsubnet1.*.id[count.index]
  route_table_id = aws_route_table.routetablepublic1.id
}

#NATGW
resource "aws_eip" "eip1" {
  count      = var.byo_eip_address == false ? 1 : 0
  vpc        = true
  depends_on = [aws_internet_gateway.igw1]
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id = var.byo_eip_address == false ? aws_eip.eip1.*.id[0] : var.nat_eip1_id
  subnet_id     = aws_subnet.pubsubnet1.0.id
  depends_on    = [aws_internet_gateway.igw1]
}