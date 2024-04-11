data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_custom_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_eip" "nat_eip" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public.id
}

resource "aws_route_table" "private_custom_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_route_table_association" "public_crt_public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_custom_route_table.id
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
#  map_public_ip_on_launch = true

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_route_table_association" "private_crt_private_subnet" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private_custom_route_table.id
}
