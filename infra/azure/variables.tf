variable "tg_network" {
  type    = string
  default = "red30tech"
}

variable "tg_api_key" {
  type      = string
  sensitive = true
}

variable "dockerhub_username" {
  type = string
}

variable "dockerhub_token" {
  type = string
}
