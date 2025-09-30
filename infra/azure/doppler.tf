variable "doppler_token" {
  type        = string
  sensitive   = true
  description = "Personal/Admin token for provisioning Doppler"
}

provider "doppler" {
  doppler_token = var.doppler_token
}

resource "doppler_project" "backend" {
  name        = "red30tech-backend"
  description = "Backend app secrets"
}

resource "doppler_environment" "dev" {
  project = doppler_project.backend.name
  name    = "Development"
  slug    = "dev"
}

resource "doppler_config" "dev_azure" {
  project     = doppler_project.backend.name
  environment = doppler_environment.dev.slug
  name        = "dev_aws"
  inheritable = false
}

resource "doppler_config" "dev_azure" {
  project     = doppler_project.backend.name
  environment = doppler_environment.dev.slug
  name        = "dev_azure"
  inheritable = false
}

resource "doppler_service_token" "backend_dev_azure" {
  project = doppler_project.backend.name
  config  = doppler_config.dev_azure.name
  name    = "backend-dev-azure-readonly"
  access  = "read"
}
