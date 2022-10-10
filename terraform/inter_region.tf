// Global VNET peering
resource "azurerm_virtual_network_peering" "reg1-reg2" {
  name                      = "reg1-reg2"
  resource_group_name       = azurerm_resource_group.reg1.name
  virtual_network_name      = module.reg1.hub_vnet_name
  remote_virtual_network_id = module.reg2.hub_vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "reg2-reg1" {
  name                      = "reg2-reg1"
  resource_group_name       = azurerm_resource_group.reg2.name
  virtual_network_name      = module.reg2.hub_vnet_name
  remote_virtual_network_id = module.reg1.hub_vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

// Route table for firewall subnet
resource "azurerm_route_table" "reg1-fw" {
  name                          = "reg1-fw-rt"
  resource_group_name           = azurerm_resource_group.reg1.name
  location                      = azurerm_resource_group.reg1.location
  disable_bgp_route_propagation = false

  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  dynamic "route" {
    for_each = module.reg2.spokes_ranges
    content {
      name                   = "otherRegion-${split("/",route.value[0])[0]}"
      address_prefix         = route.value[0]
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.reg2.fw_ip
    }
  } 

  route {
    name                   = "onpremBackupViaReg2"
    address_prefix         = "10.98.0.0/15"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.reg2.fw_ip
  }
}

resource "azurerm_route_table" "reg2-fw" {
  name                          = "reg2-fw-rt"
  resource_group_name           = azurerm_resource_group.reg2.name
  location                      = azurerm_resource_group.reg2.location
  disable_bgp_route_propagation = false

  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  dynamic "route" {
    for_each = module.reg1.spokes_ranges
    content {
      name                   = "otherRegion-${split("/",route.value[0])[0]}"
      address_prefix         = route.value[0]
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.reg1.fw_ip
    }
  } 

  route {
    name                   = "onpremBackupViaReg1"
    address_prefix         = "10.98.0.0/15"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.reg1.fw_ip
  }
}

resource "azurerm_subnet_route_table_association" "reg1-fw" {
  subnet_id      = module.reg1.fw_subnet_id
  route_table_id = azurerm_route_table.reg1-fw.id
}

resource "azurerm_subnet_route_table_association" "reg2-fw" {
  subnet_id      = module.reg2.fw_subnet_id
  route_table_id = azurerm_route_table.reg2-fw.id
}
