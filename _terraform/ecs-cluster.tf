resource "aws_ecs_cluster" "board" {
  name = local.aws_ecs_cluster_name
}

resource "aws_autoscaling_group" "board-autoscaling" {
  name                = "${var.AWS_RESOURCE_PREFIX}-ecs-autoscaling"
  vpc_zone_identifier = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id, aws_subnet.main-public-3.id]

  min_size                  = "1"
  max_size                  = "10"
  desired_capacity          = "1"
  launch_configuration      = aws_launch_configuration.board.name
  health_check_grace_period = 120
  default_cooldown          = 30
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "ECS-Agent-${var.AWS_RESOURCE_PREFIX}"
    propagate_at_launch = true
  }
}



resource "aws_autoscaling_policy" "board-autoscaling-policy" {
  name                      = "${var.AWS_RESOURCE_PREFIX}-ecs-autoscaling-policy"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "90"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = aws_autoscaling_group.board-autoscaling.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}


resource "aws_launch_configuration" "board" {
  name_prefix     = "${var.AWS_RESOURCE_PREFIX}-launch-configuration"
  security_groups = [aws_security_group.instance-sg.id]

  key_name                    = aws_key_pair.kali.key_name
  image_id                    = var.ECS_AMI
  instance_type               = var.INSTANCE_TYPE
  iam_instance_profile        = aws_iam_instance_profile.ecs-ec2-role.id
  user_data                   = "#!/bin/bash\necho 'ECS_CLUSTER=board-cluster' >> /etc/ecs/ecs.config"
  associate_public_ip_address = true

  provisioner "local-exec" {
    command = "terraform output -raw ssh_private_key > ~/.ssh/${aws_key_pair.kali.key_name}.pem && chmod 400 ~/.ssh/${aws_key_pair.kali.key_name}.pem"
  }


  lifecycle {
    create_before_destroy = true
  }
}


resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kali" {
  key_name   = "kali"
  public_key = tls_private_key.tls.public_key_openssh
}
