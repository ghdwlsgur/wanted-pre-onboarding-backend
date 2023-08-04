resource "aws_ecs_service" "board" {
  name            = "board"
  cluster         = aws_ecs_cluster.board.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_role_policy_attachment.ecs-service-attach]

  load_balancer {
    target_group_arn = aws_alb_target_group.board.id
    container_name   = "nginx"
    container_port   = "80"
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

// 로드밸런서에 연결하기 위한 태스크 생성
resource "aws_ecs_task_definition" "nginx" {
  family = "nginx"

  container_definitions = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:latest",  
    "portMappings": [
      {
        "hostPort": 0,
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "cpu": 256,
    "memory": 512,    
    "essential": true,    
    "logConfiguration": {
    "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/${var.AWS_RESOURCE_PREFIX}",
        "awslogs-region": "${var.AWS_REGION}",
        "awslogs-stream-prefix": "ecs-nginx"
      }
    }        
  }
]
EOF
}

