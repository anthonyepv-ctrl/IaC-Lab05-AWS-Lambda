# CREACIÓN DEL VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#CREACIÓN DEL INTERNET GATEWAY

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw_${terraform.workspace}"
  }
}

# REGIONES DISPONIBLES (AZ)

data "aws_availability_zones" "available" {
  state = "available"
}

#CREACIÓN DE SUBNETS PÚBLICAS Y PRIVADAS

resource "aws_subnet" "public_subnet_AZ-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_AZ-b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_AZ-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "private_subnet_AZ-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}