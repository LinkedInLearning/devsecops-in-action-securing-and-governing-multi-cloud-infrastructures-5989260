locals {
  frontend_b64     = base64encode(file("${path.module}/../../app/frontend/frontend.js"))
  frontend_pkg_b64 = base64encode(file("${path.module}/../../app/frontend/package.json"))
}

resource "aws_security_group" "frontend_sg" {
  name   = "frontend-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

variable "backend_url" {
  default = "http://api.red30tech.azure.internal/api"
  type    = string
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true
  private_ip                  = "10.20.101.101"
  user_data                   = <<-BASH
    #!/usr/bin/env bash
    set -eux

    export HOME=/root
    mkdir -p "$HOME/.tmp"

    # Node 18 LTS Install
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
    apt-get update -y
    apt-get install -y nodejs

    # Write app files
    mkdir -p /opt/frontend
    echo "${local.frontend_b64}"  | base64 -d > /opt/frontend/frontend.js
    echo "${local.frontend_pkg_b64}" | base64 -d > /opt/frontend/package.json

    # Install Dependencies
    cd /opt/frontend
    npm install --omit=dev

    # Create systemd service
    cat >/etc/systemd/system/frontend.service <<EOF
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
    EOF

    systemctl daemon-reload
    systemctl enable --now frontend.service

    # --- Twingate Headless Client ---
    curl -fsSL https://binaries.twingate.com/client/linux/install.sh | bash
    install -d -m 0700 /etc/twingate
    cat >/etc/twingate/service_key.json <<EOF
    ${twingate_service_account_key.aws_frontend_sa_key.token}
    EOF
    /usr/bin/twingate setup --headless /etc/twingate/service_key.json
    systemctl enable --now twingate

    # # --- Doppler Integration ---
    # curl -Ls https://cli.doppler.com/install.sh | bash
    # export DOPPLER_TOKEN="$${doppler_service_token.frontend_dev_aws.key}"
    # doppler secrets download \
    #   --project red30tech-frontend \
    #   --config dev \
    #   --format env --no-file > /etc/default/frontend.env
    # sed -i 's|^Environment=.*$|EnvironmentFile=/etc/default/frontend.env|' /etc/systemd/system/frontend.service
    # systemctl daemon-reload
    # systemctl restart frontend.service
  BASH

  tags = {
    Name        = "frontend"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_eip" "frontend" {
  domain = "vpc"
  tags = {
    Name = "frontend-eip"
  }
}

resource "aws_eip_association" "frontend" {
  instance_id   = aws_instance.frontend.id
  allocation_id = aws_eip.frontend.id
}

output "frontend_url" {
  value = "http://${aws_eip.frontend.public_ip}"
}
