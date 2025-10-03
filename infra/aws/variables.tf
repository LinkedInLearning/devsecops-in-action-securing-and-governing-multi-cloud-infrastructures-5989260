variable "doppler_token" {
  type        = string
  sensitive   = true
  description = "Personal/Admin token for provisioning Doppler"
}

variable "environment" {
  default = "dev"
  type    = string
}

variable "project" {
  default = "Red30Tech"
  type    = string
}
