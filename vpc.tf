# CREACIÓN DEL VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block[terraform.workspace]
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_${terraform.workspace}"
  }
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
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_public_subnet_a[terraform.workspace]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public_subnet_AZ-a_${terraform.workspace}"
  }
}

resource "aws_subnet" "public_subnet_AZ-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_public_subnet_b[terraform.workspace]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_subnet_AZ-b_${terraform.workspace}"
  }
}

resource "aws_subnet" "private_subnet_AZ-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_private_subnet_a[terraform.workspace]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_subnet_AZ-a_${terraform.workspace}"
  }
}

resource "aws_subnet" "private_subnet_AZ-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_private_subnet_b[terraform.workspace]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_subnet_AZ-b_${terraform.workspace}"
  }
}