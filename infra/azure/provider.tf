terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-azure"
    storage_account_name = "tfstate8111972"
    container_name       = "tfstate-azure-container"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    twingate = {
      source  = "twingate/twingate"
      version = "3.5.0"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.20.0"
    }
    # Intentionally old pins to trigger Dependabot PRs
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
  }
}
provider "azurerm" {
  features {}
}

provider "twingate" {
  api_token = var.tg_api_key
  network   = var.tg_network
}

provider "doppler" {
  doppler_token = var.doppler_token
}