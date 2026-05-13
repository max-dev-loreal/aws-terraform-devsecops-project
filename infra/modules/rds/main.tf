resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-db"

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]

  publicly_accessible       = false
  backup_retention_period   = var.backup_retention_days
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name_prefix}-db-final-snapshot"

  multi_az            = var.multi_az
  deletion_protection = var.deletion_protection
  storage_encrypted   = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-instance" })
}
