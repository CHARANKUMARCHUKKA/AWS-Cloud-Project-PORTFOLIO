resource "aws_lb" "api" {
  count = var.enable_ecs_service ? 1 : 0

  name               = local.api_load_balancer_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
  drop_invalid_header_fields = true

  tags = {
    Name      = "${var.project_name}-${var.environment}-api"
    Component = "load-balancer"
  }
}

resource "aws_lb_target_group" "api" {
  count = var.enable_ecs_service ? 1 : 0

  name        = local.api_load_balancer_name
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/ready"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  count = var.enable_ecs_service ? 1 : 0

  load_balancer_arn = aws_lb.api[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.enable_ecs_service ? 1 : 0

  load_balancer_arn = aws_lb.api[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api[0].arn
  }
}
