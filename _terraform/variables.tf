
variable "ECS_AMI" { default = "ami-0e00e602389e469a3" }
variable "INSTANCE_TYPE" { default = "c5a.4xlarge" } # 16vCPU 32GiB
variable "AWS_REGION" { default = "eu-central-1" }
variable "AWS_RESOURCE_PREFIX" { default = "board" }
variable "EMAIL" { default = "redmax45@naver.com" }

variable "MYSQL_PASSWORD" {}
variable "JWT_SECRET_KEY" {}

locals {
  aws_ecr_repository_name = var.AWS_RESOURCE_PREFIX
  aws_ecs_cluster_name    = "${var.AWS_RESOURCE_PREFIX}-cluster"
  aws_ecs_service_name    = "${var.AWS_RESOURCE_PREFIX}-service"
}

