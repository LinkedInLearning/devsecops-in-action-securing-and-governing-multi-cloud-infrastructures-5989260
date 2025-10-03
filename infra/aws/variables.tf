variable "tg_network" {
  type    = string
  default = "red30tech"
}

variable "tg_api_key" {
  type      = string
  sensitive = true
}

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
