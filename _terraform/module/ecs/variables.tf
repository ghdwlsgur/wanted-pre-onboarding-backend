variable "aws_subnet" {
  type = map(string)
}

variable "AWS_RESOURCE_PREFIX" {
  type = string
}

variable "AWS_REGION" {
  type = string
}

variable "aws_security_group-instance_sg" {
  type = string
}

variable "aws_ecs_cluster_name" {
  type = string
}

variable "aws_alb_target_group" {
  type = string
}

variable "INSTANCE_TYPE" {
  type = string
}

variable "ECS_AMI" {
  type = string
}

variable "key_name" {}
variable "private_key_openssh" {}
variable "private_key_pem" {}
