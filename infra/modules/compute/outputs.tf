output "asg_name" {
  value = aws_autoscaling_group.app.name
}

output "bastion_id" {
  value = aws_instance.bastion.id
}

