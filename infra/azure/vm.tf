locals {
  backend_b64 = base64encode(file("${path.module}/../../app/backend/backend.js"))
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
    destination_port_range     = "3001"
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

  # cloud-init writes your repo file and runs it
  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
    package_update: true
    packages:
      - nodejs

    write_files:
      - path: /opt/backend/backend.js
        permissions: "0755"
        encoding: b64
        content: ${local.backend_b64}

      - path: /etc/systemd/system/backend.service
        permissions: "0644"
        content: |
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

    runcmd:
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
  value = "http://${azurerm_public_ip.red30tech_public_ip.ip_address}:3001/api"
}
