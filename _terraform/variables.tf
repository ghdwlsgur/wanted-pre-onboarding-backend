variable "ECS_AMI" {
  type    = string
  default = "ami-06fe22c49e23a8c81" # ECS Optimized AMI 
}
variable "INSTANCE_TYPE" {
  type    = string
  default = "c5a.4xlarge" # 16vCPU 32GiB
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

# terraform.tfvars
variable "MYSQL_PASSWORD" {}
variable "JWT_SECRET_KEY" {}

locals {
  aws_ecr_repository_name = var.AWS_RESOURCE_PREFIX
  aws_ecs_cluster_name    = "${var.AWS_RESOURCE_PREFIX}-cluster"
  aws_ecs_service_name    = "${var.AWS_RESOURCE_PREFIX}-service"
}

