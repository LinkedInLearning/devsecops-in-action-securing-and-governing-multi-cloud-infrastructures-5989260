terraform {
  backend "s3" {
    bucket         = "tfstate15196"
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
      source = "twingate/twingate"
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
