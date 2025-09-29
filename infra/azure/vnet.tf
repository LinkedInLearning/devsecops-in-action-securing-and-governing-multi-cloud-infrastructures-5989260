resource "azurerm_resource_group" "red30tech_rg" {
  name     = "red30tech-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "red30tech_vnet" {
  name                = "red30tech-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.red30tech_rg.location
  resource_group_name = azurerm_resource_group.red30tech_rg.name
}

resource "azurerm_subnet" "red30tech_subnet" {
  name                 = "red30tech-subnet"
  resource_group_name  = azurerm_resource_group.red30tech_rg.name
  virtual_network_name = azurerm_virtual_network.red30tech_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
