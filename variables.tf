variable "aws_region" {
  description = "AWS región donde se despliegua la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile IAM Identity Center para desplegar la infraestructura"
  type        = string
  default     = "admin"
}

variable "vpc_cidr_block" {
  description = "CIDR block para la VPC por entorno"
  type        = map(string)
  default = {
    dev  = "10.0.0.0/16"
    qa   = "10.1.0.0/16"
    prod = "10.2.0.0/16"
  }
}

variable "cidr_public_subnet_a" {
  description = "CIDR block para la subred pública en AZ-a"
  type        = map(string)
  default = {
    dev  = "10.0.1.0/24"
    qa   = "10.1.1.0/24"
    prod = "10.2.1.0/24"
  }
}

variable "cidr_public_subnet_b" {
  description = "CIDR block para la subred pública en AZ-b"
  type        = map(string)
  default = {
    dev  = "10.0.2.0/24"
    qa   = "10.1.2.0/24"
    prod = "10.2.2.0/24"
  }
}

variable "cidr_private_subnet_a" {
  description = "CIDR block para la subred privada en AZ-a"
  type        = map(string)
  default = {
    dev  = "10.0.11.0/24"
    qa   = "10.1.11.0/24"
    prod = "10.2.11.0/24"
  }
}

variable "cidr_private_subnet_b" {
  description = "CIDR block para la subred privada en AZ-b"
  type        = map(string)
  default = {
    dev  = "10.0.12.0/24"
    qa   = "10.1.12.0/24"
    prod = "10.2.12.0/24"
  }
}

variable "lambda_runtime" {
  description = "Runtime de las funciones Lambda"
  type        = string
  default     = "nodejs20.x"
}

variable "upload_lambda_memory" {
  description = "Memoria (MB) de la upload-lambda por entorno"
  type        = map(number)
  default = {
    dev  = 256
    qa   = 256
    prod = 256
  }
}

variable "crop_lambda_memory" {
  description = "Memoria (MB) de la crop-lambda por entorno"
  type        = map(number)
  default = {
    dev  = 512
    qa   = 512
    prod = 512
  }
}

variable "upload_lambda_timeout" {
  description = "Timeout (s) de la upload-lambda por entorno"
  type        = map(number)
  default = {
    dev  = 30
    qa   = 30
    prod = 30
  }
}

variable "crop_lambda_timeout" {
  description = "Timeout (s) de la crop-lambda por entorno"
  type        = map(number)
  default = {
    dev  = 60
    qa   = 60
    prod = 60
  }
}

variable "sqs_batch_size" {
  description = "Mensajes por lote que consume la crop-lambda"
  type        = map(number)
  default = {
    dev  = 5
    qa   = 5
    prod = 5
  }
}

variable "upload_prefix" {
  description = "Prefijo S3 de las imagenes originales"
  type        = string
  default     = "uploads/"
}

variable "processed_prefix" {
  description = "Prefijo S3 de las imagenes procesadas"
  type        = string
  default     = "processed/"
}
