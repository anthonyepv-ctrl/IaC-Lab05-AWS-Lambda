data "archive_file" "upload_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/upload-lambda"
  output_path = "${path.module}/build/upload-function.zip"
}

data "archive_file" "crop_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/crop-lambda"
  output_path = "${path.module}/build/crop-function.zip"
}

resource "aws_lambda_function" "upload" {
  function_name    = "image-processor-${terraform.workspace}-upload"
  filename         = data.archive_file.upload_zip.output_path
  source_code_hash = data.archive_file.upload_zip.output_base64sha256
  role             = aws_iam_role.upload_lambda.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  architectures    = ["x86_64"]
  memory_size      = var.upload_lambda_memory[terraform.workspace]
  timeout          = var.upload_lambda_timeout[terraform.workspace]

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.images.id
      UPLOAD_PREFIX = var.upload_prefix
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_AZ-a.id, aws_subnet.private_subnet_AZ-b.id]
    security_group_ids = [aws_security_group.upload_lambda.id]
  }

  tags = {
    Name        = "upload-lambda-${terraform.workspace}"
    Environment = terraform.workspace
  }
  depends_on = [aws_iam_role_policy_attachment.upload_vpc_exec]
}

resource "aws_lambda_function" "crop" {
  function_name    = "image-processor-${terraform.workspace}-crop"
  filename         = data.archive_file.crop_zip.output_path
  source_code_hash = data.archive_file.crop_zip.output_base64sha256
  role             = aws_iam_role.crop_lambda.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  architectures    = ["x86_64"]
  memory_size      = var.crop_lambda_memory[terraform.workspace]
  timeout          = var.crop_lambda_timeout[terraform.workspace]

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.id
      PROCESSED_PREFIX = var.processed_prefix
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_AZ-a.id, aws_subnet.private_subnet_AZ-b.id]
    security_group_ids = [aws_security_group.crop_lambda.id]
  }

  tags = {
    Name        = "crop-lambda-${terraform.workspace}"
    Environment = terraform.workspace
  }
  depends_on = [aws_iam_role_policy_attachment.crop_vpc_exec]
}

resource "aws_lambda_event_source_mapping" "crop_sqs" {
  event_source_arn        = aws_sqs_queue.image_queue.arn
  function_name           = aws_lambda_function.crop.arn
  batch_size              = var.sqs_batch_size[terraform.workspace]
  function_response_types = ["ReportBatchItemFailures"]
  enabled                 = true

  depends_on = [aws_iam_role_policy.crop_s3_sqs]
}
