
/*
aws_region                    = "ca-central-1"
aws_ami_app_connectors_owners = ["679593333241"] #Zscaler's account no they use to share the AMI

aws_app_connector_instance = [
  {
    aws_app_connector_name          = "Canada"
    aws_app_connector_description   = "Example Description"
    aws_app_connector_instance_type = "t3.small"
    aws_app_connector_sgs           = ["allow_app_connector_out_deny_all"]
    aws_app_connector_subnet_id     = "subnet-0c61a25afd30694ec" # Private 2b
    aws_app_connector_key_pair      = "aws_app_connector_key"
    aws_app_connector_user_data     = <<EOF
    #!/usr/bin/bash
            yum install unzip -y
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli-exe-linux-x86_64.zip
            unzip /tmp/awscli-exe-linux-x86_64.zip -d /tmp
            /tmp/aws/install
            REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region)
            URL="http://169.254.169.254/latest/meta-data/network/interfaces/macs/"
            MAC=$(curl $URL)
            URL=$URL$MAC"vpc-id/"
            VPC=$(curl $URL)
            key="ZSAC-"$REGION"-"$VPC
            aws ssm get-parameter --name $key --query Parameter.Value --with-decryption --region $REGION| tr -d '"' > /opt/zscaler/var/provision_key
            systemctl restart zpa-connector
    EOF
    aws_app_connector_public_ip     = false
  }
]

// Creating App Connector AWS Security Group Rules
aws_app_connector_security_groups = [
  {
    aws_app_connector_sg_name        = "allow_app_connector_out_deny_all"
    aws_app_connector_sg_description = "Allows only meta traffic out. Blocks all other out/in"
    aws_app_connector_sg_vpc_id      = "vpc-09d234a1103696aac"
    aws_app_connector_sg_ingress_rules = [
      {
        ingress_rule_description = "Allow SSH Management Inbound. TCP 22"
        ingress_rule_from_port   = 22
        ingress_rule_to_port     = 22
        ingress_rule_protocol    = "tcp"
        ingress_rule_cidr_blocks = ["0.0.0.0/0"]
      },
      {
        ingress_rule_description = "Allow app connector keep alive inbound. ICMP"
        ingress_rule_from_port   = -1
        ingress_rule_to_port     = -1
        ingress_rule_protocol    = "icmp"
        ingress_rule_cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    aws_app_connector_sg_egress_rules = [
      {
        egress_rule_description = "Allow app connector tunneling outbound. TCP 443"
        egress_rule_from_port   = 443
        egress_rule_to_port     = 443
        egress_rule_protocol    = "tcp"
        egress_rule_cidr_blocks = ["0.0.0.0/0"]
      },
      {
        egress_rule_description = "Allow app connector keep alive outbound. ICMP"
        egress_rule_from_port   = -1
        egress_rule_to_port     = -1
        egress_rule_protocol    = "icmp"
        egress_rule_cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
]

// Use AWS Key Pair
aws_key_pairs = [
  {
    aws_key_name   = "aws_app_connector_key"
    aws_key_public = "" # Insert Public Key
  }
]

aws_secure_parameters = [
  {
    aws_secure_parameters_name_prefix   = "connector"
    aws_secure_parameters_type = "SecureString"
    aws_secure_parameters_key_id = "KMS key Zscaler Provisioning Key"
    aws_secure_parameters_value = "AWS Canada Provisioning Key"
    aws_secure_parameters_tags = {
      environment = "development"
    }

  }
]
//   aws_secure_parameters_overwrite = true
// aws_secure_parameters_tags =

/*
aws_kms_key = [
  {
    aws_kms_key_description   = "KMS key Zscaler Provisioning Key"
    aws_kms_key_customer_master_key_spec = "SYMMETRIC_DEFAULT"
    aws_kms_key_key_usage = "ENCRYPT_DECRYPT"
    aws_kms_key_deletion_window_in_days = 30
    aws_kms_key_is_enabled = true
    aws_kms_key_enable_key_rotation = true
  }
]
//    aws_kms_key_key_policy = "Zscaler_SSM_Policy"

aws_kms_alias = [
  {
    aws_kms_key_alias_name   = "alias/Zscaler_KMS_SSM"
    aws_kms_target_key_id = aws_kms_key.key_id
  }
]

// Creating App Connector Group in Zscaler Private Access Portal
zpa_app_connector_group = [
  {
    zpa_app_connector_group_name                     = "AWS Canada Connector Group"
    zpa_app_connector_group_description              = "AWS Canada Connector Group"
    zpa_app_connector_group_enabled                  = true
    zpa_app_connector_group_city_country             = "Toronto, CA"
    zpa_app_connector_group_country_code             = "CA"
    zpa_app_connector_group_latitude                 = "43.6532"
    zpa_app_connector_group_longitude                = "-79.3832"
    zpa_app_connector_group_location                 = "Toronto, ON, CA"
    zpa_app_connector_group_upgrade_day              = "SUNDAY"
    zpa_app_connector_group_upgrade_time_in_secs     = "66600"
    zpa_app_connector_group_override_version_profile = true
    zpa_app_connector_group_version_profile_id       = 0
    zpa_app_connector_group_dns_query_type           = "IPV4"
  }
]

/*
// Create Zscaler Provisioning Key
zpa_provisioning_key = [
  {
    zpa_provisioning_key_name                           = "AWS Canada Provisioning Key"
    zpa_provisioning_key_association_type               = "CONNECTOR_GRP"
    zpa_provisioning_key_association_max_usage          = "10"
    zpa_provisioning_key_association_enrollment_cert_id = "Connector"
    zpa_provisioning_key_association_zcomponent_id      = "AWS Canada Connector Group"
  }
]
*/