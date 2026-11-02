resource "aws_sns_topic" "alerts" {
  count = var.enable_monitoring ? 1 : 0

  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Name      = "${var.project_name}-${var.environment}-alerts"
    Component = "monitoring"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_monitoring && var.alarm_email != null ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# --- ECS Alarms ---

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count = var.enable_monitoring && var.enable_ecs_service ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Fargate API task CPU utilization exceeded 80%."

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.api[0].name
  }

  alarm_actions = [aws_sns_topic.alerts[0].arn]
  ok_actions    = [aws_sns_topic.alerts[0].arn]

  tags = {
    Name      = "${var.project_name}-${var.environment}-ecs-cpu-high"
    Component = "monitoring"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count = var.enable_monitoring && var.enable_ecs_service ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Fargate API task memory utilization exceeded 80%."

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.api[0].name
  }

  alarm_actions = [aws_sns_topic.alerts[0].arn]
  ok_actions    = [aws_sns_topic.alerts[0].arn]

  tags = {
    Name      = "${var.project_name}-${var.environment}-ecs-memory-high"
    Component = "monitoring"
  }
}

# --- ALB 5XX Target Error Alarm ---

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  count = var.enable_monitoring && var.enable_ecs_service ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "ALB target 5XX error rate exceeded 5 in a single minute."
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.api[0].arn_suffix
    TargetGroup  = aws_lb_target_group.api[0].arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts[0].arn]
  ok_actions    = [aws_sns_topic.alerts[0].arn]

  tags = {
    Name      = "${var.project_name}-${var.environment}-alb-5xx-errors"
    Component = "monitoring"
  }
}

# --- RDS CPU Alarm ---

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  count = var.enable_monitoring && var.enable_rds ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS MySQL instance CPU utilization exceeded 80%."

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main[0].identifier
  }

  alarm_actions = [aws_sns_topic.alerts[0].arn]
  ok_actions    = [aws_sns_topic.alerts[0].arn]

  tags = {
    Name      = "${var.project_name}-${var.environment}-rds-cpu-high"
    Component = "monitoring"
  }
}

# --- CloudWatch Dashboard ---

resource "aws_cloudwatch_dashboard" "api" {
  count = var.enable_monitoring && var.enable_ecs_service ? 1 : 0

  dashboard_name = "${var.project_name}-${var.environment}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.api[0].name, "ClusterName", aws_ecs_cluster.main.name, { stat = "Average", period = 60 }],
            [".", "MemoryUtilization", ".", ".", ".", ".", { stat = "Average", period = 60 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service Resource Utilization"
          period  = 60
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.api[0].arn_suffix, { stat = "Sum", period = 60 }],
            [".", "HTTPCode_Target_5XX_Count", "TargetGroup", aws_lb_target_group.api[0].arn_suffix, "LoadBalancer", aws_lb.api[0].arn_suffix, { stat = "Sum", period = 60, color = "#d62728" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Request and Error Counts"
          period  = 60
        }
      }
    ]
  })
}
