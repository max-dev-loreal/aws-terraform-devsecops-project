output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns" {
  value = module.alb.dns_name
}

output "db_endpoint" {
  value = module.rds.endpoint
}
output "webhook_url" {
  value = module.lambda_bot.webhook_url
}
