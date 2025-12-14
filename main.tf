terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # CONFIGURACIÓN BACKBLAZE B2
  backend "s3" {
    bucket   = "terraform-correccion2"
    key      = "examen/terraform.tfstate"
    region   = "us-east-1"
    
    endpoint = "https://s3.us-east-005.backblazeb2.com" 
    
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# --- PROVEEDOR 1: BACKEND (Lab 1) ---
provider "aws" {
  alias      = "lab_backend"
  region     = "us-east-1"
  access_key = var.lab1_access_key
  secret_key = var.lab1_secret_key
  token      = var.lab1_session_token
}

# --- PROVEEDOR 2: FRONTEND (Lab 2) ---
provider "aws" {
  alias      = "lab_frontend"
  region     = "us-east-1"
  access_key = var.lab2_access_key
  secret_key = var.lab2_secret_key
  token      = var.lab2_session_token
}

# --- DESPLIEGUE MÓDULO BACKEND ---
module "backend_api" {
  source = "./modules/app_stack"
  providers = {
    aws = aws.lab_backend
  }

  nombre_proyecto = "Backend-API"
  ami_id          = var.lab1_ami_id
  # docker_image ELIMINADO: La AMI ya tiene el contenedor corriendo
}

# --- DESPLIEGUE MÓDULO FRONTEND ---
module "frontend_web" {
  source = "./modules/app_stack"
  providers = {
    aws = aws.lab_frontend
  }

  nombre_proyecto = "Frontend-Web"
  ami_id          = var.lab2_ami_id
  # docker_image ELIMINADO: La AMI ya tiene el contenedor corriendo
}