resource "aws_autoscaling_policy" "scale_up_nginx" {
  name                   = "terramino_scale_down"
  autoscaling_group_name = aws_autoscaling_group.nginx.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description   = "Monitors CPU utilization for Nignx ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_up_nginx.arn]
  alarm_name          = "nginx_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "50"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nginx.name
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_launch_template" "nginx" {
  name_prefix   = "nginx"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t4g.nano"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = aws_key_pair.this.key_name

  user_data = filebase64("${path.module}/setup.sh")
}

resource "aws_autoscaling_group" "nginx" {
  name_prefix         = "nginx"
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.nginx.id
    version = "$Latest"
  }

  tag {
    key                 = "name"
    value               = "nginx"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true
  }

}
