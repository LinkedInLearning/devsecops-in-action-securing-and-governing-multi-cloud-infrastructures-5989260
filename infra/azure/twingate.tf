resource "twingate_remote_network" "azure_network" {
  name = "Red30Tech Azure Dev Remote Network"
}

resource "twingate_connector" "azure_connector" {
  remote_network_id = twingate_remote_network.azure_network.id
}

resource "twingate_connector_tokens" "twingate_connector_tokens" {
  connector_id = twingate_connector.azure_connector.id
}

resource "azurerm_container_group" "twingate_connector_container" {
  name                = "azure-twingate-connector"
  location            = azurerm_resource_group.red30tech_rg.location
  resource_group_name = azurerm_resource_group.red30tech_rg.name
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.twingate_azure_container_subnet.id]
  os_type             = "Linux"

  container {
    name   = "twingateconnector"
    image  = "twingate/connector:1.78.0"
    cpu    = "1"
    memory = "1.5"
    environment_variables = {
      "TWINGATE_NETWORK"          = "${var.tg_network}"
      "TWINGATE_ACCESS_TOKEN"     = twingate_connector_tokens.twingate_connector_tokens.access_token
      "TWINGATE_REFRESH_TOKEN"    = twingate_connector_tokens.twingate_connector_tokens.refresh_token
      "TWINGATE_TIMESTAMP_FORMAT" = "2"
    }
    ports {
      port     = 9999
      protocol = "UDP"
    }
  }
}

resource "twingate_group" "azure_devops" {
  name = "Azure DevOps"
}

resource "twingate_resource" "azure_backend_resource" {
  name              = "red30tech.xyz:3001"
  address           = azurerm_network_interface.red30tech_nic.private_ip_address
  remote_network_id = twingate_remote_network.azure_network.id
  access_group {
    group_id = twingate_group.azure_devops.id
  }
  protocols = {
    allow_icmp = true
    tcp = {
      policy = "RESTRICTED"
      ports  = ["3001"]
    }
    udp = {
      policy = "ALLOW_ALL"
    }
  }
}
