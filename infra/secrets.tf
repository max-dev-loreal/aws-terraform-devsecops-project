#secrets_manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "db-password"

  #dla-proverok
  recovery_window_in_days = 0
  #dla-proverok/

  tags = {
    Name = "db-secret"
  }
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = "postgres"
    password = "StrongPassword123!"
  })
}
#secrets_manger/