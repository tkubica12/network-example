resource "azurerm_local_network_gateway" "p2s_peer_reg2" {
  name                = "p2s-peer-reg2"
  resource_group_name = azurerm_resource_group.reg1.name
  location            = azurerm_resource_group.reg1.location
  gateway_address     = module.reg2.vpn_ip
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_local_network_gateway" "p2s_peer_reg1" {
  name                = "p2s-peer-reg1"
  resource_group_name = azurerm_resource_group.reg1.name
  location            = azurerm_resource_group.reg1.location
  gateway_address     = module.reg1.vpn_ip
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network_gateway_connection" "p2s_to_reg2" {
  name                       = "p2s_to_reg2"
  resource_group_name        = azurerm_resource_group.reg1.name
  location                   = azurerm_resource_group.reg1.location
  type                       = "IPsec"
  virtual_network_gateway_id = module.reg1.vpn_id
  local_network_gateway_id   = azurerm_local_network_gateway.p2s_peer_reg2.id
  enable_bgp                 = false
  shared_key                 = "Azure12345678"
}

resource "azurerm_virtual_network_gateway_connection" "p2s_to_reg1" {
  name                       = "p2s_to_reg1"
  resource_group_name        = azurerm_resource_group.reg2.name
  location                   = azurerm_resource_group.reg2.location
  type                       = "IPsec"
  virtual_network_gateway_id = module.reg2.vpn_id
  local_network_gateway_id   = azurerm_local_network_gateway.p2s_peer_reg1.id
  enable_bgp                 = false
  shared_key                 = "Azure12345678"
}
