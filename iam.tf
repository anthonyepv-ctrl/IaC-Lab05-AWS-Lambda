resource "aws_iam_role" "lambda_execution_role" {
  name = "image-processor-${terraform.workspace}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "iam-role-${terraform.workspace}"
    Environment = terraform.workspace
    Component   = "Security"
  }
}

resource "aws_iam_policy" "lambda_custom_policy" {
  name        = "image-processor-${terraform.workspace}-lambda-policy"
  description = "Permisos extraidos estrictamente del diagrama del profesor"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::image-processor-${terraform.workspace}-*-bucket",
          "arn:aws:s3:::image-processor-${terraform.workspace}-*-bucket/*"
        ]
      },
      # diagrama pide 3 sqs: ReceiveMessage, DeleteMessage y ChangeMessageVisibility (pita mira en la parte de crop-lamba)
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = [
          "arn:aws:sqs:us-east-1:*:image-processor-${terraform.workspace}-*"
        ]
      },

      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/image-processor-${terraform.workspace}-*:*"
        ]
      }
    ]
  })

  tags = {
    Name        = "iam-policy-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_custom_policy.arn
}
