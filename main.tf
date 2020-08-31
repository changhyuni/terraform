# Create VPC
resource "aws_vpc" "PR-TEST-VPC" {
  cidr_block = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = merge(var.tags, map("Name", format("%s", var.name)))
}

# Create Public Subnet
resource "aws_subnet" "PR-TEST-PUBSUB" {
  count = length(var.public_subnets)
  cidr_block = var.public_subnets[count.index]
  vpc_id = aws_vpc.PR-TEST-VPC.id
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, map("Name", format("%s", var.name)))
}

# Create Private Subnet
resource "aws_subnet" "PR-TEST-PRISUB" {
  count = length(var.private_subnets)
  cidr_block = var.private_subnets[count.index]
  vpc_id = aws_vpc.PR-TEST-VPC.id
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, map("Name", format("%s", var.name)))
}

# Create IGW
resource "aws_internet_gateway" "PR-TEST-IGW" {
  vpc_id = aws_vpc.PR-TEST-VPC.id

  tags = {
    Name = "IGW"
  }
}

# Create EIP for Nat Gateway
resource "aws_eip" "EIP" {
  count = length(var.azs)
  vpc = true
}

# Create Nat Gateway
resource "aws_nat_gateway" "PR-TEST-NG" {
  count = length(var.azs)

  allocation_id = aws_eip.EIP.*.id[count.index]
  subnet_id = aws_subnet.PR-TEST-PUBSUB.*.id[count.index]
}


# Create Public Route Table
resource "aws_route_table" "PR-TEST-PUBROUTE" {
  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PR-TEST-IGW.id
  }
}

# Create Private Route Table
resource "aws_route_table" "PR-TEST-PRIROUTE" {
  count = length(aws_nat_gateway.PR-TEST-NG)

  vpc_id = aws_vpc.PR-TEST-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.PR-TEST-NG.*.id[count.index]
  }
}

# Create Public Route Table Routing
resource "aws_route_table_association" "PR-TEST-PUBROUTING" {
  count = length(aws_subnet.PR-TEST-PUBSUB)

  route_table_id = aws_route_table.PR-TEST-PUBROUTE.id
  subnet_id = aws_subnet.PR-TEST-PUBSUB.*.id[count.index]
}

# Create Private Route Table Routing
resource "aws_route_table_association" "PR-TEST-PRIROUTING"{
  count = length(aws_subnet.PR-TEST-PRISUB)

  route_table_id = aws_route_table.PR-TEST-PRIROUTE.*.id[count.index]
  subnet_id = aws_subnet.PR-TEST-PRISUB.*.id[count.index]
}
