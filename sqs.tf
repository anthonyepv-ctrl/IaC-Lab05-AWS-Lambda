resource "aws_sqs_queue" "image_dlq" {
  name                      = "image-processor-${terraform.workspace}-image-dlq"
  message_retention_seconds = 1209600 # 14 días
}

resource "aws_sqs_queue" "image_queue" {
  name                       = "image-processor-${terraform.workspace}-image-queue"
  visibility_timeout_seconds = 360   # 6 x timeout de Lambda Crop (60 s)
  message_retention_seconds  = 86400 # 1 día
  receive_wait_time_seconds  = 20    # Long polling
}

resource "aws_sqs_queue_redrive_policy" "image_queue_redrive" {
  queue_url = aws_sqs_queue.image_queue.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "image_queue_policy" {
  queue_url = aws_sqs_queue.image_queue.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowS3SendMessage"
        Effect = "Allow"

        Principal = {
          Service = "s3.amazonaws.com"
        }

        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.image_queue.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.images.arn
          }
        }
      }
    ]
  })
}