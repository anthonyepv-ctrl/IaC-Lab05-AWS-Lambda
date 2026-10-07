output "api_url" {
  description = "URL base del API Gateway (usar en POST /upload)"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

