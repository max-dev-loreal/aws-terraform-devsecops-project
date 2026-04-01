#cloudwatch_high_cpu
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name = "high-cpu"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  period    = 60
  statistic = "Average"

  threshold = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_up.arn
  ]
}
#cloudwatch_high_cpu/

#cloudwatch_low_cpu
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name = "low-cpu"

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  period    = 60
  statistic = "Average"

  threshold = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_down.arn
  ]
}
#cloudwatch_low_cpu/

#asg_policy_up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name

  scaling_adjustment = 1
  adjustment_type    = "ChangeInCapacity"
  cooldown           = 60
}
#asg_policy_scale_up/

#asg_policy_scale_down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name

  scaling_adjustment = -1
  adjustment_type    = "ChangeInCapacity"
  cooldown           = 60
}
#asg_policy_scale_down/