data "aws_iam_policy_document" "ssm_key_policy" {
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

data "aws_iam_policy_document" "app_connector_role_policy" {
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