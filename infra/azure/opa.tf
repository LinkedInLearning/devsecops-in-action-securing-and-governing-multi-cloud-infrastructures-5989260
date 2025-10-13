resource "azurerm_linux_virtual_machine" "opa_azure" {
  name                            = "opa-azure-vm"
  location                        = azurerm_resource_group.red30tech_rg.location
  resource_group_name             = azurerm_resource_group.red30tech_rg.name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = random_password.linux_admin.result
  network_interface_ids           = [azurerm_network_interface.opa_nic.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "azurerm_network_interface" "opa_nic" {
  name                = "opa-nic"
  location            = azurerm_resource_group.red30tech_rg.location
  resource_group_name = azurerm_resource_group.red30tech_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.red30tech_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.5"
  }
}
