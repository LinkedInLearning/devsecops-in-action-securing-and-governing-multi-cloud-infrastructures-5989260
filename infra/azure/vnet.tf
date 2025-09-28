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
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

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

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
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
