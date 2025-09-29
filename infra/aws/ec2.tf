locals {
  frontend_b64 = base64encode(file("${path.module}/../../app/frontend/frontend.js"))
}

resource "aws_security_group" "frontend_sg" {
  name   = "frontend-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

variable "backend_url" {
  default = "http://red30tech.xyz:3001/api"
  type    = string
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true
  # no key_name -> no SSH

  user_data = <<-BASH
    #!/usr/bin/env bash
    set -eux
    apt-get update -y
    apt-get install -y nodejs

    mkdir -p /opt/frontend
    # write your repo file to the instance
    echo "${local.frontend_b64}" | base64 -d > /opt/frontend/frontend.js
    chmod 755 /opt/frontend/frontend.js

    cat >/etc/systemd/system/frontend.service <<'UNIT'
    [Unit]
    Description=Frontend Node app
    After=network-online.target
    Wants=network-online.target

    [Service]
    Environment=BACKEND_URL=${var.backend_url}
    WorkingDirectory=/opt/frontend
    ExecStart=/usr/bin/node /opt/frontend/frontend.js
    Restart=always
    RestartSec=2
    User=root

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now frontend.service
  BASH

  tags = { Name = "frontend" }
}

output "frontend_url" {
  value = "http://${aws_instance.frontend.public_ip}:3000"
}
