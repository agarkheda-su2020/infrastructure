resource "aws_vpc" "Ass4_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "Ass4_vpc"
  }
}


resource "aws_subnet" "subnet1" {
    cidr_block              = var.subnet1_cidr
    vpc_id                  =aws_vpc.Ass4_vpc.id
    availability_zone       = var.s1az
    map_public_ip_on_launch = true

    tags={
        Name="a4_subnet_us-east-1a"
    }
}

resource "aws_subnet" "subnet2" {
    cidr_block              = var.subnet2_cidr
    vpc_id                  =aws_vpc.Ass4_vpc.id
    availability_zone       = var.s2az
    map_public_ip_on_launch = true

    tags={
        Name="Ass4_subnet_us-east-1b"
    }
}

resource "aws_subnet" "subnet3" {
    cidr_block              = var.subnet3_cidr
    vpc_id                  =aws_vpc.Ass4_vpc.id
    availability_zone       = var.s3az
    map_public_ip_on_launch = true

    tags={
        Name="Ass4_subnet_us-east-1c"
    }
}



resource "aws_internet_gateway" "Ass4_internet_gateway" {
  vpc_id = aws_vpc.Ass4_vpc.id

  tags = {
    Name = "Ass4_internet_gateway"
  }
}

resource "aws_route_table" "Ass4_route_table" {
  vpc_id = aws_vpc.Ass4_vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Ass4_internet_gateway.id
  }

  tags = {
    Name = "Ass4_route_table"
  }
}

resource "aws_route_table_association" "routeTosubnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.Ass4_route_table.id
}

resource "aws_route_table_association" "routeTosubnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.Ass4_route_table.id
}

resource "aws_route_table_association" "routeTosubnet3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.Ass4_route_table.id
}