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