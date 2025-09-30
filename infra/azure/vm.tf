locals {
  backend_b64     = base64encode(file("${path.module}/../../app/backend/backend.js"))
  backend_pkg_b64 = base64encode(file("${path.module}/../../app/backend/package.json"))
}

resource "random_password" "linux_admin" {
  length  = 12
  special = true
}

resource "azurerm_public_ip" "red30tech_public_ip" {
  name                = "red30tech-public-ip"
  location            = azurerm_resource_group.red30tech_rg.location
  resource_group_name = azurerm_resource_group.red30tech_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "red30tech_nsg" {
  name                = "red30tech-nsg"
  location            = azurerm_resource_group.red30tech_rg.location
  resource_group_name = azurerm_resource_group.red30tech_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "red30tech_nic_nsg" {
  network_interface_id      = azurerm_network_interface.red30tech_nic.id
  network_security_group_id = azurerm_network_security_group.red30tech_nsg.id
}

resource "azurerm_network_interface" "red30tech_nic" {
  name                = "red30tech-nic"
  location            = azurerm_resource_group.red30tech_rg.location
  resource_group_name = azurerm_resource_group.red30tech_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.red30tech_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.red30tech_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "red30tech_vm" {
  name                            = "red30tech-vm"
  location                        = azurerm_resource_group.red30tech_rg.location
  resource_group_name             = azurerm_resource_group.red30tech_rg.name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = random_password.linux_admin.result
  network_interface_ids           = [azurerm_network_interface.red30tech_nic.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
    package_update: true
    packages:
      - ca-certificates
      - curl
      - gnupg

    runcmd:
      # Install Node 18 from NodeSource
      - install -m 0755 -d /etc/apt/keyrings
      - curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
      - echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
      - apt-get update -y
      - apt-get install -y nodejs

      # Write app files
      - mkdir -p /opt/backend
      - echo "${local.backend_b64}"  | base64 -d > /opt/backend/backend.js
      - echo "${local.backend_pkg_b64}" | base64 -d > /opt/backend/package.json
      - cd /opt/backend && npm install --omit=dev

      # Systemd service
      - |
        cat >/etc/systemd/system/backend.service <<'UNIT'
        [Unit]
        Description=Backend Node app
        After=network-online.target
        Wants=network-online.target

        [Service]
        WorkingDirectory=/opt/backend
        ExecStart=/usr/bin/node /opt/backend/backend.js
        Restart=always
        RestartSec=2
        User=root

        [Install]
        WantedBy=multi-user.target
        UNIT

      - systemctl daemon-reload
      - systemctl enable --now backend.service
    CLOUDINIT
  )

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }
}

output "backend_url" {
  value = "http://${azurerm_public_ip.red30tech_public_ip.ip_address}/api"
}
