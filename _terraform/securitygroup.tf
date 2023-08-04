resource "aws_security_group" "instance-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "instance-sg"
  description = "security group for ECS instance"

  ingress {
    protocol        = "tcp"
    from_port       = 32768
    to_port         = 65535
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.alb-sg.id]
    cidr_blocks     = ["${chomp(data.http.myip.response_body)}/32"]
  }

  tags = {
    Name = "instance-sg"
  }
}

resource "aws_security_group_rule" "instance-outbound" {
  type              = "egress"
  description       = "Allow to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance-sg.id
}

resource "aws_security_group" "alb-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "alb-sg"
  description = "security group for alb"

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group_rule" "alb-inbound-80" {
  type              = "ingress"
  description       = "Allow http port from anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "alb-inbound-443" {
  type              = "ingress"
  description       = "Allow https port from anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "alb-outbound" {
  type              = "egress"
  description       = "Allow to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id

}


data "http" "myip" {
  url    = "http://ipv4.icanhazip.com"
  method = "GET"
}
