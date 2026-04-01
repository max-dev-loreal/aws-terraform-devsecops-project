#load_balancer
resource "aws_lb" "app_lb" {
  name               = "${local.prefix}-alb"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  security_groups = [aws_security_group.alb_sg.id]
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-alb"
  })
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${local.prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    port                = "80"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.prefix}-tg"
  })
}
#load_balancer/

#alb_http_listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-http-listener"
  })
}
#alb_http_listener/