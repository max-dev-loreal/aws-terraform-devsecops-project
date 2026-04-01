#rds_subnet_group
resource "aws_db_subnet_group" "db_subnets" {
  name = "${local.prefix}-subnet-group"

  subnet_ids = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-db-subnet-group"
  })
}
#rds_subnet_group/

#rds_instance
resource "aws_db_instance" "postgres" {
  identifier = "${local.prefix}-db"

  engine         = "postgres"
  engine_version = "15"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = "appdb"
  username = "postgres"
  password = jsondecode(aws_secretsmanager_secret_version.db_secret_value.secret_string).password

  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible     = false
  backup_retention_period = 7
  skip_final_snapshot     = true

  multi_az            = true
  deletion_protection = true

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-db-instance"
  })
}
#rds_instance/