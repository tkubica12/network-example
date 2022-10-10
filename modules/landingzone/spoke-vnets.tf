resource "azurerm_virtual_network" "spoke" {
  count               = var.spoke_count
  name                = "${var.name_prefix}-spoke-${count.index + 1}"
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = [cidrsubnet(var.range, 8, count.index + 1)]
}

resource "azurerm_subnet" "sub01" {
  count                = var.spoke_count
  name                 = "sub01"
  virtual_network_name = azurerm_virtual_network.spoke[count.index].name
  resource_group_name  = var.rg_name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.spoke[count.index].address_space[0], 2, 0)]
}

resource "azurerm_subnet" "sub02" {
  count                = var.spoke_count
  name                 = "sub02"
  virtual_network_name = azurerm_virtual_network.spoke[count.index].name
  resource_group_name  = var.rg_name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.spoke[count.index].address_space[0], 2, 1)]
}

resource "azurerm_route_table" "main" {
  name                          = "${var.name_prefix}-rt"
  resource_group_name           = var.rg_name
  location                      = var.location
  disable_bgp_route_propagation = true

  route {
    name                   = "allToFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "sub01" {
  count          = var.spoke_count
  subnet_id      = azurerm_subnet.sub01[count.index].id
  route_table_id = azurerm_route_table.main.id
}

resource "azurerm_subnet_route_table_association" "sub02" {
  count          = var.spoke_count
  subnet_id      = azurerm_subnet.sub02[count.index].id
  route_table_id = azurerm_route_table.main.id
}

resource "azurerm_virtual_network_peering" "spokes" {
  count                     = var.spoke_count
  name                      = "${var.name_prefix}-spokehub-${count.index + 1}"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.spoke[count.index].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "hub" {
  count                     = var.spoke_count
  name                      = "${var.name_prefix}-hubspoke-${count.index + 1}"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke[count.index].id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
}
