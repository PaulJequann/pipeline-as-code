resource "aws_cloudwatch_metric_alarm" "jenkins_workers_high_cpu" {
  alarm_name          = "high-cpu-jenkins-workers"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_workers.name
  }

  alarm_description = "This metric monitors workers cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-out.arn]
}

resource "aws_autoscaling_policy" "scale-out" {
  name                   = "scale-out-jenkins-workers"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
}

resource "aws_cloudwatch_metric_alarm" "jenkins_workers_low_cpu" {
  alarm_name          = "low-cpu-jenkins-workers"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_workers.name
  }

  alarm_description = "This metric monitors workers cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-in.arn]
}

resource "aws_autoscaling_policy" "scale-in" {
  name                   = "scale-in-jenkins-workers"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
}