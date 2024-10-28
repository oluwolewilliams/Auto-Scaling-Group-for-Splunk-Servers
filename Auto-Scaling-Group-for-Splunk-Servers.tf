##################################################################################
# Auto Scaling Group for Splunk Servers
##################################################################################
resource "aws_autoscaling_group" "splunk_asg" {
  count = var.use_asg ? 1 : 0  # Create ASG only if `use_asg` is true
  desired_capacity    = var.splunk_desired_capacity  # Desired capacity of 1
  max_size            = var.splunk_max_size          # Max capacity of 5
  min_size            = var.splunk_min_size          # Min capacity of 1
  vpc_zone_identifier = var.subnet_ids               # Subnets for ASG
  name                = "splunk-asg-${var.environment}"  # ASG name with environment
  launch_template {
    id      = aws_launch_template.splunk_template[0].id    # Reference to the Launch Template
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.name}-splunk-asg"
    propagate_at_launch = true
  }
  # Additional tags to propagate at launch
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  force_delete              = true  # Ensure clean removal of ASG
  health_check_type         = "EC2" # Use EC2 health checks
  health_check_grace_period = 300   # 5-minute grace period for health checks
  lifecycle {
    create_before_destroy = true  # Ensure ASG stability during updates
  }
}