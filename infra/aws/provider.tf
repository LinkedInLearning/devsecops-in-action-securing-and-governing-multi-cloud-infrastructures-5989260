terraform {
  backend "s3" {
    bucket         = "tfstate15619"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
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
    http = {
      source  = "hashicorp/http"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "twingate" {
  api_token = var.tg_api_key
  network   = var.tg_network
}

provider "doppler" {
  doppler_token = var.doppler_token
}