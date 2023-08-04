resource "aws_security_group_rule" "ephemeral-agent-1" {
  type              = "ingress"
  description       = "Allow ephemeral port from anywhere"
  from_port         = 32768
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance-sg.id
}

resource "aws_security_group_rule" "http-agent-2" {
  type              = "ingress"
  description       = "Allow ephemeral port from anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance-sg.id
}

resource "aws_security_group_rule" "ssh-agent-3" {
  type              = "ingress"
  description       = "Allow ephemeral port from anywhere"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.instance-sg.id
}

data "http" "myip" {
  url    = "http://ipv4.icanhazip.com"
  method = "GET"
}

resource "aws_security_group_rule" "http-alb-1" {
  type              = "ingress"
  description       = "Allow http port from anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "https-alb-2" {
  type              = "ingress"
  description       = "Allow https port from anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}



