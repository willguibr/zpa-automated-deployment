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