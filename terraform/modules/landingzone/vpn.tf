// VPN 
resource "azurerm_public_ip" "vpn" {
  count               = var.enable_vpn ? 1 : 0
  name                = "${var.name_prefix}-vpn-ip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_virtual_network_gateway" "main" {
  count               = var.enable_vpn ? 1 : 0
  name                = "${var.name_prefix}-vpn"
  resource_group_name = var.rg_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1AZ"
  generation          = "Generation1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw.id
  }
}

// VPN peer (onprem)
resource "azurerm_local_network_gateway" "main" {
  count               = var.enable_vpn ? 1 : 0
  name                = "${var.name_prefix}-onprem"
  resource_group_name = var.rg_name
  location            = var.location
  gateway_address     = var.onprem_vpn_ip
  address_space       = var.onprem_ranges
}

// VPN connection
resource "azurerm_virtual_network_gateway_connection" "reg_to_onprem" {
  count                      = var.enable_vpn ? 1 : 0
  name                       = "reg_to_onprem"
  resource_group_name        = var.rg_name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.main[0].id
  enable_bgp                 = false
  shared_key                 = "Azure12345678"
}

// Send traffic from VPN to FW
resource "azurerm_route_table" "vpn" {
  count                         = (var.enable_vpn && var.route_onprem_via_firewall) ? 1 : 0
  name                          = "${var.name_prefix}-vpn-rt"
  resource_group_name           = var.rg_name
  location                      = var.location
  disable_bgp_route_propagation = false

  route {
    name                   = "internallToFirewall"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "vpn" {
  count          = (var.enable_vpn && var.route_onprem_via_firewall) ? 1 : 0
  subnet_id      = azurerm_subnet.gw.id
  route_table_id = azurerm_route_table.vpn[0].id
}
