resource "aws_alb" "board-alb" {
  name            = "${var.AWS_RESOURCE_PREFIX}-alb"
  subnets         = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id, aws_subnet.main-public-3.id]
  security_groups = [aws_security_group.alb-sg.id]
  enable_http2    = "true"
  idle_timeout    = 100
  # 타임아웃 100초 설정
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.board-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.board.id
    type             = "forward"
  }
}


resource "aws_alb_target_group" "board" {
  name       = "board"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_alb.board-alb]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}
