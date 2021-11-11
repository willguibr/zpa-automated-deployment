# 0. Random
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

// Create AWS Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "${var.name-prefix}-key-${random_string.suffix.result}"
  public_key = var.public-key
}

resource "local_file" "random_string" {
  content  = random_string.suffix.result
  filename = "random_string"

  depends_on = [
    aws_key_pair.deployer,
  ]
}

resource "local_file" "name-prefix" {
  content  = var.name-prefix
  filename = "name_prefix"

  depends_on = [
    aws_key_pair.deployer,
  ]
}

/*
# rename the ssh key files to match the keyname
resource "null_resource" "rename_sshkey_files" {
  provisioner "local-exec" {
    command = "mv local.pem ${var.name-prefix}-key-${random_string.suffix.result}.pem && mv local.pem.pub ${var.name-prefix}-key-${random_string.suffix.result}.pem.pub"
  }

  depends_on = [
    aws_key_pair.deployer,
  ]
}
*/
resource "aws_instance" "app_connector_instance" {
  ami                         = data.aws_ami.app_connector.id
  instance_type               = var.instance-type
  iam_instance_profile        = aws_iam_instance_profile.app_connector_profile.name
  vpc_security_group_ids      = [aws_security_group.appconnector-node-sg.id]
  subnet_id                   = aws_subnet.pubsubnet1.0.id
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  // user_data = "${file("user_data.sh")}"
  user_data                   = file("user_data.sh")
}

