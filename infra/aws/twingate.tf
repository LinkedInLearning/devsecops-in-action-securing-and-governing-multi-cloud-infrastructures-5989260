resource "twingate_remote_network" "aws_network" {
  name = "Red30Tech AWS Dev Remote Network"
}

resource "twingate_connector" "aws_connector" {
  remote_network_id = twingate_remote_network.aws_network.id
}

resource "twingate_connector_tokens" "aws_connector_tokens" {
  connector_id = twingate_connector.aws_connector.id
}

resource "aws_instance" "twingate_connector" {
  ami                         = "ami-08a58c22a6e788ea2" # Version 1.78.0
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
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
    "Name" = "Twingate Connector"
  }
}

resource "twingate_group" "aws_devops" {
  name = "AWS DevOps"
}

resource "twingate_resource" "aws_frontend_resource" {
  name              = "red30tech.internal"
  address           = aws_instance.frontend.private_ip
  remote_network_id = twingate_remote_network.aws_network.id
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
