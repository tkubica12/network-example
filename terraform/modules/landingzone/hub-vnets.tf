resource "azurerm_virtual_network" "hub" {
  name                = "${var.name_prefix}-hub"
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = [cidrsubnet(var.range, 8, 0)]
}

resource "azurerm_subnet" "fw" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = azurerm_virtual_network.hub.name
  resource_group_name  = var.rg_name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.hub.address_space[0], 2, 0)]
}

resource "azurerm_subnet" "gw" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.hub.name
  resource_group_name  = var.rg_name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.hub.address_space[0], 2, 1)]
}


