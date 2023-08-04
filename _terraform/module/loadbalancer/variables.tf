variable "aws_subnet" {
  type = map(string)
}

variable "aws_vpc" {
  type = string
}

variable "aws_security_group-alb_sg" {
  type = string
}

variable "AWS_REGION" {
  type = string
}

variable "AWS_RESOURCE_PREFIX" {
  type = string
}
