# --- RESULTADOS DEL BACKEND ---
output "backend_resultados" {
  description = "Información de despliegue del Backend (Lab 1)"
  value = {
    load_balancer_url = "http://${module.backend_api.alb_dns_name}"
    auto_scaling_group = module.backend_api.asg_name
  }
}

# --- RESULTADOS DEL FRONTEND ---
output "frontend_resultados" {
  description = "Información de despliegue del Frontend (Lab 2)"
  value = {
    load_balancer_url = "http://${module.frontend_web.alb_dns_name}"
    auto_scaling_group = module.frontend_web.asg_name
  }
}