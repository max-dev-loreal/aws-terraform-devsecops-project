resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids = var.subnet_ids

  security_group_ids = [
    var.security_group_id,
  ]

  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce-secretsmanager" })
}

