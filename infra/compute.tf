#launch_template
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${local.prefix}-lt"
  image_id      = "ami-0c1ac8a41498c1a9c"
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  key_name = "stockholm-max-key"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  network_interfaces {
    security_groups             = [aws_security_group.private_sg.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd aws-cli jq

systemctl start httpd
systemctl enable httpd

# HEALTH CHECK
echo "OK" > /var/www/html/health

# GET SECRET FROM SECRETS MANAGER
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id db-password \
  --region eu-north-1 \
  --query SecretString \
  --output text)

# SIMPLE APP OUTPUT
echo "=== APP STARTED ===" > /var/www/html/index.html
echo "Secret Loaded: $SECRET" >> /var/www/html/index.html
EOF
  )
}

#launch_template/

#asg
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}
#asg/

#compute
resource "aws_instance" "bastion" {
  ami           = "ami-0c1ac8a41498c1a9c"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_a.id

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  key_name                    = "stockholm-max-key"
  associate_public_ip_address = true

  tags = {
    Name    = "bastion-host"
    Project = local.project
  }
}
#compute/