resource "aws_iam_role" "zscler_iam_role" {
  name               = var.aws_iam_role
  assume_role_policy = data.aws_iam_policy_document.app_connector_role_policy.json
}

resource "aws_iam_role_policy_attachment" "zscaler_policy_attachment" {
  role       = aws_iam_role.zscler_iam_role.name
  policy_arn = aws_iam_policy.zscaler_ssm_policy.arn
}

resource "aws_iam_instance_profile" "app_connector_profile" {
  name = "${var.name-prefix}-app_connector_profile-${var.resource-tag}"
  role = aws_iam_role.zscler_iam_role.name
}