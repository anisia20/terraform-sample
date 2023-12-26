provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_vpc" "themore-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "themore-vpc"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.themore-vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"
}

resource "aws_subnet" "public-c" {
  vpc_id                  = aws_vpc.themore-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
}

resource "aws_subnet" "private-a" {
  vpc_id                  = aws_vpc.themore-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"
}

resource "aws_subnet" "private-c" {
  vpc_id                  = aws_vpc.themore-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
}


resource "aws_internet_gateway" "themore-igw" {
  vpc_id = aws_vpc.themore-vpc.id
  tags = {
    Name = "themore-internet-gateway"
  }
}


resource "aws_default_route_table" "public-route_table" {
  default_route_table_id = aws_vpc.themore-vpc.default_route_table_id
  tags = {
    Name = "default"
  }
}

resource "aws_route" "internet-gw-route" {
  route_table_id         = aws_vpc.themore-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.themore-igw.id
}

resource "aws_eip" "themore-nat-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.themore-igw]
}

resource "aws_nat_gateway" "prac-nat" {
  allocation_id = aws_eip.themore-nat-eip.id
  subnet_id     = aws_subnet.public-a.id
  depends_on    = [aws_internet_gateway.themore-igw]
}

resource "aws_route_table" "themore-private-route-table" {
  vpc_id = aws_vpc.themore-vpc.id
  tags = {
    Name = "private"
  }
}


resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.themore-private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.prac-nat.id
}

resource "aws_route_table_association" "public_subneta_association" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_vpc.themore-vpc.main_route_table_id
}

resource "aws_route_table_association" "public_subnetb_association" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_vpc.themore-vpc.main_route_table_id
}

resource "aws_route_table_association" "private_subneta_association" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.themore-private-route-table.id
}

resource "aws_route_table_association" "private_subnetb_association" {
  subnet_id      = aws_subnet.private-c.id
  route_table_id = aws_route_table.themore-private-route-table.id
}
