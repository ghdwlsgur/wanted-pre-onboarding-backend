
module "ecs" {
  source                         = "./module/ecs"
  aws_subnet                     = module.network.aws_subnet
  aws_security_group-instance_sg = module.security_group.aws_security_group-instance_sg
  aws_ecs_cluster_name           = local.aws_ecs_cluster_name
  aws_alb_target_group           = module.loadbalancer.aws_alb_target_group
  ECS_AMI                        = var.ECS_AMI
  INSTANCE_TYPE                  = var.INSTANCE_TYPE
  key_name                       = aws_key_pair.ecs_agent_key.key_name
  private_key_openssh            = tls_private_key.tls.private_key_openssh
  private_key_pem                = tls_private_key.tls.private_key_pem
  # AWS ACCESS INFO
  AWS_REGION          = var.AWS_REGION
  AWS_RESOURCE_PREFIX = var.AWS_RESOURCE_PREFIX
  AWS_PROFILE         = var.AWS_PROFILE
  AWS_ACCESS_KEY      = var.AWS_ACCESS_KEY
  AWS_SECRET_KEY      = var.AWS_SECRET_KEY
}

module "loadbalancer" {
  source                    = "./module/loadbalancer"
  aws_subnet                = module.network.aws_subnet
  aws_vpc                   = module.network.aws_vpc
  aws_security_group-alb_sg = module.security_group.aws_security_group-alb_sg
  # AWS ACCESS INFO
  AWS_REGION          = var.AWS_REGION
  AWS_RESOURCE_PREFIX = var.AWS_RESOURCE_PREFIX
  AWS_PROFILE         = var.AWS_PROFILE
  AWS_ACCESS_KEY      = var.AWS_ACCESS_KEY
  AWS_SECRET_KEY      = var.AWS_SECRET_KEY
}

module "monitoring" {
  source               = "./module/monitoring"
  aws_ecs_cluster_name = local.aws_ecs_cluster_name
  aws_ecs_service_name = local.aws_ecs_service_name
  EMAIL                = var.EMAIL
  # AWS ACCESS INFO
  AWS_REGION          = var.AWS_REGION
  AWS_RESOURCE_PREFIX = var.AWS_RESOURCE_PREFIX
  AWS_PROFILE         = var.AWS_PROFILE
  AWS_ACCESS_KEY      = var.AWS_ACCESS_KEY
  AWS_SECRET_KEY      = var.AWS_SECRET_KEY
}

module "network" {
  source = "./module/network"
  # AWS ACCESS INFO
  AWS_REGION          = var.AWS_REGION
  AWS_RESOURCE_PREFIX = var.AWS_RESOURCE_PREFIX
  AWS_PROFILE         = var.AWS_PROFILE
  AWS_ACCESS_KEY      = var.AWS_ACCESS_KEY
  AWS_SECRET_KEY      = var.AWS_SECRET_KEY
}

module "security_group" {
  source     = "./module/security_group"
  aws_vpc    = module.network.aws_vpc
  aws_subnet = module.network.aws_subnet
  # AWS ACCESS INFO
  AWS_REGION     = var.AWS_REGION
  AWS_PROFILE    = var.AWS_PROFILE
  AWS_ACCESS_KEY = var.AWS_ACCESS_KEY
  AWS_SECRET_KEY = var.AWS_SECRET_KEY
}
