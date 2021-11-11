resource "aws_iam_policy" "zscaler_ssm_policy" {
  name        = var.iam_policy
  description = var.iam_policy
  policy      = data.aws_iam_policy_document.ssm_key_policy.json
}