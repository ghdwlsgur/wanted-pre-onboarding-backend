output "alb-dns-name" {
  value = module.loadbalancer.alb-dns-name
}

output "ssh_private_key" {
  value     = tls_private_key.tls.private_key_pem
  sensitive = true
}
