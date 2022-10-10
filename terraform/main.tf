resource "azurerm_resource_group" "reg1" {
  name     = "reg1"
  location = "northeurope"
}

resource "azurerm_resource_group" "reg2" {
  name     = "reg2"
  location = "westeurope"
}

module "reg1" {
  source        = "./modules/landingzone"
  location      = azurerm_resource_group.reg1.location
  rg_name       = azurerm_resource_group.reg1.name
  name_prefix   = "reg1"
  range         = "10.1.0.0/16"
  onprem_vpn_ip = azurerm_public_ip.onprem_vpn.ip_address
  bgp_asn       = 65001
  bgp_peer_asn  = 65099
  bgp_peer_ip   = azurerm_virtual_network_gateway.onprem_vpn.bgp_settings[0].peering_addresses[0].default_addresses[0]
  enable_vpn    = true
  spoke_count   = 2
}

module "reg2" {
  source        = "./modules/landingzone"
  location      = azurerm_resource_group.reg2.location
  rg_name       = azurerm_resource_group.reg2.name
  name_prefix   = "reg2"
  range         = "10.2.0.0/16"
  onprem_vpn_ip = azurerm_public_ip.onprem_vpn.ip_address
  bgp_asn       = 65002
  bgp_peer_asn  = 65099
  bgp_peer_ip   = azurerm_virtual_network_gateway.onprem_vpn.bgp_settings[0].peering_addresses[0].default_addresses[0]
  enable_vpn    = true
  spoke_count   = 2
}

output "debug" {
  value = module.reg1.spokes_ranges
}