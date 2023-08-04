
output "aws_security_group-instance_sg" {
  value = aws_security_group.instance-sg.id
}

output "aws_security_group-alb_sg" {
  value = aws_security_group.alb-sg.id
}
