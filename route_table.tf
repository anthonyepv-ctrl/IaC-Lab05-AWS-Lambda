resource "aws_route_table" "publico" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_subnet_AZ-a" {
  subnet_id      = aws_subnet.public_subnet_AZ-a.id
  route_table_id = aws_route_table.publico.id
}

resource "aws_route_table_association" "public_subnet_AZ-b" {
  subnet_id      = aws_subnet.public_subnet_AZ-b.id
  route_table_id = aws_route_table.publico.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
}

resource "aws_route_table_association" "private_subnet_AZ-a" {
  subnet_id      = aws_subnet.private_subnet_AZ-a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_subnet_AZ-b" {
  subnet_id      = aws_subnet.private_subnet_AZ-b.id
  route_table_id = aws_route_table.private_b.id
}