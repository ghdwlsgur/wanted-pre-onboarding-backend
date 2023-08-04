
resource "tls_private_key" "tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ecs_agent_key" {
  key_name   = "${var.AWS_RESOURCE_PREFIX}_${var.AWS_REGION}"
  public_key = tls_private_key.tls.public_key_openssh
}
