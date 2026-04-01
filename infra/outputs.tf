output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}