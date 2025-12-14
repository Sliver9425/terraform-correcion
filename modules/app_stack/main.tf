# --- 1. DATOS (Esto buscará la VPC de la cuenta donde se ejecute) ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- 2. SECURITY GROUP ---
resource "aws_security_group" "web_sg" {
  name        = "sg_${var.nombre_proyecto}"
  description = "Permitir HTTP y SSH para ${var.nombre_proyecto}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress { 
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- 3. LOAD BALANCER (ALB) ---
resource "aws_lb" "mi_alb" {
  name               = "alb-${lower(var.nombre_proyecto)}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = data.aws_subnets.default.ids
  
  tags = {
    Name = "alb-${var.nombre_proyecto}"
  }
}

resource "aws_lb_target_group" "mi_tg" {
  name     = "tg-${lower(var.nombre_proyecto)}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path    = "/"
    matcher = "200"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.mi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mi_tg.arn
  }
}

# --- 4. LAUNCH TEMPLATE (LIMPIO) ---
resource "aws_launch_template" "mi_lt" {
  name_prefix   = "lt-${lower(var.nombre_proyecto)}-"
  image_id      = var.ami_id 
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

  # ¡ADIOS USER_DATA! 
  # Confiamos en que tu AMI arranca el servicio Docker y el contenedor automáticamente.
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Instancia-${var.nombre_proyecto}"
    }
  }
}

# --- 5. AUTO SCALING GROUP ---
resource "aws_autoscaling_group" "mi_asg" {
  name                = "asg-${lower(var.nombre_proyecto)}"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.mi_tg.arn]

  launch_template {
    id      = aws_launch_template.mi_lt.id
    version = "$Latest"
  }
  
  instance_refresh {
    strategy = "Rolling"
  }
}

# --- 6. POLITICAS DE ESCALADO (CPU) ---
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "escalar-por-cpu"
  autoscaling_group_name = aws_autoscaling_group.mi_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0 
  }
}