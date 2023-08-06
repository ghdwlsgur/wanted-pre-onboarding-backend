variable "ECS_AMI" {
  type    = string
  default = "ami-06fe22c49e23a8c81" # ECS Optimized AMI 
}
variable "INSTANCE_TYPE" {
  type    = string
  default = "t2.medium" # 2vCPU 4GiB
}
variable "AWS_REGION" {
  type    = string
  default = "ap-northeast-2"
}
variable "AWS_RESOURCE_PREFIX" {
  type    = string
  default = "board"
}
variable "EMAIL" {
  type    = string
  default = "redmax45@naver.com"
}

variable "AWS_PROFILE" {
  type    = string
  default = "default"
}

# terraform.tfvars 파일 내 선언
variable "MYSQL_PASSWORD" {}
variable "JWT_SECRET_KEY" {}
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

locals {
  aws_ecr_repository_name = var.AWS_RESOURCE_PREFIX
  aws_ecs_cluster_name    = "${var.AWS_RESOURCE_PREFIX}-cluster"
  aws_ecs_service_name    = "${var.AWS_RESOURCE_PREFIX}-service"
}

