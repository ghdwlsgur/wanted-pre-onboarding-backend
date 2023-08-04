output "aws_alb_target_group" {
  value = aws_alb_target_group.board.id
}

output "alb-dns-name" {
  value = aws_alb.board-alb.dns_name
}
