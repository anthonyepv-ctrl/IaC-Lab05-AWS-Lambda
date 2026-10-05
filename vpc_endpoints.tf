resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id,
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:PutObject"]
        Resource  = "${aws_s3_bucket.images.arn}/*"
      }
    ]
  })

  tags = {
    Name        = "vpce-s3-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_subnet_AZ-a.id,
    aws_subnet.private_subnet_AZ-b.id,
  ]

  security_group_ids = [aws_security_group.vpce_sqs.id]

  tags = {
    Name        = "vpce-sqs-${terraform.workspace}"
    Environment = terraform.workspace
  }
}