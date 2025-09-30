variable "doppler_token" {
  type        = string
  sensitive   = true
  description = "Personal/Admin token for provisioning Doppler"
}

provider "doppler" {
  doppler_token = var.doppler_token
}

resource "doppler_project" "frontend" {
  name        = "red30tech-frontend"
  description = "Frontend app secrets"
}

resource "doppler_environment" "dev" {
  project = doppler_project.frontend.name
  name    = "Development"
  slug    = "dev"
}

resource "doppler_config" "dev_aws" {
  project     = doppler_project.frontend.name
  environment = doppler_environment.dev.slug
  name        = "dev"
}

resource "doppler_service_token" "frontend_dev_aws" {
  project = doppler_project.frontend.name
  config  = doppler_config.dev_aws.name
  name    = "frontend-dev-aws-readonly"
  access  = "read"
}
