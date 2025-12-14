variable "ami_id" {
  description = "El ID de la AMI que se usará para lanzar las instancias (varía según el laboratorio)"
  type        = string
}

variable "nombre_proyecto" {
  description = "Nombre para etiquetar los recursos (ej: Backend-API, Frontend-Web)"
  type        = string
}