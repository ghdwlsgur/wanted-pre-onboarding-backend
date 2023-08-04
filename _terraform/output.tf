output "alb-dns-name" {
  value = aws_alb.board-alb.dns_name
}

// private key (pem)
output "ssh_private_key" {
  value     = tls_private_key.tls.private_key_pem
  sensitive = true
}


