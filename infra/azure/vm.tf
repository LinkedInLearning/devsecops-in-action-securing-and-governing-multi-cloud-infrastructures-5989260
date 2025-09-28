# resource "azurerm_linux_virtual_machine" "red30tech_vm" {
#   name                            = "red30tech-vm"
#   resource_group_name             = azurerm_resource_group.red30tech_rg.name
#   location                        = azurerm_resource_group.red30tech_rg.location
#   size                            = "Standard_B1s"
#   admin_username                  = "azureuser"
#   admin_password                  = var.admin_password
#   disable_password_authentication = false

#   network_interface_ids = [
#     azurerm_network_interface.red30tech_nic.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts-gen2"
#     version   = "latest"
#   }
# }
