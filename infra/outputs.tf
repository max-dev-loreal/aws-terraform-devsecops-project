output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns" {
  value = module.alb.dns_name
}

output "db_endpoint" {
  value = module.rds.endpoint
}