resource "twingate_remote_network" "aws_network" {
  name = "Red30Tech AWS Dev Remote Network"
}

resource "twingate_connector" "aws_connector" {
  remote_network_id = twingate_remote_network.aws_network.id
}

resource "twingate_connector_tokens" "aws_connector_tokens" {
  connector_id = twingate_connector.aws_connector.id
}

resource "aws_security_group" "twingate_sg" {
  name   = "twingate-sg"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "twingate_connector" {
  ami                         = "ami-08a58c22a6e788ea2" # Version 1.78.0
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.twingate_sg.id]
  user_data                   = <<-EOT
    #!/bin/bash
    set -e
    mkdir -p /etc/twingate/
    {
      echo TWINGATE_URL="https://${var.tg_network}.twingate.com"
      echo TWINGATE_ACCESS_TOKEN="${twingate_connector_tokens.aws_connector_tokens.access_token}"
      echo TWINGATE_REFRESH_TOKEN="${twingate_connector_tokens.aws_connector_tokens.refresh_token}"
    } > /etc/twingate/connector.conf
    sudo systemctl enable --now twingate-connector
  EOT

  tags = {
    Name        = "Twingate Connector"
    Environment = var.environment
    Project     = var.project
  }
}

resource "twingate_group" "aws_devops" {
  name = "AWS DevOps"
}

resource "twingate_resource" "aws_frontend_resource" {
  name              = "red30tech.aws.internal"
  address           = aws_instance.frontend.private_ip
  remote_network_id = twingate_remote_network.aws_network.id
  alias             = "red30tech.aws.internal"
  access_group {
    group_id = twingate_group.aws_devops.id
  }
  protocols = {
    allow_icmp = true
    tcp = {
      policy = "RESTRICTED"
      ports  = ["80"]
    }
    udp = {
      policy = "ALLOW_ALL"
    }
  }
}

# A service account that will run on the AWS frontend host
resource "twingate_service_account" "aws_frontend_sa" {
  name = "aws-frontend-headless"
}

resource "twingate_service_account_key" "aws_frontend_sa_key" {
  name               = "AWS Frontend Key"
  service_account_id = twingate_service_account.aws_frontend_sa.id
}
