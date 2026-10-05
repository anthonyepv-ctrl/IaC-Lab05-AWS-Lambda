data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_security_group" "upload_lambda" {
  name        = "upload-lambda-${terraform.workspace}"
  description = "SG de upload-lambda: sin entrada, salida 443 a S3 y SQS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "sg-upload-lambda-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "crop_lambda" {
  name        = "crop-lambda-${terraform.workspace}"
  description = "SG de crop-lambda: sin entrada, salida 443 a S3 y SQS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "sg-crop-lambda-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "vpce_sqs" {
  name        = "vpce-sqs-${terraform.workspace}"
  description = "SG del endpoint de SQS: entrada 443 desde las Lambdas"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "sg-vpce-sqs-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_vpc_security_group_egress_rule" "upload_to_s3" {
  security_group_id = aws_security_group.upload_lambda.id
  prefix_list_id    = data.aws_prefix_list.s3.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "crop_to_s3" {
  security_group_id = aws_security_group.crop_lambda.id
  prefix_list_id    = data.aws_prefix_list.s3.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "upload_to_vpce_sqs" {
  security_group_id            = aws_security_group.upload_lambda.id
  referenced_security_group_id = aws_security_group.vpce_sqs.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "crop_to_vpce_sqs" {
  security_group_id            = aws_security_group.crop_lambda.id
  referenced_security_group_id = aws_security_group.vpce_sqs.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "vpce_sqs_from_upload" {
  security_group_id            = aws_security_group.vpce_sqs.id
  referenced_security_group_id = aws_security_group.upload_lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "vpce_sqs_from_crop" {
  security_group_id            = aws_security_group.vpce_sqs.id
  referenced_security_group_id = aws_security_group.crop_lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}