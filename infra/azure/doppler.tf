resource "doppler_project" "backend" {
  name        = "red30tech-backend"
  description = "Backend app secrets"
}

resource "doppler_environment" "dev" {
  project = doppler_project.backend.name
  name    = "Development"
  slug    = "dev"
}

resource "doppler_service_token" "backend_dev_azure" {
  project = doppler_project.backend.name
  config  = doppler_environment.dev.slug
  name    = "backend-dev-azure-readonly"
  access  = "read"
}
