resource "aws_cloudwatch_log_group" "board" {
  name              = "/${var.AWS_RESOURCE_PREFIX}"
  retention_in_days = 30
}


module "ecs_service_alarms" {
  namespace                             = var.AWS_RESOURCE_PREFIX
  source                                = "cloudposse/ecs-cloudwatch-sns-alarms/aws"
  stage                                 = "production"
  name                                  = "${var.AWS_RESOURCE_PREFIX}-ecs-alarms"
  cluster_name                          = local.aws_ecs_cluster_name
  service_name                          = local.aws_ecs_service_name
  memory_utilization_high_alarm_actions = [aws_sns_topic.send-alert-message.arn]
  memory_utilization_high_ok_actions    = [aws_sns_topic.send-alert-message.arn]
  cpu_utilization_high_alarm_actions    = [aws_sns_topic.send-alert-message.arn]
  cpu_utilization_high_ok_actions       = [aws_sns_topic.send-alert-message.arn]
}
