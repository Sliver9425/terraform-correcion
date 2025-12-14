output "alb_dns_name" {
  description = "La URL pública del Load Balancer"
  value       = aws_lb.mi_alb.dns_name
}

output "asg_name" {
  description = "El nombre del Auto Scaling Group creado"
  value       = aws_autoscaling_group.mi_asg.name
}