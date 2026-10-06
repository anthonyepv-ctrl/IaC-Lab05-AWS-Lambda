output "api_url" {
  description = "URL base del API Gateway (usar en POST /upload)"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "bucket_name" {
  description = "Nombre del bucket S3 de imagenes"
  value       = aws_s3_bucket.images.id
}

output "queue_url" {
  description = "URL de la cola SQS principal"
  value       = aws_sqs_queue.image_queue.id
}

output "dlq_url" {
  description = "URL de la Dead-Letter Queue"
  value       = aws_sqs_queue.image_dlq.id
}

output "upload_lambda_name" {
  description = "Nombre de la funcion Lambda de subida"
  value       = aws_lambda_function.upload.function_name
}

output "crop_lambda_name" {
  description = "Nombre de la funcion Lambda de recorte"
  value       = aws_lambda_function.crop.function_name
}
