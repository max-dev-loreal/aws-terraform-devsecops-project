output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "private_sg_id" {
  value = aws_security_group.app_private.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

