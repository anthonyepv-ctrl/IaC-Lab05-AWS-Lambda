resource "aws_eip" "nat_a" {
  domain = "vpc"
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_subnet_AZ-a.id
  tags = {
    Name = "nat_a_${terraform.workspace}"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_subnet_AZ-b.id
  tags = {
    Name = "nat_b_${terraform.workspace}"
  }
  depends_on = [aws_internet_gateway.gw]
}