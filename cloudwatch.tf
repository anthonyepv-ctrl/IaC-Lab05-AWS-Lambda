resource "aws_cloudwatch_log_group" "upload_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.upload.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "crop_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.crop.function_name}"
  retention_in_days = 14
}

resource "aws_sns_topic" "dlq_alarm_topic" {
  name = "image-processor-${terraform.workspace}-dlq-alarm"
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "dlq-messages-alarm-${terraform.workspace}"
  alarm_description   = "Alerta cuando hay mensajes visibles en la DLQ"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.image_dlq.name
  }

  alarm_actions = [aws_sns_topic.dlq_alarm_topic.arn]
}
