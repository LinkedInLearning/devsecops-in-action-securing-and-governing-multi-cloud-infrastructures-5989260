# resource "doppler_project" "frontend" {
#   name        = "red30tech-frontend"
#   description = "Frontend app secrets"
# }

# resource "doppler_environment" "dev" {
#   project = doppler_project.frontend.name
#   name    = "Development"
#   slug    = "dev"
# }

# resource "doppler_service_token" "frontend_dev_aws" {
#   project = doppler_project.frontend.name
#   config  = doppler_environment.dev.slug
#   name    = "frontend-dev-aws-readonly"
#   access  = "read"
# }
