#iam_role
resource "aws_iam_role" "ec2_role" {
  name = "ec2-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
#iam_role/

#iam_policy
resource "aws_iam_role_policy" "ec2_secrets_policy" {
  name = "ec2-secrets-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.db_secret.arn
    }]
  })
}
#iam_policy/

#iam_instance_profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}
#iam_instance_profile/