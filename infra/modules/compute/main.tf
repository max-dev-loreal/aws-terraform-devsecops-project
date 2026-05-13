resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_prefix}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  key_name = var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  network_interfaces {
    security_groups             = [var.private_security_group_id]
    associate_public_ip_address = false
  }

  user_data = var.user_data_base64

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.name_prefix}-app-instance" })
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-app"
    propagate_at_launch = true
  }
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.public_subnet_ids[0]

  vpc_security_group_ids = [
    var.bastion_security_group_id,
  ]

  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-bastion" })
}
