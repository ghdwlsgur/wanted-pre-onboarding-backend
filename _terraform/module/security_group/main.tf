resource "aws_security_group" "instance-sg" {
  vpc_id      = var.aws_vpc
  name        = "instance-sg"
  description = "security group for EC2 (ECS Agent)"

  tags = {
    Name = "ecs-agent-sg"
  }
}

resource "aws_security_group" "alb-sg" {
  vpc_id      = var.aws_vpc
  name        = "alb-sg"
  description = "security group for alb"

  tags = {
    Name = "alb-sg"
  }
}

